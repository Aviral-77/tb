"""
LangGraph agents for the Digiwise AI Copilot.

DB pipeline:
  0. retrieve_schema    — RAG: pick 2–4 relevant tables from embeddings
  1. write_sql          — Writer LLM generates SQL (strict: ONLY SQL output)
  2. validate_syntax    — sqlglot checks syntax (no LLM, no DB)
  3. validate_tables    — whitelist check: blocks hallucinated table names
  4. validate_semantic  — EXPLAIN checks real table/col names against DB
  4. critique_sql       — Critic LLM repairs SQL with full error history
     └── loops back to validate_syntax (max _MAX_RETRIES times)
  5. execute_sql        — runs the validated SQL
  6. format_answer      — formats rows into natural language (no SQL leaked)

All nodes emit INFO/WARNING/ERROR log lines for full traceability.
On retry exhaustion the pipeline returns a structured SQL_GENERATION_FAILED error.
"""
from __future__ import annotations

import json
import logging
import os
import re
import textwrap
import time
from pathlib import Path
from typing import Iterator, TypedDict

import sqlglot
import sqlglot.expressions as sexp
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_ollama import ChatOllama
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import END, StateGraph
from langgraph.prebuilt import create_react_agent

from app.agents.db_tools import build_db_tools
from app.agents.tools import build_tools
from app.config.settings import settings
from app.db.connection import execute, explain

_THRESHOLDS_PATH     = Path(__file__).parent.parent / "thresholds.json"
_FINANCIAL_TERMS_PATH = Path(__file__).resolve().parents[2] / "financial_terms.json"
_DEFAULT_EXCEL_PATH  = Path(__file__).resolve().parents[2] / "TBG Moov_Africa_Bénin DEC 2025 DF SANS LIEN.xlsx"

# ---------------------------------------------------------------------------
# Logger
# ---------------------------------------------------------------------------

log = logging.getLogger("tbg.pipeline")
if not log.handlers:
    _h = logging.StreamHandler()
    _h.setFormatter(logging.Formatter(
        "%(asctime)s  %(levelname)-7s  [%(name)s]  %(message)s",
        datefmt="%H:%M:%S",
    ))
    log.addHandler(_h)
log.setLevel(logging.DEBUG)


def _clip(text: str, n: int = 140) -> str:
    text = text.replace("\n", " ")
    return text if len(text) <= n else text[:n] + "…"


# ---------------------------------------------------------------------------
# Shared LLM factory
# ---------------------------------------------------------------------------
from ollama import Client

class OllamaLLM:
    """Wrapper for Ollama client that implements invoke() interface for LangGraph."""
    def __init__(self, client: Client, model: str):
        self.client = client
        self.model = model
        self.tools = None

    def bind_tools(self, tools, **kwargs):
        """Allow LangGraph to attach tools to the model."""
        self.tools = tools
        return self

    def invoke(self, messages):
        """Convert LangChain or raw messages to Ollama format and get response."""
        msgs = []
        for m in messages:
            if isinstance(m, SystemMessage):
                role, content = "system", m.content
            elif isinstance(m, HumanMessage):
                role, content = "user", m.content
            elif isinstance(m, str):
                role, content = "user", m
            elif isinstance(m, dict):
                role = m.get("role", "user")
                content = m.get("content") or m.get("text") or ""
            elif hasattr(m, "content"):
                role = getattr(m, "role", "user")
                content = m.content
            else:
                raise ValueError(f"Unsupported message type: {type(m)}")

            if not content:
                continue
            msgs.append({"role": role, "content": content})

        try:
            response = self.client.chat(
                model=self.model,
                messages=msgs,
            )
            content = response.get('message', {}).get('content', '')
            if not content:
                raise ValueError("Empty response from Ollama API")
            return HumanMessage(content=content)
        except Exception as e:
            log.error("Ollama API call failed: %s", str(e))
            raise

    def __call__(self, messages, *args, **kwargs):
        return self.invoke(messages)

    def stream_tokens(self, messages) -> Iterator[str]:
        """Stream response tokens from Ollama."""
        msgs = []
        for m in messages:
            if isinstance(m, SystemMessage):
                role, content = "system", m.content
            elif isinstance(m, HumanMessage):
                role, content = "user", m.content
            elif isinstance(m, str):
                role, content = "user", m
            elif isinstance(m, dict):
                role = m.get("role", "user")
                content = m.get("content") or m.get("text") or ""
            elif hasattr(m, "content"):
                role = getattr(m, "role", "user")
                content = m.content
            else:
                continue
            if content:
                msgs.append({"role": role, "content": content})
        try:
            for chunk in self.client.chat(model=self.model, messages=msgs, stream=True):
                token = chunk.get('message', {}).get('content', '')
                if token:
                    yield token
        except Exception as e:
            log.error("Ollama stream failed: %s", str(e))
            raise


_OLLAMA_TIMEOUT = 100  # seconds — stay under Cloudflare's 120 s proxy timeout


def _make_llm(model: str | None = None) -> OllamaLLM:
    """Create Ollama client for local or cloud Ollama."""
    resolved = model or settings.OLLAMA_MODEL
    if settings.is_ollama_cloud:
        headers = {"Authorization": f"Bearer {settings.OLLAMA_API_KEY}"}
        client = Client(host=settings.OLLAMA_BASE_URL, headers=headers, timeout=_OLLAMA_TIMEOUT)
        log.info("LLM initialized — API: OLLAMA CLOUD | model: %s | timeout: %ds", resolved, _OLLAMA_TIMEOUT)
    else:
        client = Client(host=settings.OLLAMA_BASE_URL, timeout=_OLLAMA_TIMEOUT)
        log.info("LLM initialized — API: LOCAL OLLAMA | model: %s | base_url: %s", resolved, settings.OLLAMA_BASE_URL)
    return OllamaLLM(client, resolved)


# ---------------------------------------------------------------------------
# File-upload session graph (unchanged)
# ---------------------------------------------------------------------------

_graph_cache: dict[str, object] = {}


def _load_thresholds() -> dict:
    with open(_THRESHOLDS_PATH) as f:
        return json.load(f)


def _build_system_prompt(parsed_data: dict) -> str:
    sheets     = list(parsed_data.get("sheets", {}).keys())
    periods    = parsed_data.get("all_periods", [])
    period_range = f"{periods[0]} to {periods[-1]}" if periods else "unknown"
    file_name  = parsed_data.get("file", "uploaded file")
    return f"""You are the TBG AI Copilot — an expert financial analyst assistant for Moov Benin.

You have access to data parsed from the TBG report: {file_name}
Available sheets: {', '.join(sheets)}
Available periods: {period_range}

Rules:
- Always use tools to retrieve real data; do NOT invent numbers.
- For monetary values: thousands separators, one decimal place, unit M CFA.
- For percentages: always show the sign (+/-).
- After answering, offer the next logical follow-up question.
"""


def get_or_create_graph(session_id: str, parsed_data: dict, model: str | None = None):
    key = f"{session_id}:{model or settings.OLLAMA_MODEL}"
    if key in _graph_cache:
        return _graph_cache[key]
    thresholds = _load_thresholds()
    tools      = build_tools(parsed_data, thresholds)
    llm        = _make_llm(model)
    graph = create_react_agent(
        model=llm,
        tools=tools,
        prompt=SystemMessage(content=_build_system_prompt(parsed_data)),
        checkpointer=MemorySaver(),
    )
    _graph_cache[key] = graph
    return graph


# ---------------------------------------------------------------------------
# DB pipeline state
# ---------------------------------------------------------------------------

class DbPipelineState(TypedDict):
    question:         str
    history:          str
    language:         str          # "en" or "fr" — controls answer language
    # RAG output
    retrieved_schema: str          # compact schema for relevant tables only
    allowed_tables:   list[str]    # whitelist — blocks hallucinated table names
    # SQL under construction
    sql:              str
    # Validation errors (one set at a time)
    syntax_error:     str          # from sqlglot
    table_error:      str          # table not in whitelist
    semantic_error:   str          # from EXPLAIN
    # Repair loop
    error_history:    list[str]    # accumulated across all retries
    column_facts:     str          # verified columns for tables in SQL (injected on semantic fail)
    critic_feedback:  str
    retry_count:      int
    # Execution
    sql_error:        str
    rows:             list[dict]
    cols:             list[str]
    answer:           str
    chart_specs:      list[dict]


_MAX_RETRIES = 3      # writer attempt + up to 3 critic repairs = 4 total SQL generations


# ---------------------------------------------------------------------------
# SQL extraction — strict SELECT/WITH guard
# ---------------------------------------------------------------------------

_SQL_FENCE_RE = re.compile(r"```(?:sql)?\s*([\s\S]*?)```", re.IGNORECASE)
_SQL_BARE_RE  = re.compile(
    r"((?:SELECT|WITH)\b[\s\S]*?)(?:;|\Z)",
    re.IGNORECASE,
)


def _extract_sql(raw: str) -> tuple[str, str]:
    """
    Returns (sql, error).
    Strips markdown fences and prose; validates the result starts with SELECT/WITH.
    """
    # 1. Try fenced block first
    m = _SQL_FENCE_RE.search(raw)
    if m:
        sql = m.group(1).strip().rstrip(";")
    else:
        # 2. Find first SELECT/WITH … to end-of-string or first semicolon
        m2 = _SQL_BARE_RE.search(raw)
        sql = m2.group(1).strip().rstrip(";") if m2 else raw.strip().rstrip(";")

    upper = sql.lstrip().upper()
    if not (upper.startswith("SELECT") or upper.startswith("WITH")):
        snippet = _clip(raw, 120)
        return "", f"LLM output does not start with SELECT or WITH. Raw: {snippet!r}"
    
    log.debug("_extract_sql: extracted %d chars from %d char input", len(sql), len(raw))
    return sql, ""


# ---------------------------------------------------------------------------
# Node 0 — Retrieve schema (RAG)
# ---------------------------------------------------------------------------

def retrieve_schema(state: DbPipelineState) -> dict:
    from app.agents.schema_retriever import get_schema_retriever
    question = state["question"]
    try:
        retriever = get_schema_retriever()
        result    = retriever.retrieve(question)
        log.info(
            "retrieve_schema: %d tables selected (%d chars) — %s",
            len(result.tables), len(result.schema_text),
            [t.name for t in result.tables],
        )
        return {
            "retrieved_schema": result.schema_text,
            "allowed_tables":   sorted(result.allowed_tables),
        }
    except Exception as exc:
        log.error("retrieve_schema failed: %s — falling back to full schema", exc)
        try:
            from app.db.schema_inspector import build_schema_context, get_tables
            schema     = build_schema_context()
            all_tables = get_tables()
            log.info("Fallback full schema: %d tables", len(all_tables))
            return {"retrieved_schema": schema, "allowed_tables": all_tables}
        except Exception as exc2:
            log.error("Full schema fallback also failed: %s", exc2)
            return {"retrieved_schema": "(schema unavailable)", "allowed_tables": []}


# ---------------------------------------------------------------------------
# Node 1 — Writer LLM: generate SQL
# ---------------------------------------------------------------------------

