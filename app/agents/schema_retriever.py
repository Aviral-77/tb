"""
RAG-based schema retriever.

On first call, embeds every table description with Ollama embeddings and
caches the vectors in memory.  Per query it computes cosine similarity
against the user question and returns the top-K most relevant tables plus
any FK-connected neighbours (so the LLM can write correct JOINs).

Falls back to keyword overlap scoring when the embedding model is unavailable.
"""
from __future__ import annotations

import logging
import threading
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import yaml

from app.config.settings import settings
from app.db.schema_inspector import TableInfo, inspect_schema

_DESCRIPTIONS_FILE = Path(__file__).parent / "schema_descriptions.yaml"

log = logging.getLogger("tbg.retriever")

_TOP_K_DEFAULT = 4          # direct-match tables before FK expansion
_MAX_EXPANDED  = 10         # hard cap after FK expansion (increased for domain hints)

# French/domain keyword → table names to force-include when the keyword appears in the question.
_DOMAIN_HINTS: dict[str, list[str]] = {
    # KPI / revenue — always the financial_metrics_data hierarchy
    "arpu":         ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "revenue":      ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "recette":      ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "breakdown":    ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "repartition":  ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "category":     ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "categorie":    ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "p&l":          ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "ebitda":       ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "sortant":      ["financial_metrics_data", "financial_metric", "financial_types"],
    "entrant":      ["financial_metrics_data", "financial_metric", "financial_types"],
    "budget":       ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    "kpi":          ["financial_metrics_data", "financial_metric", "financial_types"],
    "metric":       ["financial_metrics_data", "financial_metric"],
    "metrique":     ["financial_metrics_data", "financial_metric"],
    "financial":    ["financial_metrics_data", "financial_metric", "financial_types", "financial_categories"],
    # Cash flow — only when explicitly asked
    "flux":         ["cashflow_data", "cashflow_sections", "cashflow_categories", "realised_cashflow"],
    "cashflow":     ["cashflow_data", "cashflow_sections", "cashflow_categories", "realised_cashflow"],
    "cash flow":    ["cashflow_data", "cashflow_sections", "cashflow_categories", "realised_cashflow"],
    "tresorerie":   ["cashflow_data", "cashflow_sections", "cashflow_categories"],
    # CAPEX
    "capex":        ["capex_data", "capex_projects"],
    # Commissions
    "enlevement":   ["commission_enlevements"],
    "enlevements":  ["commission_enlevements"],
    "commission":   ["commission_enlevements", "commission_calculation_rules", "commission_types"],
    "distributor":  ["commission_enlevements"],
    "distributeur": ["commission_enlevements"],
    # Moov Money
    "momo":         ["moov_money_data"],
    "mobile money": ["moov_money_data"],
}

# Tables that are system/operational and should never appear in business queries.
_BLOCKLISTED_TABLES: frozenset[str] = frozenset({
    "DownloadRequests", "SequelizeMeta",
    "activity_events", "alert_notifications", "app_icons",
    "archive_registry", "archive_storage_kpis",
    "configuration", "configuration_archive",
    "country_module_configs", "data_lineage_notification",
    "decoder_configuration", "feature_prerequisites", "feature_section",
    "health_apps", "health_checks", "import_sources",
    "login_events", "mail_recipient_lists",
    "modules", "navigation_items",
    "network_registry", "nifi_connection_ids",
    "notification_tracking", "notifications",
    "portal_settings", "si_registry", "smtp_details",
    "superset_dashboard", "theme_configurations",
    "upload_component_types", "upload_sheet_types",
    "upload_tbg_file_types", "vendor_registry",
    # Raw ERP / upload-tracking tables — never useful for business queries
    "sage_yexptdb", "tbg_capex_project_details",
    "revenue_uploaded_files", "data_cormat_upload_files",
    "data_dormant_upload_files", "upload_data",
})


# ---------------------------------------------------------------------------
# Public result type
# ---------------------------------------------------------------------------

@dataclass
class RetrievedSchema:
    tables: list[TableInfo]
    schema_text: str
    allowed_tables: set[str]   # table names the LLM is permitted to use


# ---------------------------------------------------------------------------
# Retriever
# ---------------------------------------------------------------------------

