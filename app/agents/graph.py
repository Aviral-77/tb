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
import re
import textwrap
import time
from pathlib import Path
from typing import TypedDict

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

_THRESHOLDS_PATH = Path(__file__).parent.parent / "thresholds.json"

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

def _make_llm() -> ChatOllama:
    llm = ChatOllama(
        model=settings.OLLAMA_MODEL,
        base_url=settings.OLLAMA_BASE_URL,
        temperature=0,
    )
    log.debug(
        "LLM initialized: model=%s, base_url=%s",
        settings.OLLAMA_MODEL,
        settings.OLLAMA_BASE_URL,
    )
    return llm


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


def get_or_create_graph(session_id: str, parsed_data: dict):
    if session_id in _graph_cache:
        return _graph_cache[session_id]
    thresholds = _load_thresholds()
    tools      = build_tools(parsed_data, thresholds)
    llm        = _make_llm()
    graph = create_react_agent(
        model=llm,
        tools=tools,
        prompt=SystemMessage(content=_build_system_prompt(parsed_data)),
        checkpointer=MemorySaver(),
    )
    _graph_cache[session_id] = graph
    return graph


# ---------------------------------------------------------------------------
# DB pipeline state
# ---------------------------------------------------------------------------

class DbPipelineState(TypedDict):
    question:         str
    history:          str
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

  ✓ Revenue by category 2024:
    SELECT fc.name AS category, SUM(fmd.real_value) AS total
    FROM financial_metrics_data fmd
    JOIN financial_types ft ON ft.id = fmd.financial_type_id
    JOIN financial_categories fc ON fc.id = ft.financial_category_id
    WHERE EXTRACT(YEAR FROM fmd.date) = 2024 AND fmd.real_value IS NOT NULL
    GROUP BY fc.name ORDER BY total DESC;

  ✗ NEVER use cashflow_data for revenue questions — cashflow_data stores treasury cash flow,
    NOT operational revenue. "Category" in a revenue question means financial_categories, not cashflow_categories.

CAPEX HIERARCHY — for questions about CAPEX suppliers, projects, spend by month:
  capex_projects: id [PK], supplier_name, direction_name, project_title, contract_no
  capex_data:     id [PK], capex_projects_id (FK → capex_projects.id), month, year,
                  equipment, services, additional_costs

  ✓ Correct query — suppliers by CAPEX spend for a given month:
    SELECT cp.supplier_name,
           SUM(cd.equipment + cd.services + cd.additional_costs) AS total_spend
    FROM capex_data cd
    JOIN capex_projects cp ON cp.id = cd.capex_projects_id
    WHERE cd.year = 2025 AND cd.month = 9
      AND (cd.equipment + cd.services + cd.additional_costs) > 0
    GROUP BY cp.supplier_name
    ORDER BY total_spend DESC;

  ✗ NEVER reference capex_projects columns without the JOIN above.

CASH FLOW HIERARCHY — use ONLY for questions about flux de trésorerie / treasury / liquidity:
  realised_cashflow → cashflow_sections → cashflow_categories → cashflow_subcategories
  Data in cashflow_data: [year, jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]
  Each row's entity_type is 'section', 'category', or 'subcategory'.

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

OUTPUT FORMAT — use EXACTLY this four-section structure:

**Insight**: [1–2 sentences: the key business finding. Include the actual number(s) with thousands separators and FCFA where monetary.]

[Reproduce the data table exactly as provided — do not reformat or omit rows]

**Source**: [list the table(s) queried] | [period covered if visible] | [N row(s) returned]

**Follow-up**: [One specific, actionable question the executive should ask next about this metric — not generic]