_WRITER_SYSTEM = """\
You are a PostgreSQL 15 expert connected to a financial database for Moov Benin.

╔══ OUTPUT FORMAT — STRICTLY ENFORCED ══╗
║  Output ONLY a raw SQL SELECT statement  ║
║  • First token must be SELECT or WITH     ║
║  • Last character must be ;               ║
║  • ZERO prose, ZERO comments, ZERO markdown ║
║  Any text outside the SQL = REJECTED       ║
╚═══════════════════════════════════════════╝

COLUMN ALIAS RULE (mandatory):
  Every computed expression MUST have an AS alias so column headers are readable.
  ✓  SUM(jan + feb + mar) AS q1_total
  ✓  ROUND(real_value / budget_value * 100, 2) AS pct_budget
  ✓  prodium + linarcels + easycom AS total_commission
  ✗  SUM(jan + feb)          ← produces ugly "?column?" header — FORBIDDEN

CRITICAL — TWO TABLE STRUCTURES EXIST:

DENORMALIZED TABLES (months stored as separate columns):
  • cashflow_data: columns are [year, jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec, current_year_total]
    ✓ Query: SELECT SUM(jan)+SUM(feb)+SUM(mar)... FROM cashflow_data WHERE year=2024
    ✗ Do NOT use: EXTRACT(), date column, month column (they don't exist)

  • commission_enlevements: DISTRIBUTORS ARE COLUMNS, NOT ROWS.
    Columns: [year, month, prodium, linarcels, easycom, somac, d_commercial, aftel, senaniminde]
    ✗ WRONG — causes "must appear in GROUP BY" error:
        SELECT distributor, SUM(amount) FROM commission_enlevements GROUP BY distributor
    ✓ CORRECT — use UNION ALL to unpivot distributors into rows, then rank:
        WITH totals AS (
            SELECT 'Prodium'      AS distributor, SUM(prodium)      AS total FROM commission_enlevements WHERE year = 2025
            UNION ALL
            SELECT 'Linarcels',                   SUM(linarcels)             FROM commission_enlevements WHERE year = 2025
            UNION ALL
            SELECT 'Easycom',                     SUM(easycom)               FROM commission_enlevements WHERE year = 2025
            UNION ALL
            SELECT 'Somac',                       SUM(somac)                 FROM commission_enlevements WHERE year = 2025
            UNION ALL
            SELECT 'D-Commercial',                SUM(d_commercial)          FROM commission_enlevements WHERE year = 2025
            UNION ALL
            SELECT 'Aftel',                       SUM(aftel)                 FROM commission_enlevements WHERE year = 2025
            UNION ALL
            SELECT 'Senaniminde',                 SUM(senaniminde)           FROM commission_enlevements WHERE year = 2025
        )
        SELECT distributor, total AS total_commission
        FROM totals
        WHERE total IS NOT NULL
        ORDER BY total DESC
        LIMIT 5;

NORMALIZED TABLES (date column):
  • financial_metrics_data: has [date, real_value, budget_value, financial_metric_id, financial_submetric_id]
    ✓ Query: WHERE EXTRACT(YEAR FROM date)=2025 AND real_value IS NOT NULL
  • capex_data: has [year, month, equipment, services, additional_costs, capex_projects_id]
    ✓ Query: WHERE year=2025 AND month=9, GROUP BY month

BEFORE WRITING SQL:
  1. Identify which table(s) you'll query
  2. Check if it's denormalized (monthly columns) or normalized (date column)
  3. Use appropriate filter syntax:
     - Denormalized: WHERE year = 2024 (direct comparison)
     - Normalized: WHERE EXTRACT(YEAR FROM date) = 2024 (date extraction)

POSTGRESQL RULES:
  ✗ MONTH() YEAR() ISNULL() IFNULL()   ← MySQL functions — FORBIDDEN
  ✗ backtick quoting                    ← use double-quotes only
  ✗ CONCAT() with 2 args                ← use || operator
  ✓ NULLIF(col, 0) to prevent division by zero
  ✓ COALESCE(col, 0) for NULL handling

NULL HANDLING:
  • Aggregations: Always add WHERE value IS NOT NULL to avoid NULL results
  • Variance: Use NULLIF(ABS(budget), 0) to guard against division by zero
  • Comparisons: Always check both real_value and budget_value are NOT NULL

REVENUE / KPI HIERARCHY — use this for ANY question about revenue, ARPU, EBITDA, budgets, categories:
  financial_categories   ← top-level groupings (CA Mobile, Data Mobile, Mobile Money, Capex, etc.)
       └── financial_types     ← report sections within each category
             └── financial_metric   ← individual KPI metric names
                   └── financial_metrics_data   ← monthly values: real_value, budget_value, last_year_real_value

  Categories in the DB: 'CA Mobile', 'Data Mobile', 'Mobile Money', 'Parc Mobile',
                        'Capex Consolidés', 'Cash Conso', 'P&L conso', 'Opex Consolidés',
                        'Marge brute Mobile', 'Trafic mobile', 'Indicateurs Mobile'

  ✓ Revenue by category 2024 (always join via financial_metric):
    SELECT fc.name AS category, SUM(fmd.real_value) AS total
    FROM financial_metrics_data fmd
    JOIN financial_metric fm  ON fm.id  = fmd.financial_metric_id
    JOIN financial_types ft   ON ft.id  = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE EXTRACT(YEAR FROM fmd.date) = 2024 AND fmd.real_value IS NOT NULL
    GROUP BY fc.name ORDER BY total DESC;

  ✗ NEVER use cashflow_data for revenue questions — cashflow_data stores treasury cash flow,
    NOT operational revenue. "Category" in a revenue question means financial_categories, not cashflow_categories.

CAPEX HIERARCHY — for questions about CAPEX suppliers, projects, spend by month:
  capex_projects: id [PK], supplier_name, direction_name, project_title, contract_no
  capex_data:     id [PK], capex_projects_id (FK → capex_projects.id), month, year,
                  equipment, services, additional_costs

  ✓ Monthly trend (total spend per month — NO supplier breakdown):
    SELECT cd.month,
           SUM(COALESCE(cd.equipment,0) + COALESCE(cd.services,0) + COALESCE(cd.additional_costs,0)) AS total_capex
    FROM capex_data cd
    WHERE cd.year = 2025
    GROUP BY cd.month
    ORDER BY cd.month;

  ✓ Suppliers for a specific month (requires JOIN to capex_projects):
    SELECT cp.supplier_name,
           SUM(cd.equipment + cd.services + cd.additional_costs) AS total_spend
    FROM capex_data cd
    JOIN capex_projects cp ON cp.id = cd.capex_projects_id
    WHERE cd.year = 2025 AND cd.month = 9
      AND (cd.equipment + cd.services + cd.additional_costs) > 0
    GROUP BY cp.supplier_name
    ORDER BY total_spend DESC;

  ✓ Supplier spend breakdown by cost type (equipment vs services vs additional_costs):
    SELECT SUM(COALESCE(cd.equipment,0))         AS equipment_spend,
           SUM(COALESCE(cd.services,0))          AS services_spend,
           SUM(COALESCE(cd.additional_costs,0))  AS additional_costs_spend,
           SUM(COALESCE(cd.equipment,0)+COALESCE(cd.services,0)+COALESCE(cd.additional_costs,0)) AS total_spend,
           ROUND(SUM(COALESCE(cd.equipment,0)) * 100.0
                 / NULLIF(SUM(COALESCE(cd.equipment,0)+COALESCE(cd.services,0)+COALESCE(cd.additional_costs,0)),0), 2)
                 AS equipment_pct
    FROM capex_data cd
    JOIN capex_projects cp ON cp.id = cd.capex_projects_id
    WHERE UPPER(cp.supplier_name) LIKE '%ERICSSON%';

  SUPPLIER NAME RULES:
    ✓ Always use UPPER(cp.supplier_name) LIKE '%NAME%' for fuzzy supplier matching
      (supplier names have variants: 'ERICSSON AB', 'ERICSSON BENIN', etc.)
    ✗ Never use exact equality cp.supplier_name = 'X' — variants will be missed

  CAPEX COST TYPES (columns in capex_data):
    equipment        = hardware / network infrastructure purchases
    services         = implementation, installation, maintenance services
    additional_costs = other project costs (transport, duties, etc.)

  ✗ NEVER mix supplier columns into a monthly trend query — if the question
    asks "monthly trend" or "per month", GROUP BY cd.month only, no JOIN needed.
  ✗ NEVER reference capex_projects columns without the JOIN above.

CASH FLOW HIERARCHY — use ONLY for questions about flux de trésorerie / treasury / liquidity:
  realised_cashflow → cashflow_sections → cashflow_categories → cashflow_subcategories
  Data in cashflow_data: [year, jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]
  Each row's entity_type is 'section', 'category', or 'subcategory'.

JOIN PATH RULE — CRITICAL:
  financial_metrics_data has TWO foreign keys:
    fmd.financial_metric_id  → financial_metric.id       (ALWAYS populated)
    fmd.financial_type_id    → financial_types.id        (sometimes NULL — do NOT rely on it)

  When filtering by metric name (fm.name) or category name (fc.name), ALWAYS use:
    JOIN financial_metric fm  ON fm.id  = fmd.financial_metric_id   ← join data → metric
    JOIN financial_types ft   ON ft.id  = fm.financial_type_id      ← join metric → type  (NOT fmd.financial_type_id)
    JOIN financial_categories fc ON fc.id = ft.financial_category_id

  ✗ WRONG (fmd.financial_type_id is NULL for many metrics → returns 0 rows):
      JOIN financial_types ft ON ft.id = fmd.financial_type_id
  ✓ CORRECT:
      JOIN financial_metric fm ON fm.id = fmd.financial_metric_id
      JOIN financial_types ft  ON ft.id = fm.financial_type_id

MARGINS / PROFITABILITY QUERIES:
  "Business segments" = financial_categories (CA Mobile, Data Mobile, Mobile Money, P&L conso, etc.)
  There is NO single "margins" column — margins are stored as named metrics inside financial_metrics_data.

  Available margin metrics (financial_metric.name):
    '% CA'                — net margin % of revenue             (category='P&L conso',     type='RESULTAT NET')
    '% Marge Brute/CA'    — MoMo gross margin %                 (category='Mobile Money',   type='Marge Brute (en monnaie locale)')
    'Marge Brute'         — absolute gross margin in FCFA        (category='P&L conso',     type="Chiffre d'affaires")
    'EBITDA'              — EBITDA in FCFA                       (category='P&L conso',     type="Chiffre d'affaires")
    'EBITA'               — EBITA in FCFA                        (category='P&L conso',     type="Chiffre d'affaires")

  ✓ Compare available margin % metrics across segments (use fm.financial_type_id, NOT fmd):
    SELECT fc.name AS segment, fm.name AS margin_type,
           ROUND(AVG(fmd.real_value)::numeric, 2) AS avg_margin_pct
    FROM financial_metrics_data fmd
    JOIN financial_metric fm  ON fm.id  = fmd.financial_metric_id
    JOIN financial_types ft   ON ft.id  = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE fm.name IN ('% CA', '% Marge Brute/CA')
      AND EXTRACT(YEAR FROM fmd.date) = 2024
      AND fmd.real_value IS NOT NULL
    GROUP BY fc.name, fm.name
    ORDER BY avg_margin_pct DESC;

  ✓ P&L summary (revenue, gross margin, EBITDA, net result) for a year:
    SELECT fm.name AS kpi,
           ROUND(SUM(fmd.real_value)::numeric, 0) AS total_fcfa
    FROM financial_metrics_data fmd
    JOIN financial_metric fm  ON fm.id  = fmd.financial_metric_id
    JOIN financial_types ft   ON ft.id  = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE fc.name = 'P&L conso'
      AND fm.name IN ('Mobile', 'Marge Brute', 'EBITDA', 'RESULTAT NET')
      AND EXTRACT(YEAR FROM fmd.date) = 2024
      AND fmd.real_value IS NOT NULL
    GROUP BY fm.name
    ORDER BY total_fcfa DESC;

  ✗ Do NOT invent a "margin" column — it does not exist. Always JOIN to financial_metric.name.
  ✗ Do NOT use fc.name = 'Marge brute Mobile' for margin % — that category stores costs, not %.

SUBSCRIBER & TRAFFIC METRICS — for questions about subscribers, churn, ARPU, MoU, traffic, parc:
  Categories: 'Parc Mobile', 'Trafic mobile', 'Indicateurs Mobile', 'CA Mobile', 'Data Mobile'
  All stored in financial_metrics_data — same JOIN path as revenue queries.

  ✓ Monthly subscriber base trend:
    SELECT EXTRACT(MONTH FROM fmd.date)::int AS month,
           SUM(fmd.real_value) AS total_subscribers
    FROM financial_metrics_data fmd
    JOIN financial_metric fm ON fm.id = fmd.financial_metric_id
    JOIN financial_types ft   ON ft.id = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE fc.name = 'Parc Mobile'
      AND EXTRACT(YEAR FROM fmd.date) = 2025
      AND fmd.real_value IS NOT NULL
    GROUP BY EXTRACT(MONTH FROM fmd.date)
    ORDER BY month;

  ✓ ARPU monthly trend (fuzzy match on metric name):
    SELECT EXTRACT(MONTH FROM fmd.date)::int AS month,
           ROUND(AVG(fmd.real_value)::numeric, 2) AS avg_arpu
    FROM financial_metrics_data fmd
    JOIN financial_metric fm ON fm.id = fmd.financial_metric_id
    WHERE UPPER(fm.name) LIKE '%ARPU%'
      AND EXTRACT(YEAR FROM fmd.date) = 2025
      AND fmd.real_value IS NOT NULL
    GROUP BY EXTRACT(MONTH FROM fmd.date) ORDER BY month;

  ✓ List all available metric names in a category (for exploration):
    SELECT DISTINCT fm.name AS metric, ft.name AS type
    FROM financial_metric fm
    JOIN financial_types ft ON ft.id = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE fc.name = 'Indicateurs Mobile'
    ORDER BY ft.name, fm.name;

BUDGET vs ACTUAL VARIANCE — for questions about budget, forecast, écart, vs target, over/under:
  Use: real_value (actual), budget_value (plan/budget). Guard division with NULLIF(budget_value, 0).

  ✓ Variance by metric for a year (over/under budget):
    SELECT fm.name AS metric,
           ROUND(SUM(fmd.real_value)::numeric, 0)      AS actual,
           ROUND(SUM(fmd.budget_value)::numeric, 0)    AS budget,
           ROUND((SUM(fmd.real_value) - SUM(fmd.budget_value))::numeric, 0) AS variance,
           ROUND((SUM(fmd.real_value) - SUM(fmd.budget_value)) * 100.0
                 / NULLIF(ABS(SUM(fmd.budget_value)), 0), 2)               AS variance_pct
    FROM financial_metrics_data fmd
    JOIN financial_metric fm  ON fm.id  = fmd.financial_metric_id
    JOIN financial_types ft   ON ft.id  = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE fc.name = 'P&L conso'
      AND EXTRACT(YEAR FROM fmd.date) = 2025
      AND fmd.real_value IS NOT NULL AND fmd.budget_value IS NOT NULL
    GROUP BY fm.name ORDER BY variance_pct DESC;

  ✓ Monthly actual vs budget for a single metric:
    SELECT EXTRACT(MONTH FROM fmd.date)::int AS month,
           ROUND(SUM(fmd.real_value)::numeric, 0)   AS actual,
           ROUND(SUM(fmd.budget_value)::numeric, 0) AS budget
    FROM financial_metrics_data fmd
    JOIN financial_metric fm ON fm.id = fmd.financial_metric_id
    WHERE fm.name = 'EBITDA'
      AND EXTRACT(YEAR FROM fmd.date) = 2025
      AND fmd.real_value IS NOT NULL AND fmd.budget_value IS NOT NULL
    GROUP BY EXTRACT(MONTH FROM fmd.date) ORDER BY month;

YEAR-ON-YEAR (YoY) COMPARISON — for questions about growth, YoY, vs last year, evolution, year-over-year:
  Use last_year_real_value for the prior-year figure. Do NOT query two separate years.

  ✓ YoY comparison for key P&L metrics:
    SELECT fm.name AS metric,
           ROUND(SUM(fmd.last_year_real_value)::numeric, 0) AS prior_year,
           ROUND(SUM(fmd.real_value)::numeric, 0)           AS current_year,
           ROUND((SUM(fmd.real_value) - SUM(fmd.last_year_real_value)) * 100.0
                 / NULLIF(ABS(SUM(fmd.last_year_real_value)), 0), 2)       AS yoy_pct
    FROM financial_metrics_data fmd
    JOIN financial_metric fm  ON fm.id  = fmd.financial_metric_id
    JOIN financial_types ft   ON ft.id  = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE fc.name = 'P&L conso'
      AND fm.name IN ('Mobile', 'EBITDA', 'RESULTAT NET')
      AND EXTRACT(YEAR FROM fmd.date) = 2025
      AND fmd.real_value IS NOT NULL AND fmd.last_year_real_value IS NOT NULL
    GROUP BY fm.name ORDER BY current_year DESC;

  ✓ YoY monthly trend for a single metric:
    SELECT EXTRACT(MONTH FROM fmd.date)::int AS month,
           ROUND(SUM(fmd.last_year_real_value)::numeric, 0) AS prior_year,
           ROUND(SUM(fmd.real_value)::numeric, 0)           AS current_year
    FROM financial_metrics_data fmd
    JOIN financial_metric fm ON fm.id = fmd.financial_metric_id
    WHERE UPPER(fm.name) LIKE '%EBITDA%'
      AND EXTRACT(YEAR FROM fmd.date) = 2025
      AND fmd.real_value IS NOT NULL AND fmd.last_year_real_value IS NOT NULL
    GROUP BY EXTRACT(MONTH FROM fmd.date) ORDER BY month;

OPEX QUERIES — for questions about operating expenses, charges, coûts opérationnels:
  Category: 'Opex Consolidés'. Same JOIN path as revenue.

  ✓ OpEx breakdown by type for a year:
    SELECT ft.name AS opex_type,
           ROUND(SUM(fmd.real_value)::numeric, 0)   AS actual,
           ROUND(SUM(fmd.budget_value)::numeric, 0) AS budget
    FROM financial_metrics_data fmd
    JOIN financial_metric fm  ON fm.id  = fmd.financial_metric_id
    JOIN financial_types ft   ON ft.id  = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE fc.name = 'Opex Consolidés'
      AND EXTRACT(YEAR FROM fmd.date) = 2025
      AND fmd.real_value IS NOT NULL
    GROUP BY ft.name ORDER BY actual DESC;

  ✓ Monthly OpEx trend:
    SELECT EXTRACT(MONTH FROM fmd.date)::int AS month,
           ROUND(SUM(fmd.real_value)::numeric, 0) AS total_opex
    FROM financial_metrics_data fmd
    JOIN financial_metric fm  ON fm.id  = fmd.financial_metric_id
    JOIN financial_types ft   ON ft.id  = fm.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE fc.name = 'Opex Consolidés'
      AND EXTRACT(YEAR FROM fmd.date) = 2025
      AND fmd.real_value IS NOT NULL
    GROUP BY EXTRACT(MONTH FROM fmd.date) ORDER BY month;

CASH FLOW QUERIES — for questions about cash flow, trésorerie, FCF, liquidity, flux, cash position:

  UNIT: cashflow_data values are in MILLIONS of FCFA (M CFA).

  VERSION FILTER (CRITICAL for 2025 and 2026 data):
    The table stores multiple upload versions per year. ALWAYS filter with:
      AND cd.version_id = (SELECT MAX(version_id) FROM cashflow_data WHERE year = <year>)
    For year 2024: version_id IS NULL — use: AND cd.version_id IS NULL

  CORRUPTED VALUES: Some monthly cells for 2025 contain near-zero floats (7.21e-321) instead of NULL.
    Always wrap monthly columns with: NULLIF(CASE WHEN ABS(COALESCE(cd.jan,0)) < 0.01 THEN NULL ELSE cd.jan END, 0)
    Shorthand helper: use CASE WHEN ABS(COALESCE(col,0)) < 0.01 THEN NULL ELSE col END for each month.

  CASH FLOW LINES (tbg_key reference — use in WHERE cs.tbg_key = '...'):
    RL01  (A) TOTAL ENCAISSEMENTS               — total cash inflows
    RL03  (B) TOTAL DECAISSEMENTS                — total cash outflows
    RL05  (C) FLUX MENSUEL GENERE PAR EXPLOITAT  — operating cash flow (CFFO)
    RL07  (D) FLUX MENSUEL GENERE PAR H. EXPLOITAT — investment/non-operating cash flow
    RL09  (E) FLUX MENSUEL                       — financing cash flow
    RL11  FLUX NET MENSUEL (C+D+E)               — NET CASH FLOW (best proxy for FCF)
    RL13  CASH & CASH EQUIVALENT                 — cash position (balance)
    RL14  DETTE BRUTE                            — gross debt

  entity_type: always use 'section' to avoid double-counting categories and subcategories.

  ✓ Net cash flow (FCF proxy) for a year — works for 2025:
    WITH latest AS (SELECT MAX(version_id) AS vid FROM cashflow_data WHERE year = 2025)
    SELECT cs.name AS line_item,
           ROUND(cd.current_year_total::numeric, 0) AS annual_total_m_cfa
    FROM cashflow_data cd
    JOIN cashflow_sections cs ON cs.id = cd.entity_id
    JOIN latest ON cd.version_id = latest.vid
    WHERE cd.entity_type = 'section'
      AND cd.year = 2025
      AND cs.tbg_key IN ('RL01', 'RL03', 'RL05', 'RL11')
    ORDER BY cs.sequence_id;

  ✓ Monthly cash position (CASH & CASH EQUIVALENT) for 2024:
    SELECT cs.name AS line_item,
           cd.jan, cd.feb, cd.mar, cd.apr, cd.may, cd.jun,
           cd.jul, cd.aug, cd.sep, cd.oct, cd.nov, cd.dec
    FROM cashflow_data cd
    JOIN cashflow_sections cs ON cs.id = cd.entity_id
    WHERE cd.entity_type = 'section'
      AND cd.year = 2024
      AND cd.version_id IS NULL
      AND cs.tbg_key = 'RL13';

  ✓ Q4 operating cash flow for 2025:
    WITH latest AS (SELECT MAX(version_id) AS vid FROM cashflow_data WHERE year = 2025)
    SELECT cs.name AS line_item,
           CASE WHEN ABS(COALESCE(cd.oct,0)) < 0.01 THEN NULL ELSE ROUND(cd.oct::numeric,0) END AS oct,
           CASE WHEN ABS(COALESCE(cd.nov,0)) < 0.01 THEN NULL ELSE ROUND(cd.nov::numeric,0) END AS nov,
           CASE WHEN ABS(COALESCE(cd.dec,0)) < 0.01 THEN NULL ELSE ROUND(cd.dec::numeric,0) END AS dec,
           ROUND((COALESCE(CASE WHEN ABS(COALESCE(cd.oct,0)) < 0.01 THEN NULL ELSE cd.oct END, 0)
                + COALESCE(CASE WHEN ABS(COALESCE(cd.nov,0)) < 0.01 THEN NULL ELSE cd.nov END, 0)
                + COALESCE(CASE WHEN ABS(COALESCE(cd.dec,0)) < 0.01 THEN NULL ELSE cd.dec END, 0))::numeric, 0) AS q4_total
    FROM cashflow_data cd
    JOIN cashflow_sections cs ON cs.id = cd.entity_id
    JOIN latest ON cd.version_id = latest.vid
    WHERE cd.entity_type = 'section'
      AND cd.year = 2025
      AND cs.tbg_key = 'RL05';

  ✓ Cash inflows vs outflows comparison for 2025:
    WITH latest AS (SELECT MAX(version_id) AS vid FROM cashflow_data WHERE year = 2025)
    SELECT cs.tbg_key AS code, cs.name AS line_item,
           ROUND(cd.current_year_total::numeric, 0) AS total_m_cfa
    FROM cashflow_data cd
    JOIN cashflow_sections cs ON cs.id = cd.entity_id
    JOIN latest ON cd.version_id = latest.vid
    WHERE cd.entity_type = 'section'
      AND cd.year = 2025
      AND cs.tbg_key IN ('RL01', 'RL03')
    ORDER BY cs.sequence_id;

  ✗ Do NOT use EXTRACT() or date columns on cashflow_data — they don't exist.
  ✗ Do NOT SUM across multiple rows without version_id filter — you will get inflated totals.
  ✗ Do NOT use cashflow_data for revenue questions — it is treasury/liquidity only.
  ✗ FCF is not a named column — use RL11 (Net Cash Flow) as the best available proxy.

USE ONLY the tables and columns listed below.
Do NOT invent table names or column names.

{schema}
"""


