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

import numpy as np

from app.config.settings import settings
from app.db.schema_inspector import TableInfo, inspect_schema

log = logging.getLogger("tbg.retriever")

_TOP_K_DEFAULT = 4          # direct-match tables before FK expansion
_MAX_EXPANDED  = 8          # hard cap after FK expansion


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

class SchemaRetriever:
    """Thread-safe singleton.  Call build() once; retrieve() is thread-safe."""

    def __init__(self) -> None:
        self._lock   = threading.Lock()
        self._ready  = False
        self._infos:  list[TableInfo]          = []
        self._texts:  dict[str, str]           = {}   # name → description
        self._vecs:   dict[str, np.ndarray]    = {}   # name → embedding vector
        self._fk_out: dict[str, set[str]]      = {}   # name → {ref_table, …}
        self._embed_model = None

    # ------------------------------------------------------------------
    # Build (called once)
    # ------------------------------------------------------------------

    def build(self) -> None:
        with self._lock:
            if self._ready:
                return
            log.info("SchemaRetriever.build() — loading schema from DB …")
            self._infos = inspect_schema()
            log.info("Loaded %d tables", len(self._infos))

            for ti in self._infos:
                self._texts[ti.name]  = self._describe(ti)
                self._fk_out[ti.name] = {fk.ref_table for fk in ti.foreign_keys}

            self._try_embed()
            self._ready = True

    def _describe(self, ti: TableInfo) -> str:
        """Compact text for embedding — name + column tokens + FK targets."""
        tokens = [ti.name.replace("_", " ")]
        for col in ti.columns:
            tokens.append(col.name.replace("_", " "))
        for fk in ti.foreign_keys:
            tokens.append(f"related to {fk.ref_table.replace('_', ' ')}")
        return " ".join(tokens)

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

    def retrieve(self, question: str, top_k: int = _TOP_K_DEFAULT) -> RetrievedSchema:
        if not self._ready:
            self.build()

        names = [ti.name for ti in self._infos]

        if self._vecs:
            scores = self._embedding_scores(question, names)
        else:
            scores = self._keyword_scores(question, names)

        ranked  = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        top_set = {n for n, _ in ranked[:top_k]}

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

        ti_map   = {ti.name: ti for ti in self._infos}
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