STRICT RULES:
- NEVER output SQL, column types, or any technical detail.
- NEVER invent numbers not present in the results.
- If a cell shows "(null)" → write "no data" instead. NEVER write "None" or "null".
- If a column is named "?column?" → label it "Value" in your narrative.
- Do NOT start with "I'm sorry", "Based on", or "The query returned".
- Respond in the same language as the user question.
"""


def _cell(value) -> str:
    return "(null)" if value is None else str(value)


# ---------------------------------------------------------------------------
# Chart spec builder — pure Python, no LLM
# ---------------------------------------------------------------------------

_TIME_COL_NAMES = {
    "month", "year", "date", "period", "quarter",
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

    return {
        "chart_type": chart_type,
        "title":      question[:80],
        "data":       data,
        "x_key":      x_key,
        "y_keys":     y_keys,
        "colors":     _PALETTE[: len(y_keys)],
        "unit":       "FCFA",
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


def _build_ascii_table(rows: list[dict], cols: list[str]) -> str:
    # Rename ugly PostgreSQL default headers
    display_cols = ["value" if c in ("?column?", "?column?") else c for c in cols]
    col_rename   = dict(zip(cols, display_cols))

    sample = rows[:100]
    col_w  = {
        dc: max(len(dc), max((len(_fmt_number(_cell(r.get(c)))) for r in sample), default=0))
        for c, dc in col_rename.items()
    }
    header = " | ".join(dc.ljust(col_w[dc]) for dc in display_cols)
    sep    = "-+-".join("-" * col_w[dc] for dc in display_cols)
    lines  = [header, sep]
    for r in sample:
        lines.append(" | ".join(
            _fmt_number(_cell(r.get(c))).ljust(col_w[dc])
            for c, dc in col_rename.items()
        ))
    if len(rows) > 100:
        lines.append(f"... ({len(rows) - 100} more rows not shown)")
    return "\n".join(lines)


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


def _make_format_answer_node(llm: ChatOllama):
    def format_answer(state: DbPipelineState) -> dict:
        retry     = state.get("retry_count", 0)
        sql_error = state.get("sql_error", "")
        rows      = state.get("rows", [])
        cols      = state.get("cols", [])
        question  = state["question"]
        sql       = state.get("sql", "")

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

        # ── Build table, chart spec, and source context ──────────────────
        table      = _build_ascii_table(rows, cols)
        source     = _source_context(sql, rows)
        chart_spec = _build_chart_spec(cols, rows, question)
        if chart_spec:
            log.info("format_answer: chart_type=%s x=%s y=%s",
                     chart_spec["chart_type"], chart_spec["x_key"], chart_spec["y_keys"])

        log.info("format_answer: narrating %d rows via LLM", len(rows))
        t0 = time.monotonic()
        response = llm.invoke([
            SystemMessage(content=_FMT_SYSTEM),
            HumanMessage(content=(
                f"User question: {question}\n\n"
                f"Query source (for the **Source** line): {source}\n\n"
                f"Result ({len(rows)} row(s)):\n{table}"
            )),
        ])
        log.info("format_answer LLM done in %.1fs", time.monotonic() - t0)
        return {
            "answer":      response.content,
            "chart_specs": [chart_spec] if chart_spec else [],
        }

    return format_answer


# ---------------------------------------------------------------------------
# Build the pipeline graph
# ---------------------------------------------------------------------------

def _build_db_pipeline() -> object:
    llm = _make_llm()
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


_db_pipeline: object | None = None


def _get_db_pipeline() -> object:
    global _db_pipeline
    if _db_pipeline is None:
        _db_pipeline = _build_db_pipeline()
    return _db_pipeline


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
) -> str:
    import asyncio

    thread_id     = f"db:{session_id}:{conversation_id}"
    history_turns = _conversation_history.get(thread_id, [])
    history_text  = "\n".join(history_turns[-6:])

    pipeline = _get_db_pipeline()

    log.info("=== run_db_agent  session=%s  conv=%s ===", session_id, conversation_id)
    log.info("Question: %s", _clip(message))

    state: DbPipelineState = {
        "question":         message,
        "history":          history_text,
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

    t0     = time.monotonic()
    result = await asyncio.to_thread(pipeline.invoke, state)
    log.info("Pipeline finished in %.1fs", time.monotonic() - t0)

    answer      = result.get("answer") or "I was unable to generate a response."
    chart_specs = result.get("chart_specs", [])
    history_turns.append(f"Q: {message}\nA: {answer}")
    _conversation_history[thread_id] = history_turns
    return {"answer": answer, "charts": chart_specs}


async def run_agent(
    session_id: str,
    parsed_data: dict,
    message: str,
    conversation_id: str = "default",
) -> str:
    graph     = get_or_create_graph(session_id, parsed_data)
    thread_id = f"{session_id}:{conversation_id}"
    config    = {"configurable": {"thread_id": thread_id}}

    result = await graph.ainvoke(
        {"messages": [HumanMessage(content=message)]},
        config=config,
    )

    messages = result.get("messages", [])
    for msg in reversed(messages):
        if hasattr(msg, "content") and msg.content and not getattr(msg, "tool_calls", None):
            return msg.content

    return "I was unable to generate a response. Please try again."