def _make_write_sql_node(llm: ChatOllama):
    def write_sql(state: DbPipelineState) -> dict:
        retry  = state.get("retry_count", 0)
        schema = state.get("retrieved_schema", "(no schema)")
        system = _WRITER_SYSTEM.format(schema=schema)

        messages = [SystemMessage(content=system)]
        if state.get("history"):
            messages.append(HumanMessage(
                content=f"Conversation history:\n{state['history']}"
            ))
        messages.append(HumanMessage(content=state["question"]))

        log.info("[attempt %d/%d] Writer invoked", retry + 1, _MAX_RETRIES + 1)
        t0 = time.monotonic()
        response = llm.invoke(messages)
        elapsed  = time.monotonic() - t0

        # Log raw LLM output for debugging
        raw_output = response.content
        log.debug("[attempt %d/%d] Raw LLM output: %s", retry + 1, _MAX_RETRIES + 1, raw_output[:300])

        sql, err = _extract_sql(raw_output)
        if err:
            log.warning("Writer output rejected in %.1fs: %s", elapsed, err)
            log.debug("Raw output that failed extraction: %s", raw_output[:500])
            return {
                "sql": "", "syntax_error": err,
                "table_error": "", "semantic_error": "", "critic_feedback": "",
            }

        log.info(
            "[attempt %d/%d] Writer OK in %.1fs:\n%s",
            retry + 1, _MAX_RETRIES + 1, elapsed,
            textwrap.indent(sql, "    "),
        )
        return {
            "sql": sql,
            "syntax_error": "", "table_error": "", "semantic_error": "",
            "critic_feedback": "",
        }

    return write_sql