def _load_descriptions() -> dict[str, dict]:
    """Load schema_descriptions.yaml; return empty dict if file missing."""
    if not _DESCRIPTIONS_FILE.exists():
        log.warning("schema_descriptions.yaml not found — using column-only embeddings")
        return {}
    with _DESCRIPTIONS_FILE.open(encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    log.info("Loaded human descriptions for %d tables from schema_descriptions.yaml", len(data))
    return data


class SchemaRetriever:
    """Thread-safe singleton.  Call build() once; retrieve() is thread-safe."""

    def __init__(self) -> None:
        self._lock   = threading.Lock()
        self._ready  = False
        self._infos:  list[TableInfo]          = []
        self._texts:  dict[str, str]           = {}   # name → rich embedding text
        self._vecs:   dict[str, np.ndarray]    = {}   # name → embedding vector
        self._fk_out: dict[str, set[str]]      = {}   # name → {ref_table, …}
        self._embed_model = None
        self._descriptions: dict[str, dict]    = {}

    # ------------------------------------------------------------------
    # Build (called once)
    # ------------------------------------------------------------------

    def build(self) -> None:
        with self._lock:
            if self._ready:
                return
            self._descriptions = _load_descriptions()
            log.info("SchemaRetriever.build() — loading schema from DB …")
            all_infos = inspect_schema()
            self._infos = [t for t in all_infos if t.name not in _BLOCKLISTED_TABLES]
            log.info(
                "Loaded %d analytical tables (%d system tables blocklisted)",
                len(self._infos), len(all_infos) - len(self._infos),
            )

            for ti in self._infos:
                self._texts[ti.name]  = self._describe(ti)
                self._fk_out[ti.name] = {fk.ref_table for fk in ti.foreign_keys}

            self._try_embed()
            self._ready = True

    def _describe(self, ti: TableInfo) -> str:
        """Rich embedding text: YAML description + aliases + column names + FK targets."""
        meta = self._descriptions.get(ti.name, {})

        parts: list[str] = [ti.name.replace("_", " ")]

        # 1. Human description (most informative — weighted by appearing first)
        if desc := meta.get("description", ""):
            parts.append(desc.strip())

        # 2. Aliases / French synonyms
        if aliases := meta.get("aliases", ""):
            parts.append(aliases.strip())

        # 3. Column names (structural signal)
        for col in ti.columns:
            parts.append(col.name.replace("_", " "))

        # 4. FK relationships
        for fk in ti.foreign_keys:
            parts.append(f"related to {fk.ref_table.replace('_', ' ')}")

        return " ".join(parts)

    def _try_embed(self) -> None:
        model_name = settings.OLLAMA_EMBEDDING_MODEL or settings.OLLAMA_MODEL
        texts  = [self._texts[ti.name] for ti in self._infos]
        names  = [ti.name for ti in self._infos]
        try:
            from langchain_ollama import OllamaEmbeddings
            self._embed_model = OllamaEmbeddings(
                model=model_name, base_url=settings.OLLAMA_BASE_URL
            )
            vecs = self._embed_model.embed_documents(texts)
            for name, vec in zip(names, vecs):
                self._vecs[name] = np.array(vec, dtype=np.float32)
            log.info("Embedded %d tables with '%s'", len(self._vecs), model_name)
        except Exception as exc:
            log.warning("Embedding unavailable (%s) — keyword fallback active", exc)
            self._embed_model = None

    # ------------------------------------------------------------------
    # Retrieve
    # ------------------------------------------------------------------

    def _name_boost(self, question: str, table_name: str) -> float:
        """Boost score when question words appear as substrings in the table name parts."""
        q_lower = question.lower()
        parts = table_name.lower().split("_")
        return sum(0.35 for p in parts if len(p) > 3 and p in q_lower)

    def _domain_hint_tables(self, question: str) -> set[str]:
        """Return table names forced by domain keyword matches."""
        q_lower = question.lower()
        forced: set[str] = set()
        for keyword, tables in _DOMAIN_HINTS.items():
            if keyword in q_lower:
                forced.update(tables)
        return forced

    def retrieve(self, question: str, top_k: int = _TOP_K_DEFAULT) -> RetrievedSchema:
        if not self._ready:
            self.build()

        names  = [ti.name for ti in self._infos]
        ti_map = {ti.name: ti for ti in self._infos}

        if self._vecs:
            scores = self._embedding_scores(question, names)
        else:
            scores = self._keyword_scores(question, names)

        # Apply name-part boost on top of embedding/keyword scores
        for name in names:
            scores[name] = scores.get(name, 0.0) + self._name_boost(question, name)

        # Force-include domain-hinted tables (pin their score above threshold)
        hinted = self._domain_hint_tables(question)
        known_hinted = hinted & {ti.name for ti in self._infos}
        for name in known_hinted:
            scores[name] = max(scores.get(name, 0.0), 0.9)

        ranked  = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        top_set = {n for n, _ in ranked[:top_k]}
        # Always include hinted tables in top_set (may push past top_k)
        top_set |= known_hinted

        # 1-hop FK expansion: include tables that top tables reference
        expanded: set[str] = set(top_set)
        for tname in top_set:
            expanded |= self._fk_out.get(tname, set())
        # Hard cap to avoid ballooning the context
        if len(expanded) > _MAX_EXPANDED:
            # Keep top_set intact, trim FK additions by score
            fk_only = expanded - top_set
            ranked_fk = sorted(fk_only, key=lambda n: scores.get(n, 0), reverse=True)
            expanded = top_set | set(ranked_fk[: _MAX_EXPANDED - len(top_set)])

        # Preserve rank order
        ordered  = [n for n, _ in ranked if n in expanded]
        ordered += [n for n in expanded if n not in {x for x, _ in ranked}]

        selected = [ti_map[n] for n in ordered if n in ti_map]

        log.info(
            "Retrieved %d/%d tables for question '%s': %s",
            len(selected), len(self._infos),
            question[:60],
            [t.name for t in selected],
        )

        schema_text = _format_schema(selected)
        return RetrievedSchema(
            tables=selected,
            schema_text=schema_text,
            allowed_tables={ti.name for ti in selected},
        )

    def _embedding_scores(self, question: str, names: list[str]) -> dict[str, float]:
        try:
            q_vec = np.array(
                self._embed_model.embed_query(question), dtype=np.float32
            )
            out: dict[str, float] = {}
            for name in names:
                if name not in self._vecs:
                    out[name] = 0.0
                    continue
                v = self._vecs[name]
                out[name] = float(
                    np.dot(q_vec, v) / (np.linalg.norm(q_vec) * np.linalg.norm(v) + 1e-8)
                )
            return out
        except Exception as exc:
            log.warning("Embedding query failed (%s) — falling back to keywords", exc)
            return self._keyword_scores(question, names)

    def _keyword_scores(self, question: str, names: list[str]) -> dict[str, float]:
        q_words = set(question.lower().split())
        ti_map  = {ti.name: ti for ti in self._infos}
        out: dict[str, float] = {}
        for name in names:
            ti = ti_map.get(name)
            if not ti:
                out[name] = 0.0
                continue
            t_words: set[str] = set()
            for part in name.split("_"):
                t_words.add(part.lower())
            for col in ti.columns:
                for part in col.name.split("_"):
                    t_words.add(part.lower())
            out[name] = len(q_words & t_words) / (len(q_words) + 1)
        return out

    def invalidate(self) -> None:
        """Force full rebuild on next call (e.g., after schema migration)."""
        with self._lock:
            self._ready = False
            self._vecs.clear()
            self._infos.clear()
            self._texts.clear()
            self._embed_model = None


# ---------------------------------------------------------------------------
# Schema text formatter
# ---------------------------------------------------------------------------

def _format_schema(tables: list[TableInfo]) -> str:
    lines: list[str] = []
    for ti in tables:
        row_hint = f"  (~{ti.row_count_estimate:,} rows)" if ti.row_count_estimate else ""
        lines.append(f"Table: {ti.name}{row_hint}")
        for col in ti.columns:
            pk = " [PK]" if col.is_pk else ""
            nn = " NOT NULL" if not col.nullable else ""
            lines.append(f"  {col.name}: {col.data_type}{pk}{nn}")
        for fk in ti.foreign_keys:
            lines.append(f"  FK: {fk.column} -> {fk.ref_table}.{fk.ref_column}")
        lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Module-level singleton
# ---------------------------------------------------------------------------

_retriever: SchemaRetriever | None = None


def get_schema_retriever() -> SchemaRetriever:
    global _retriever
    if _retriever is None:
        _retriever = SchemaRetriever()
    return _retriever