# ---------------------------------------------------------------------------
# Node 2 — sqlglot syntax validation (no LLM, no DB)
# ---------------------------------------------------------------------------

def validate_syntax(state: DbPipelineState) -> dict:
    sql = state.get("sql", "").strip()
    if not sql:
        err = "No SQL was generated."
        log.warning("validate_syntax FAIL: %s", err)
        return {"syntax_error": err}
    try:
        stmts = sqlglot.parse(sql, dialect="postgres", error_level=sqlglot.ErrorLevel.RAISE)
        if not stmts:
            err = "Could not parse the SQL statement."
            log.warning("validate_syntax FAIL: %s", err)
            return {"syntax_error": err}
        stmt = stmts[0]
        if not isinstance(stmt, (sexp.Select, sexp.With)):
            err = f"Only SELECT/WITH allowed. Got: {type(stmt).__name__}"
            log.warning("validate_syntax FAIL: %s", err)
            return {"syntax_error": err}
        log.info("validate_syntax PASS")
        return {"syntax_error": ""}
    except sqlglot.errors.ParseError as exc:
        err = str(exc).split("\n")[0]
        log.warning("validate_syntax FAIL: %s", err)
        return {"syntax_error": err}


# ---------------------------------------------------------------------------
# Node 3 — Table whitelist validation (no LLM, no DB)
# ---------------------------------------------------------------------------

def _referenced_tables(sql: str) -> set[str]:
    """Return all real table names in SQL, excluding CTE aliases."""
    try:
        stmt = sqlglot.parse_one(sql, dialect="postgres")
    except Exception:
        return set()
    cte_aliases = {cte.alias.lower() for cte in stmt.find_all(sexp.CTE)}
    return {
        t.name.lower()
        for t in stmt.find_all(sexp.Table)
        if t.name and t.name.lower() not in cte_aliases
    }


def validate_tables(state: DbPipelineState) -> dict:
    if state.get("syntax_error"):
        return {"table_error": ""}      # wait for syntax to pass first

    allowed = {t.lower() for t in state.get("allowed_tables", [])}
    if not allowed:
        log.warning("validate_tables: no whitelist set — skipping check")
        return {"table_error": ""}

    sql = state.get("sql", "").strip()
    if not sql:
        return {"table_error": "No SQL to validate."}

    referenced = _referenced_tables(sql)
    disallowed  = referenced - allowed
    if disallowed:
        err = (
            f"Query references unknown table(s): {', '.join(sorted(disallowed))}. "
            f"Allowed: {', '.join(sorted(allowed))}"
        )
        log.warning("validate_tables FAIL: %s", err)
        return {"table_error": err}

    log.info("validate_tables PASS (referenced: %s)", sorted(referenced))
    return {"table_error": ""}


# ---------------------------------------------------------------------------
# Node 4 — EXPLAIN semantic validation (no LLM, checks real DB names)
# ---------------------------------------------------------------------------

def _get_column_facts(sql: str) -> str:
    """
    For every table referenced in sql, fetch its real column list from DB.
    Returns a compact string injected into the critic prompt so the LLM
    cannot hallucinate column names on the next attempt.
    """
    try:
        from app.db.schema_inspector import get_columns
        referenced = _referenced_tables(sql)
        if not referenced:
            return ""
        lines = ["VERIFIED COLUMNS (exact names + types from live DB — use ONLY these):"]
        for tname in sorted(referenced):
            try:
                cols = get_columns(tname)
                col_list = ", ".join(
                    f"{c.name}({c.data_type}{'PK' if c.is_pk else ''})" for c in cols
                )
                lines.append(f"  {tname}: {col_list}")
            except Exception:
                pass
        return "\n".join(lines)
    except Exception:
        return ""


def validate_semantic(state: DbPipelineState) -> dict:
    if state.get("syntax_error") or state.get("table_error"):
        return {"semantic_error": ""}   # earlier check must pass first

    sql = state.get("sql", "").strip()
    if not sql:
        return {"semantic_error": "No SQL to validate."}
    try:
        explain(sql)
        log.info("validate_semantic PASS")
        return {"semantic_error": "", "column_facts": ""}
    except Exception as exc:
        err = str(exc).split("\n")[0]
        log.warning("validate_semantic FAIL: %s", err)
        log.warning("  SQL: %s", sql[:300])
        facts = _get_column_facts(sql)
        if facts:
            log.info("column_facts populated:\n%s", facts)
        return {"semantic_error": err, "column_facts": facts}


# ---------------------------------------------------------------------------
# Node 5 — Critic LLM: repair SQL using full error history
# ---------------------------------------------------------------------------

_CRITIC_SYSTEM = """\
You are a PostgreSQL SQL repair agent. The database contains financial data for Moov Benin.

╔══ OUTPUT FORMAT — STRICTLY ENFORCED ══╗
║  Output ONLY the corrected SQL SELECT   ║
║  • Start with SELECT or WITH            ║
║  • End with ;                           ║
║  • ZERO explanations, ZERO markdown     ║
╚═════════════════════════════════════════╝

⚠️  ABSOLUTE RULE — COLUMN NAMES:
If error says "column X does not exist", then X DOES NOT EXIST. Do NOT invent names.
Use ONLY the exact column names from VERIFIED COLUMNS below.

KEY INSIGHT — TWO SCHEMA TYPES:

DENORMALIZED (months as columns):
  • cashflow_data: [year, jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec, current_year_total]
    ✓ Query: SELECT SUM(jan), SUM(feb), SUM(mar), ... FROM cashflow_data WHERE year = 2024
    ✗ Do NOT use: date_column, month, EXTRACT(MONTH FROM ...), month column reference
  
  • commission_enlevements: [year, month, prodium, linarcels, somac, easycom, d_commercial, aftel, senaniminde]
    ✓ Query: SELECT prodium, linarcels, somac, ... FROM commission_enlevements WHERE year = 2025

NORMALIZED (date column):
  • financial_metrics_data: has date column → use WHERE EXTRACT(YEAR FROM date) = 2025
  • capex_data: has year and month columns → use WHERE year = 2025 AND month = 9

REPAIR PROCESS:
1. Look at VERIFIED COLUMNS
2. Identify if table is denormalized or normalized
3. If denormalized and error mentions non-existent columns → use the actual month columns (jan, feb, mar, ...)
4. If normalized and error is "can't use EXTRACT on integer" → use direct column comparison

STEP 1 — READ VERIFIED COLUMNS FIRST:
{column_facts}

STEP 2 — TABLE CONSTRAINT:
  Query ONLY these tables:
    {tables_in_sql}

STEP 3 — ERROR DIAGNOSIS:
  • "column X does not exist" → X is wrong. Use exact name from VERIFIED COLUMNS.
  • "relation X does not exist" → X is not a valid table.
  • "function pg_catalog.extract(unknown, integer)" → EXTRACT() on integer column. Use: WHERE year = 2024
  • "must appear in GROUP BY or aggregate" on commission_enlevements →
      Distributors are COLUMNS not rows. Fix by using UNION ALL unpivot:
        WITH totals AS (
            SELECT 'Prodium' AS distributor, SUM(prodium) AS total FROM commission_enlevements WHERE year = 2025
            UNION ALL SELECT 'Linarcels', SUM(linarcels) FROM commission_enlevements WHERE year = 2025
            UNION ALL SELECT 'Easycom',   SUM(easycom)   FROM commission_enlevements WHERE year = 2025
            UNION ALL SELECT 'Somac',     SUM(somac)     FROM commission_enlevements WHERE year = 2025
            UNION ALL SELECT 'D-Commercial', SUM(d_commercial) FROM commission_enlevements WHERE year = 2025
            UNION ALL SELECT 'Aftel',     SUM(aftel)     FROM commission_enlevements WHERE year = 2025
            UNION ALL SELECT 'Senaniminde', SUM(senaniminde) FROM commission_enlevements WHERE year = 2025
        )
        SELECT distributor, total AS total_commission FROM totals
        WHERE total IS NOT NULL ORDER BY total DESC LIMIT 5;
  • Missing columns in denormalized table → use the actual month/distributor columns shown in VERIFIED COLUMNS

STEP 4 — POSTGRESQL RULES:
  • EXTRACT() works ONLY on date/timestamp columns, NOT integers or text
  • Integer columns: WHERE year = 2024 (NOT EXTRACT(YEAR FROM year))
  • ✗ MONTH() YEAR() ISNULL() IFNULL() ← MySQL syntax — FORBIDDEN
  • ✓ NULLIF(amount, 0) to prevent division by zero
  • ✓ COALESCE(col, 0) for NULL defaults

Allowed tables: {allowed_tables}

SCHEMA (VERIFIED COLUMNS takes priority if there's conflict):
{schema}
"""

_CRITIC_USER = """\
USER QUESTION:
{question}

REPAIR HISTORY (all previous attempts, oldest first):
{history}

CURRENT BROKEN SQL:
{sql}

CURRENT ERROR:
{error}

Output ONLY the corrected SQL:
"""


def _make_critique_sql_node(llm: ChatOllama):
    def critique_sql(state: DbPipelineState) -> dict:
        retry    = state.get("retry_count", 0)
        schema   = state.get("retrieved_schema", "(no schema)")
        allowed  = state.get("allowed_tables", [])
        error    = (
            state.get("syntax_error")
            or state.get("table_error")
            or state.get("semantic_error")
            or "unknown error"
        )
        question = state["question"]
        sql      = state.get("sql", "")

        # Accumulate error history
        prev     = state.get("error_history", [])
        entry    = f"  Attempt {retry + 1}: {_clip(error, 200)}\n  SQL was: {_clip(sql, 160)}"
        history  = prev + [entry]

        column_facts = state.get("column_facts", "")
        facts_block    = column_facts if column_facts else (
            "VERIFIED COLUMNS: not yet available — use column names from SCHEMA below."
        )
        tables_in_sql  = sorted(_referenced_tables(sql)) or ["(no tables parsed)"]

        system_msg = _CRITIC_SYSTEM.format(
            column_facts=facts_block,
            tables_in_sql=", ".join(tables_in_sql),
            schema=schema,
            allowed_tables=", ".join(sorted(allowed)),
        )
        user_msg = _CRITIC_USER.format(
            question=question,
            history="\n".join(history),
            sql=sql,
            error=error,
        )

        log.warning(
            "[repair %d/%d] Critic invoked. Error: %s",
            retry + 1, _MAX_RETRIES, _clip(error, 160),
        )
        t0 = time.monotonic()
        response  = llm.invoke([
            SystemMessage(content=system_msg),
            HumanMessage(content=user_msg),
        ])
        elapsed   = time.monotonic() - t0

        fixed_sql, extract_err = _extract_sql(response.content)
        if extract_err:
            # Critic also produced non-SQL — count as a failure and let routing decide
            log.warning("Critic output rejected in %.1fs: %s", elapsed, extract_err)
            return {
                "sql": "",
                "error_history":   history,
                "critic_feedback": f"Repair {retry + 1} failed ({error}).",
                "syntax_error":    extract_err,
                "table_error":     "",
                "semantic_error":  "",
                "retry_count":     retry + 1,
            }

        log.info(
            "Critic fix in %.1fs:\n%s",
            elapsed,
            textwrap.indent(fixed_sql, "    "),
        )
        return {
            "sql":             fixed_sql,
            "error_history":   history,
            "critic_feedback": f"Repair {retry + 1}: fixed '{_clip(error, 80)}'.",
            "syntax_error":    "",
            "table_error":     "",
            "semantic_error":  "",
            "retry_count":     retry + 1,
        }

    return critique_sql


# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------

def _any_validation_error(state: DbPipelineState) -> str:
    return (
        state.get("syntax_error")
        or state.get("table_error")
        or state.get("semantic_error")
        or ""
    )


def _route_after_syntax(state: DbPipelineState) -> str:
    if state.get("syntax_error"):
        if state.get("retry_count", 0) < _MAX_RETRIES:
            return "critique_sql"
        log.error("Syntax retries exhausted — routing to format_answer")
        return "format_answer"
    return "validate_tables"


def _route_after_tables(state: DbPipelineState) -> str:
    if state.get("table_error"):
        if state.get("retry_count", 0) < _MAX_RETRIES:
            return "critique_sql"
        log.error("Table retries exhausted — routing to format_answer")
        return "format_answer"
    return "validate_semantic"


def _route_after_semantic(state: DbPipelineState) -> str:
    if state.get("semantic_error"):
        if state.get("retry_count", 0) < _MAX_RETRIES:
            return "critique_sql"
        log.error("Semantic retries exhausted — routing to format_answer")
        return "format_answer"
    return "execute_sql"


def _route_after_critique(state: DbPipelineState) -> str:
    return "validate_syntax"   # always re-validate from scratch after a fix


# ---------------------------------------------------------------------------
# Node 6 — Execute SQL
# ---------------------------------------------------------------------------

def execute_sql(state: DbPipelineState) -> dict:
    sql = state.get("sql", "").strip()
    if not sql:
        return {"sql_error": "No SQL available for execution.", "rows": [], "cols": []}

    log.info("execute_sql:\n%s", textwrap.indent(sql, "    "))
    t0 = time.monotonic()
    try:
        rows, cols = execute(sql)
        log.info("execute_sql OK: %d rows, %d cols in %.1fs", len(rows), len(cols), time.monotonic() - t0)
        return {"rows": rows, "cols": cols, "sql_error": ""}
    except Exception as exc:
        log.error("execute_sql FAIL in %.1fs: %s", time.monotonic() - t0, exc)
        return {"sql_error": str(exc), "rows": [], "cols": []}


# ---------------------------------------------------------------------------
# Node 7 — Format answer (never leaks SQL)
# ---------------------------------------------------------------------------

_FMT_SYSTEM = """\
You are a senior financial analyst presenting database query results to a Moov Benin executive.

CURRENCY: All monetary values are in FCFA (West African CFA franc). NEVER write $ or USD.
NUMBERS:  Always use thousands separators — write 2,998,413 not 2998413.

CRITICAL — DATA FACTS are pre-computed in Python and are 100% accurate.
You MUST copy numbers from DATA FACTS verbatim into your Summary and Key Insights.
⚠ PEAK/TROUGH RULE: The PEAK is whatever DATA FACTS says PEAK is. Never scan the table
to find a different row. If DATA FACTS says label='1' is the peak, then Month 1 is the peak —
do not substitute a different month even if values nearby look higher. Copy the exact value.
Do NOT re-derive totals, peaks, shares, or trend direction from the table.

OUTPUT FORMAT — use EXACTLY this structure (no deviations):

## [Short descriptive title — 4–8 words matching the question, e.g. "Monthly CapEx Trend — 2025", "P&L Summary — 2024 vs 2025", "Distributor Commission Ranking — 2025"]

**Summary**
[2–3 sentences. Lead with the main finding. Use numbers from DATA FACTS exactly. State trend direction or comparison if applicable. Do NOT list everything — just the headline result.]

[Reproduce the data table exactly as provided — do not reformat, reorder, or omit rows. Keep all pipe characters.]

**Key Insights**
- **[Label]**: [value with context, e.g. "Peak: March 2025 — 2,341,000,000 FCFA (18.3% of total)"]
- **[Label]**: [second finding, e.g. "Lowest: January — 980,000,000 FCFA"]
- **[Label]**: [grand total or average from DATA FACTS]
- **[Label]**: [trend direction or notable variance — omit if not meaningful]

**Source**: [table(s) queried] | [period covered] | [N row(s) returned]

**Follow-up**: [One specific, actionable question the executive should ask next — not generic]

STRICT RULES:
- The ## title MUST reflect the actual question topic.
- Key Insights: write exactly 3–4 bullets. Use **bold labels**. Numbers must come from DATA FACTS.
- Reproduce the table AS-IS including all | characters — do not strip pipes or collapse columns.
- NEVER output SQL, column types, or any technical detail.
- NEVER invent numbers not present in the results.
- If a cell shows "(null)" → write "no data". NEVER write "None" or "null".
- Do NOT start with "I'm sorry", "Based on", or "The query returned".
- {language_instruction}
"""


def _cell(value) -> str:
    return "(null)" if value is None else str(value)


# ---------------------------------------------------------------------------
# Chart spec builder — pure Python, no LLM
# ---------------------------------------------------------------------------

_TIME_COL_NAMES = {
    "month", "year", "date", "period", "quarter",
    "month_number", "month_no", "month_num",
    "week", "week_number", "week_no",
    "quarter_number", "quarter_no",
    "jan", "feb", "mar", "apr", "may", "jun",
    "jul", "aug", "sep", "oct", "nov", "dec",
}

_RANK_KEYWORDS = {
    "top", "rank", "best", "worst", "highest", "lowest",
    "distributor", "supplier", "fournisseur", "category", "categorie",
}

_TREND_KEYWORDS = {
    "trend", "monthly", "evolution", "mensuel", "par mois",
    "over time", "breakdown", "month by month",
}

_PALETTE = ["#6c63ff", "#4ecca3", "#f6ad55", "#fc8181", "#63b3ed", "#f687b3"]


def _to_float(v) -> float | None:
    from decimal import Decimal
    if v is None:
        return None
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def _compute_trend_analysis(rows: list[dict], x_key: str, y_key: str | None) -> str:
    """Compute a short plain-English trend summary from chart data."""
    if not y_key or len(rows) < 2:
        return ""
    vals = [(_to_float(r.get(y_key)), str(r.get(x_key, ""))) for r in rows]
    vals = [(v, lbl) for v, lbl in vals if v is not None]
    if len(vals) < 2:
        return ""

    numbers = [v for v, _ in vals]
    total   = sum(numbers)
    avg     = total / len(numbers)
    max_v, max_lbl = max(vals, key=lambda x: x[0])
    min_v, min_lbl = min(vals, key=lambda x: x[0])
    first, last = numbers[0], numbers[-1]
    overall_change_pct = ((last - first) / abs(first) * 100) if first else 0

    increases = sum(1 for i in range(1, len(numbers)) if numbers[i] > numbers[i - 1])
    decreases = len(numbers) - 1 - increases
    if increases > decreases:
        direction = "an overall upward trend"
    elif decreases > increases:
        direction = "an overall downward trend"
    else:
        direction = "mixed movement with no clear direction"

    parts = [
        f"The data shows {direction} across {len(vals)} periods.",
        f"Peak: {max_lbl} at {max_v:,.0f} FCFA.",
        f"Trough: {min_lbl} at {min_v:,.0f} FCFA.",
        f"Average: {avg:,.0f} FCFA.",
    ]
    if abs(overall_change_pct) >= 1:
        sign = "+" if overall_change_pct > 0 else ""
        parts.append(f"Net change from first to last period: {sign}{overall_change_pct:.1f}%.")
    return " ".join(parts)


def _build_chart_spec(cols: list[str], rows: list[dict], question: str) -> dict | None:
    """Infer a chart spec from the result shape and question keywords. Returns None if not chartable."""
    if len(rows) < 2 or len(cols) < 2:
        return None

    # Classify columns
    numeric_cols: list[str] = []
    label_cols:   list[str] = []
    for c in cols:
        samples = [r.get(c) for r in rows[:10] if r.get(c) is not None]
        if samples and all(_to_float(v) is not None for v in samples):
            numeric_cols.append(c)
        else:
            label_cols.append(c)

    if not numeric_cols:
        return None

    # Pick x-axis: prefer time column, then first label col
    time_col = next((c for c in cols if c.lower() in _TIME_COL_NAMES), None)
    x_key    = time_col or (label_cols[0] if label_cols else None)
    if x_key is None:
        return None

    y_keys = [c for c in numeric_cols if c != x_key][:4]
    if not y_keys:
        # All columns are numeric — use row index as x
        y_keys = numeric_cols[:4]
        x_key  = cols[0]

    # Detect chart type
    q = question.lower()
    is_time  = time_col in ("month", "date", "period") or any(k in q for k in _TREND_KEYWORDS)
    is_rank  = any(k in q for k in _RANK_KEYWORDS) and len(rows) <= 20
    is_multi = len(y_keys) > 1

    if is_time:
        chart_type = "line"
    elif is_rank:
        chart_type = "bar_horizontal"
    else:
        chart_type = "bar"

    # Serialize — convert Decimal/None to float/null
    data = []
    for r in rows[:60]:
        entry: dict = {}
        entry[x_key] = str(r.get(x_key) or "")
        for y in y_keys:
            v = _to_float(r.get(y))
            entry[y] = v  # None serialises to null in JSON
        data.append(entry)

    # Axis labels — humanise the column name
    x_label = x_key.replace("_", " ").title()
    y_label = (y_keys[0].replace("_", " ").title() if len(y_keys) == 1 else "Value")

    # Trend analysis from the full row set
    trend_analysis = _compute_trend_analysis(rows, x_key, y_keys[0] if y_keys else None)

    return {
        "chart_type":     chart_type,
        "title":          question[:80],
        "data":           data,
        "x_key":          x_key,
        "y_keys":         y_keys,
        "colors":         _PALETTE[: len(y_keys)],
        "unit":           "FCFA",
        "x_label":        x_label,
        "y_label":        y_label,
        "trend_analysis": trend_analysis,
    }


def _fmt_number(s: str) -> str:
    """Add thousands separators to bare numeric strings."""
    try:
        f = float(s)
        if f == int(f):
            return f"{int(f):,}"
        return f"{f:,.2f}"
    except (ValueError, TypeError):
        return s


# Max rows shown to the LLM — keeps prompts short and avoids cloud timeouts.
# DATA FACTS already captures totals/peaks for the full result set.
_LLM_TABLE_ROW_CAP = 30


def _build_ascii_table(rows: list[dict], cols: list[str], cap: int = _LLM_TABLE_ROW_CAP) -> str:
    # Rename ugly PostgreSQL default headers
    display_cols = ["value" if c in ("?column?", "?column?") else c for c in cols]
    col_rename   = dict(zip(cols, display_cols))

    sample = rows[:cap]
    col_w  = {
        dc: max(len(dc), max((len(_fmt_number(_cell(r.get(c)))) for r in sample), default=0))
        for c, dc in col_rename.items()
    }
    header = "| " + " | ".join(dc.ljust(col_w[dc]) for dc in display_cols) + " |"
    sep    = "| " + " | ".join("-" * col_w[dc] for dc in display_cols) + " |"
    lines  = [header, sep]
    for r in sample:
        lines.append("| " + " | ".join(
            _fmt_number(_cell(r.get(c))).ljust(col_w[dc])
            for c, dc in col_rename.items()
        ) + " |")
    if len(rows) > cap:
        lines.append(f"... ({len(rows) - cap} more rows — totals in DATA FACTS above)")
    return "\n".join(lines)


def _compute_data_facts(cols: list[str], rows: list[dict]) -> str:
    """
    Pre-compute key statistics from the result set in Python (ground truth).
    Injected into the LLM prompt so it cannot misidentify peaks, totals, or shares.
    """
    from decimal import Decimal

    if not rows or not cols:
        return ""

    # Columns that look like dimension/index, not metrics
    _DIM_EXACT = {
        "month", "year", "id", "sequence", "rank", "quarter", "week",
        "month_number", "week_number", "quarter_number",
        "month_no", "week_no", "quarter_no", "num", "number", "m",
    }
    _DIM_SUFFIXES = ("_id", "_number", "_no", "_num", "_rank", "_seq")

    def _is_dim_col(name: str, vals: list) -> bool:
        n = name.lower()
        if n in _DIM_EXACT:
            return True
        if any(n.endswith(s) for s in _DIM_SUFFIXES):
            return True
        # Heuristic: if all values are small integers (≤ 366), likely an index/period column
        nums = [_to_float(v) for v in vals if v is not None]
        if nums and all(v is not None and v == int(v) and abs(v) <= 366 for v in nums):
            return True
        return False

    numeric_col = label_col = None
    for c in cols:
        vals = [r.get(c) for r in rows if r.get(c) is not None]
        if not vals:
            continue
        is_numeric = all(isinstance(v, (int, float, Decimal)) for v in vals)
        is_dim     = _is_dim_col(c, vals)
        if is_numeric and not is_dim:
            if numeric_col is None:
                numeric_col = c
        else:
            if label_col is None:
                label_col = c

    if not numeric_col:
        return ""

    float_vals = [(_to_float(r.get(numeric_col)), r) for r in rows]
    float_vals = [(v, r) for v, r in float_vals if v is not None]
    if not float_vals:
        return ""

    total      = sum(v for v, _ in float_vals)
    max_val, max_row = max(float_vals, key=lambda x: x[0])
    min_val, min_row = min(float_vals, key=lambda x: x[0])
    max_share  = (max_val / total * 100) if total else 0
    max_label  = str(max_row.get(label_col or cols[0], ""))

    min_label = str(min_row.get(label_col or cols[0], ""))
    facts = [
        f"DATA FACTS — AUTHORITATIVE. Copy these numbers verbatim. DO NOT re-derive from the table:",
        f"  • PEAK  (highest): label={max_label!r}  value={max_val:,.2f}  share={max_share:.1f}% of total",
        f"  • TROUGH (lowest): label={min_label!r}  value={min_val:,.2f}",
        f"  • Grand total    : {total:,.2f}",
        f"  • Row count      : {len(rows)}",
        f"  • Metric column  : {numeric_col}  |  Label column: {label_col or cols[0]}",
    ]

    # Flag if multiple rows are numeric for trend direction
    if len(float_vals) >= 3:
        ordered_vals = [v for v, _ in float_vals]
        increases = sum(1 for i in range(1, len(ordered_vals)) if ordered_vals[i] > ordered_vals[i-1])
        direction = "mostly increasing" if increases > len(ordered_vals) // 2 else "mostly decreasing" if increases < len(ordered_vals) // 2 else "mixed"
        facts.append(f"  • Trend direction: {direction}")

    return "\n".join(facts)


def _format_fallback(rows: list[dict], cols: list[str], question: str,
                     facts: str, source: str, chart_spec: dict | None,
                     lang: str) -> dict:
    """
    Return a structured answer built entirely from pre-computed Python values,
    used when the LLM call times out or fails.
    """
    table = _build_ascii_table(rows, cols)

    if lang == "fr":
        source_label   = "Source"
        followup_label = "Suggestion"
        followup_text  = "Souhaitez-vous filtrer ou approfondir ces résultats ?"
        note           = f"(Réponse générée sans IA — {len(rows)} ligne(s) récupérée(s))"
        insights_label = "Points clés"
    else:
        source_label   = "Source"
        followup_label = "Follow-up"
        followup_text  = "Would you like to filter or drill down into these results?"
        note           = f"(Response generated without AI narration — {len(rows)} row(s) returned)"
        insights_label = "Key Insights"

    # Extract DATA FACTS bullets for Key Insights
    bullets: list[str] = []
    if facts:
        for line in facts.splitlines():
            line = line.strip().lstrip("•").strip()
            if line and not line.startswith("DATA FACTS"):
                bullets.append(f"- **{line.split(':')[0].strip()}**: {':'.join(line.split(':')[1:]).strip()}" if ":" in line else f"- {line}")
    bullets_text = "\n".join(bullets[:4]) if bullets else f"- {len(rows)} row(s) returned"

    summary_text = bullets[0].lstrip("- ").strip() if bullets else f"{len(rows)} row(s) returned."
    title = question[:70]

    answer = (
        f"## {title}\n\n"
        f"**Summary**\n{summary_text}\n\n"
        f"{table}\n\n"
        f"**{insights_label}**\n{bullets_text}\n\n"
        f"**{source_label}**: {source}\n\n"
        f"**{followup_label}**: {followup_text}\n\n"
        f"_{note}_"
    )
    log.warning("format_answer: used fallback (no LLM) for %d rows", len(rows))
    return {"answer": answer, "chart_specs": [chart_spec] if chart_spec else []}


def _source_context(sql: str, rows: list[dict]) -> str:
    """Derive a short validation line from the SQL and result size."""
    tables = sorted(_referenced_tables(sql))
    table_str = ", ".join(tables) if tables else "database"
    n = len(rows)
    row_str = f"{n} row" if n == 1 else f"{n} rows"

    # Try to extract year/period filter from SQL text for context
    year_m = re.search(r"\b(20\d{2})\b", sql)
    period = f" for {year_m.group(1)}" if year_m else ""

    return f"{table_str}{period} | {row_str} returned"


_LANG_INSTRUCTIONS = {
    "fr": "Répondez en français. Toutes les réponses, analyses et libellés doivent être en français.",
    "en": "Respond in English.",
}


def _make_format_answer_node(llm: ChatOllama):
    def format_answer(state: DbPipelineState) -> dict:
        retry     = state.get("retry_count", 0)
        sql_error = state.get("sql_error", "")
        rows      = state.get("rows", [])
        cols      = state.get("cols", [])
        question  = state["question"]
        sql       = state.get("sql", "")
        lang      = state.get("language", "en")

        # ── Validation exhausted ─────────────────────────────────────────
        remaining = _any_validation_error(state)
        if remaining and not rows:
            log.warning("format_answer: SQL_GENERATION_FAILED after %d retries", retry)
            return {"answer": (
                f"SQL_GENERATION_FAILED: I was unable to generate a valid query "
                f"after {retry} repair attempt(s).\n"
                f"Last error: {remaining[:300]}"
            )}

        # ── Runtime execution error ──────────────────────────────────────
        if sql_error:
            reason = sql_error.split("\n")[0][:250]
            log.warning("format_answer: execution error → %s", reason)
            return {"answer": f"I could not retrieve the data. Reason: {reason}"}

        # ── Empty result set ─────────────────────────────────────────────
        if not rows:
            log.info("format_answer: 0 rows returned")
            return {"answer": (
                "The query ran successfully but returned no results. "
                "Try broadening your filters or checking the date range."
            )}

        # ── Build table, facts, chart spec, and source context ───────────
        table      = _build_ascii_table(rows, cols)
        facts      = _compute_data_facts(cols, rows)
        source     = _source_context(sql, rows)
        chart_spec = _build_chart_spec(cols, rows, question)
        if chart_spec:
            log.info("format_answer: chart_type=%s x=%s y=%s",
                     chart_spec["chart_type"], chart_spec["x_key"], chart_spec["y_keys"])
        if facts:
            log.info("format_answer: data facts injected:\n%s", facts)

        lang_instr = _LANG_INSTRUCTIONS.get(lang, _LANG_INSTRUCTIONS["en"])
        fmt_system = _FMT_SYSTEM.format(language_instruction=lang_instr)

        log.info("format_answer: narrating %d rows via LLM (lang=%s, showing up to %d)",
                 len(rows), lang, _LLM_TABLE_ROW_CAP)
        t0 = time.monotonic()
        try:
            response = llm.invoke([
                SystemMessage(content=fmt_system),
                HumanMessage(content=(
                    f"User question: {question}\n\n"
                    f"{facts}\n\n"
                    f"Query source (for the **Source** line): {source}\n\n"
                    f"Result ({len(rows)} row(s), first {_LLM_TABLE_ROW_CAP} shown):\n{table}"
                )),
            ])
            log.info("format_answer LLM done in %.1fs", time.monotonic() - t0)
            return {
                "answer":      response.content,
                "chart_specs": [chart_spec] if chart_spec else [],
            }
        except Exception as llm_err:
            log.error("format_answer LLM failed after %.1fs: %s — using fallback",
                      time.monotonic() - t0, llm_err)
            return _format_fallback(rows, cols, question, facts, source, chart_spec, lang)

    return format_answer


# ---------------------------------------------------------------------------
# Build the pipeline graph
# ---------------------------------------------------------------------------

def _build_db_pipeline(model: str | None = None) -> object:
    llm = _make_llm(model)
    g   = StateGraph(DbPipelineState)

    g.add_node("retrieve_schema",   retrieve_schema)
    g.add_node("write_sql",         _make_write_sql_node(llm))
    g.add_node("validate_syntax",   validate_syntax)
    g.add_node("validate_tables",   validate_tables)
    g.add_node("validate_semantic", validate_semantic)
    g.add_node("critique_sql",      _make_critique_sql_node(llm))
    g.add_node("execute_sql",       execute_sql)
    g.add_node("format_answer",     _make_format_answer_node(llm))

    g.set_entry_point("retrieve_schema")
    g.add_edge("retrieve_schema", "write_sql")
    g.add_edge("write_sql",       "validate_syntax")

    g.add_conditional_edges(
        "validate_syntax", _route_after_syntax,
        {"critique_sql": "critique_sql", "validate_tables": "validate_tables", "format_answer": "format_answer"},
    )
    g.add_conditional_edges(
        "validate_tables", _route_after_tables,
        {"critique_sql": "critique_sql", "validate_semantic": "validate_semantic", "format_answer": "format_answer"},
    )
    g.add_conditional_edges(
        "validate_semantic", _route_after_semantic,
        {"critique_sql": "critique_sql", "execute_sql": "execute_sql", "format_answer": "format_answer"},
    )
    g.add_conditional_edges(
        "critique_sql", _route_after_critique,
        {"validate_syntax": "validate_syntax"},
    )
    g.add_edge("execute_sql",   "format_answer")
    g.add_edge("format_answer", END)

    return g.compile()


_db_pipeline_cache: dict[str, object] = {}


def _get_db_pipeline(model: str | None = None) -> object:
    key = model or settings.OLLAMA_MODEL
    if key not in _db_pipeline_cache:
        _db_pipeline_cache[key] = _build_db_pipeline(model=key)
    return _db_pipeline_cache[key]


# ---------------------------------------------------------------------------
# Question intent classification
# ---------------------------------------------------------------------------

_INTENT_CLASSIFIER_PROMPT = """\
Classify the user's question as one of:
- "definition": ONLY asking for explanation/definition of a term (e.g., "what is CAPEX", "explain EBITDA")
- "data_query": asking for data, metrics, numbers, trends, or analysis from the database (e.g., "show me sales", "what was the trend", "how much did we spend")
- "both": asking BOTH a definition AND a data/trend question in the same message (e.g., "what is CAPEX? what was the monthly trend?", "explain ARPU and show me the 2024 values")
- "other": something else (e.g., small talk, greetings, off-topic)

Respond with ONLY the classification (one word: "definition", "data_query", "both", or "other").

Question: {question}
Classification:"""


def _classify_question_intent(llm: OllamaLLM, question: str) -> str:
    """Use LLM to classify if question is asking for definition, data, both, or other."""
    try:
        prompt = _INTENT_CLASSIFIER_PROMPT.format(question=question)
        response = llm.invoke([
            SystemMessage(content="You are a question classifier."),
            HumanMessage(content=prompt),
        ])
        classification = response.content.strip().lower()

        valid = ("definition", "data_query", "both", "other")
        if classification not in valid:
            log.warning("Unexpected classification output: %s — defaulting to data_query", classification)
            return "data_query"

        log.info("Question classified as: %s", classification)
        return classification
    except Exception as exc:
        log.warning("Classification failed (%s) — defaulting to data_query", exc)
        return "data_query"


def _load_financial_terms() -> list[dict]:
    """Load financial_terms.json once; return empty list on failure."""
    try:
        with open(_FINANCIAL_TERMS_PATH, encoding="utf-8") as fh:
            return json.load(fh).get("terms", [])
    except Exception as exc:
        log.warning("Could not load financial_terms.json: %s", exc)
        return []

_FINANCIAL_TERMS: list[dict] = _load_financial_terms()


def _lookup_term(question: str) -> dict | None:
    """
    Find the best matching term entry for a question.
    Matches against the canonical term name and all aliases (case-insensitive).
    Returns the term dict, or None if no match found.
    """
    q_lower = question.lower()
    best: dict | None = None
    best_len = 0
    for entry in _FINANCIAL_TERMS:
        candidates = [entry["term"].lower()] + [a.lower() for a in entry.get("aliases", [])]
        for candidate in candidates:
            # Short aliases (≤4 chars) must match on a word boundary to avoid
            # false positives like "ca" matching inside "categories".
            if len(candidate) <= 4:
                pattern = r"(?<![a-z])" + re.escape(candidate) + r"(?![a-z])"
                matched = bool(re.search(pattern, q_lower))
            else:
                matched = candidate in q_lower
            if matched and len(candidate) > best_len:
                best = entry
                best_len = len(candidate)
    return best


def _format_term_reference(entry: dict, language: str) -> str:
    """Format a financial_terms.json entry into readable reference text."""
    lang = language if language in ("en", "fr") else "en"
    definition_key = f"definition_{lang}"
    definition = entry.get(definition_key) or entry.get("definition_en", "")

    lines = [
        f"**{entry['term']}**",
        f"*Category: {entry.get('category', '')}*",
        "",
        definition,
    ]
    if formula := entry.get("formula"):
        lines += ["", f"**Formula:** `{formula}`"]
    if unit := entry.get("unit"):
        lines += [f"**Unit:** {unit}"]
    if context := entry.get("context"):
        lines += ["", f"**Context:** {context}"]
    return "\n".join(lines)


def _get_definition_answer(question: str, llm: OllamaLLM, language: str = "en", definition_only: bool = False) -> str:
    """
    Answer a definition question.
    1. Check financial_terms.json for a matching entry — if found, inject the
       reference text into the LLM prompt so it gives an authoritative answer.
    2. Fall back to pure LLM knowledge if no entry matches.

    definition_only=True: strictly define the term; do not acknowledge or attempt
    to answer any data/trend parts of the question (those will be handled separately).
    """
    lang_instr = _LANG_INSTRUCTIONS.get(language, _LANG_INSTRUCTIONS["en"])
    term_entry = _lookup_term(question)

    scope_instruction = (
        "Your ONLY task is to define the financial term mentioned in the question. "
        "Stop after the definition. "
        "NEVER mention data, trends, monthly figures, or numerical analysis. "
        "NEVER say you cannot provide something. "
        "NEVER add any disclaimer, caveat, or note about data availability."
    ) if definition_only else (
        "Answer the question precisely and concisely."
    )

    if term_entry:
        log.info("Term reference found: %s", term_entry["term"])
        reference_block = _format_term_reference(term_entry, language)
        system_content = (
            "You are a financial analyst expert for Moov Benin. "
            f"{scope_instruction} "
            "Use the following authoritative reference. "
            "You may expand with telecom/Benin context but do not contradict the reference. "
            f"{lang_instr}\n\n"
            "--- REFERENCE ---\n"
            f"{reference_block}\n"
            "--- END REFERENCE ---"
        )
    else:
        log.info("No term reference found — using LLM knowledge only")
        system_content = (
            "You are a financial analyst expert for Moov Benin. "
            f"{scope_instruction} "
            f"Include practical examples relevant to telecom/financial services in Benin. "
            f"{lang_instr}"
        )

    # When definition_only, extract just the term name to avoid the LLM seeing
    # the data/trend part of the question and feeling compelled to address it.
    if definition_only and term_entry:
        user_prompt = f"Define {term_entry['term']}."
    else:
        user_prompt = question

    try:
        response = llm.invoke([
            SystemMessage(content=system_content),
            HumanMessage(content=user_prompt),
        ])
        answer = response.content.strip()
        if not answer:
            answer = "I was unable to generate an explanation. Please try rephrasing your question."
        return answer
    except Exception as exc:
        log.error("Definition generation failed: %s", exc)
        if term_entry:
            return _format_term_reference(term_entry, language)
        return f"I encountered an error while generating the explanation: {str(exc)}"


def _get_definition_tokens(question: str, llm: OllamaLLM, language: str = "en", definition_only: bool = False):
    """Stream tokens for a definition answer."""
    lang_instr = _LANG_INSTRUCTIONS.get(language, _LANG_INSTRUCTIONS["en"])
    term_entry = _lookup_term(question)

    scope_instruction = (
        "Your ONLY task is to define the financial term mentioned in the question. "
        "Stop after the definition. "
        "NEVER mention data, trends, monthly figures, or numerical analysis. "
        "NEVER say you cannot provide something. "
        "NEVER add any disclaimer, caveat, or note about data availability."
    ) if definition_only else (
        "Answer the question precisely and concisely."
    )

    if term_entry:
        reference_block = _format_term_reference(term_entry, language)
        system_content = (
            "You are a financial analyst expert for Moov Benin. "
            f"{scope_instruction} "
            "Use the following authoritative reference. "
            "You may expand with telecom/Benin context but do not contradict the reference. "
            f"{lang_instr}\n\n"
            "--- REFERENCE ---\n"
            f"{reference_block}\n"
            "--- END REFERENCE ---"
        )
    else:
        system_content = (
            "You are a financial analyst expert for Moov Benin. "
            f"{scope_instruction} "
            f"Include practical examples relevant to telecom/financial services in Benin. "
            f"{lang_instr}"
        )

    if definition_only and term_entry:
        user_prompt = f"Define {term_entry['term']}."
    else:
        user_prompt = question

    yield from llm.stream_tokens([
        SystemMessage(content=system_content),
        HumanMessage(content=user_prompt),
    ])


# ---------------------------------------------------------------------------
# Conversation history
# ---------------------------------------------------------------------------

_conversation_history: dict[str, list[str]] = {}


def evict_graph(session_id: str) -> None:
    _graph_cache.pop(session_id, None)
    for key in list(_conversation_history.keys()):
        if key.startswith(f"db:{session_id}:"):
            _conversation_history.pop(key, None)


# ---------------------------------------------------------------------------
# Public entrypoints
# ---------------------------------------------------------------------------

async def run_db_agent(
    session_id: str,
    message: str,
    conversation_id: str = "default",
    model: str | None = None,
    language: str = "en",
) -> dict:
    import asyncio

    t_start       = time.monotonic()
    thread_id     = f"db:{session_id}:{conversation_id}"
    history_turns = _conversation_history.get(thread_id, [])
    history_text  = "\n".join(history_turns[-6:])

    # ─────────────────────────────────────────────────────────────
    # Pre-check: Classify question intent using LLM
    # ─────────────────────────────────────────────────────────────
    llm = _make_llm(model)
    classification = _classify_question_intent(llm, message)

    if classification == "definition":
        answer = _get_definition_answer(message, llm, language=language)
        log.info("Definition question detected — returning explanation")
        history_turns.append(f"Q: {message}\nA: {answer}")
        _conversation_history[thread_id] = history_turns
        inference_time = round(time.monotonic() - t_start, 2)
        return {"answer": answer, "charts": [], "inference_time": inference_time}

    definition_prefix = ""
    if classification == "both":
        log.info("Combined question detected — answering definition then querying data")
        definition_prefix = _get_definition_answer(message, llm, language=language, definition_only=True)

    # ─────────────────────────────────────────────────────────────
    # Proceed with normal SQL pipeline for data queries
    # ─────────────────────────────────────────────────────────────
    pipeline = _get_db_pipeline(model)

    log.info("=== run_db_agent  session=%s  conv=%s  model=%s  lang=%s ===", session_id, conversation_id, model or settings.OLLAMA_MODEL, language)
    log.info("Question: %s", _clip(message))

    state: DbPipelineState = {
        "question":         message,
        "history":          history_text,
        "language":         language,
        "retrieved_schema": "",
        "allowed_tables":   [],
        "sql":              "",
        "syntax_error":     "",
        "table_error":      "",
        "semantic_error":   "",
        "error_history":    [],
        "column_facts":     "",
        "critic_feedback":  "",
        "retry_count":      0,
        "sql_error":        "",
        "rows":             [],
        "cols":             [],
        "answer":           "",
        "chart_specs":      [],
    }

    result = await asyncio.to_thread(pipeline.invoke, state)
    inference_time = round(time.monotonic() - t_start, 2)
    log.info("Pipeline finished in %.1fs", inference_time)

    answer      = result.get("answer") or "I was unable to generate a response."
    chart_specs = result.get("chart_specs", [])

    if definition_prefix:
        answer = definition_prefix + "\n\n---\n\n" + answer

    history_turns.append(f"Q: {message}\nA: {answer}")
    _conversation_history[thread_id] = history_turns
    return {"answer": answer, "charts": chart_specs, "inference_time": inference_time}


async def run_db_agent_stream(
    session_id: str,
    message: str,
    conversation_id: str = "default",
    model: str | None = None,
    language: str = "en",
):
    """
    Async generator that yields SSE-formatted strings for streaming chat.
    Events: progress, token, charts, done, error
    """
    import asyncio, json as _json

    def _sse(event: str, data) -> str:
        return f"event: {event}\ndata: {_json.dumps(data, ensure_ascii=False)}\n\n"

    t_start   = time.monotonic()
    thread_id = f"db:{session_id}:{conversation_id}"
    history_turns = _conversation_history.get(thread_id, [])
    history_text  = "\n".join(history_turns[-6:])

    yield _sse("progress", {"message": "Classifying question…"})

    llm = _make_llm(model)
    classification = await asyncio.to_thread(_classify_question_intent, llm, message)

    definition_prefix = ""
    if classification == "definition":
        yield _sse("progress", {"message": "Generating definition…"})
        full_answer = ""
        try:
            for token in _get_definition_tokens(message, llm, language=language):
                full_answer += token
                yield _sse("token", {"text": token})
        except Exception as exc:
            log.error("Definition stream failed: %s", exc)
            full_answer = _get_definition_answer(message, llm, language=language)
            yield _sse("token", {"text": full_answer})
        history_turns.append(f"Q: {message}\nA: {full_answer}")
        _conversation_history[thread_id] = history_turns
        inference_time = round(time.monotonic() - t_start, 2)
        yield _sse("done", {"inference_time": inference_time, "charts": []})
        return

    if classification == "both":
        yield _sse("progress", {"message": "Generating definition…"})
        try:
            for token in _get_definition_tokens(message, llm, language=language, definition_only=True):
                definition_prefix += token
                yield _sse("token", {"text": token})
        except Exception as exc:
            log.error("Definition stream failed: %s", exc)
            definition_prefix = _get_definition_answer(message, llm, language=language, definition_only=True)
            yield _sse("token", {"text": definition_prefix})
        yield _sse("token", {"text": "\n\n---\n\n"})

    elif classification == "data_query":
        # If the question mentions a known financial term, stream a brief one-liner intro
        term_entry = _lookup_term(message)
        if term_entry:
            lang_key = f"definition_{language}" if language in ("en", "fr") else "definition_en"
            full_def = term_entry.get(lang_key) or term_entry.get("definition_en", "")
            # First sentence only
            first_sentence = full_def.split(".")[0].strip() + "." if "." in full_def else full_def
            intro = f"**{term_entry['term']}**: {first_sentence}\n\n---\n\n"
            definition_prefix = intro
            yield _sse("token", {"text": intro})
            log.info("data_query: added brief term intro for %s", term_entry["term"])

    yield _sse("progress", {"message": "Retrieving schema…"})
    schema_state = await asyncio.to_thread(retrieve_schema, {
        "question": message, "history": history_text, "language": language,
        "retrieved_schema": "", "allowed_tables": [], "sql": "",
        "syntax_error": "", "table_error": "", "semantic_error": "",
        "error_history": [], "column_facts": "", "critic_feedback": "",
        "retry_count": 0, "sql_error": "", "rows": [], "cols": [],
        "answer": "", "chart_specs": [],
    })

    yield _sse("progress", {"message": "Writing SQL…"})
    write_node = _make_write_sql_node(llm)
    sql_state = await asyncio.to_thread(write_node, {**schema_state, "question": message,
        "history": history_text, "language": language,
        "syntax_error": "", "table_error": "", "semantic_error": "",
        "error_history": [], "column_facts": "", "critic_feedback": "",
        "retry_count": 0, "sql_error": "", "rows": [], "cols": [],
        "answer": "", "chart_specs": [],
    })
    current_state = {
        "question": message, "history": history_text, "language": language,
        "retry_count": 0, "error_history": [], "chart_specs": [], "answer": "",
        **schema_state, **sql_state,
    }

    # Validate + repair loop (synchronous, same as pipeline)
    yield _sse("progress", {"message": "Validating query…"})
    for _ in range(_MAX_RETRIES + 2):
        vs = await asyncio.to_thread(validate_syntax, current_state)
        current_state = {**current_state, **vs}
        if not current_state.get("syntax_error"):
            vt = await asyncio.to_thread(validate_tables, current_state)
            current_state = {**current_state, **vt}
            if not current_state.get("table_error"):
                vsem = await asyncio.to_thread(validate_semantic, current_state)
                current_state = {**current_state, **vsem}
                if not current_state.get("semantic_error"):
                    break
        err = _any_validation_error(current_state)
        if not err or current_state.get("retry_count", 0) >= _MAX_RETRIES:
            break
        yield _sse("progress", {"message": f"Repairing SQL (attempt {current_state.get('retry_count',0)+1})…"})
        critique_node = _make_critique_sql_node(llm)
        cr = await asyncio.to_thread(critique_node, current_state)
        current_state = {**current_state, **cr}

    yield _sse("progress", {"message": "Executing query…"})
    exec_state = await asyncio.to_thread(execute_sql, current_state)
    current_state = {**current_state, **exec_state}

    rows = current_state.get("rows", [])
    cols = current_state.get("cols", [])

    # Build chart spec and facts
    chart_spec = _build_chart_spec(cols, rows, message) if rows else None
    facts      = _compute_data_facts(cols, rows) if rows else ""
    source     = _source_context(current_state.get("sql",""), rows)
    lang_instr = _LANG_INSTRUCTIONS.get(language, _LANG_INSTRUCTIONS["en"])
    fmt_system = _FMT_SYSTEM.format(language_instruction=lang_instr)
    table      = _build_ascii_table(rows, cols) if rows else ""

    yield _sse("progress", {"message": "Formatting answer…"})

    full_answer = ""
    try:
        fmt_messages = [
            SystemMessage(content=fmt_system),
            HumanMessage(content=(
                f"User question: {message}\n\n"
                f"{facts}\n\n"
                f"Query source (for the **Source** line): {source}\n\n"
                f"Result ({len(rows)} row(s), first {_LLM_TABLE_ROW_CAP} shown):\n{table}"
            )),
        ]
        for token in llm.stream_tokens(fmt_messages):
            full_answer += token
            yield _sse("token", {"text": token})
    except Exception as exc:
        log.error("Streaming format_answer failed: %s", exc)
        fallback = _format_fallback(rows, cols, message, facts, source, chart_spec, language)
        fallback_text = fallback["answer"]
        full_answer = fallback_text
        yield _sse("token", {"text": fallback_text})

    full_answer = (definition_prefix + "\n\n---\n\n" + full_answer) if definition_prefix else full_answer
    history_turns.append(f"Q: {message}\nA: {full_answer}")
    _conversation_history[thread_id] = history_turns
    inference_time = round(time.monotonic() - t_start, 2)
    yield _sse("done", {"inference_time": inference_time, "charts": [chart_spec] if chart_spec else []})


async def run_agent(
    session_id: str,
    parsed_data: dict,
    message: str,
    conversation_id: str = "default",
    model: str | None = None,
    language: str = "en",
) -> dict:
    t_start   = time.monotonic()
    graph     = get_or_create_graph(session_id, parsed_data, model=model)
    thread_id = f"{session_id}:{conversation_id}"
    config    = {"configurable": {"thread_id": thread_id}}

    lang_instr = _LANG_INSTRUCTIONS.get(language, _LANG_INSTRUCTIONS["en"])
    augmented  = f"[{lang_instr}]\n{message}"

    result = await graph.ainvoke(
        {"messages": [HumanMessage(content=augmented)]},
        config=config,
    )

    inference_time = round(time.monotonic() - t_start, 2)
    messages = result.get("messages", [])
    for msg in reversed(messages):
        if hasattr(msg, "content") and msg.content and not getattr(msg, "tool_calls", None):
            return {"answer": msg.content, "inference_time": inference_time}

    return {"answer": "I was unable to generate a response. Please try again.", "inference_time": inference_time}
