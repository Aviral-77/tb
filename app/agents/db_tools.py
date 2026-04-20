"""
LangChain tools that query the TBG PostgreSQL database.

Two layers:
  1. sql_query — lets the LLM write any SELECT statement for complex questions.
  2. Structured helpers — reliable shortcuts for the 5 core scenarios that
     avoid the LLM needing to know exact column names.
"""
from __future__ import annotations

import json

from langchain_core.tools import tool

from app.db.connection import execute

_MAX_ROWS = 100          # cap raw sql_query results
_SEARCH_PATH = "tbg"    # already set at pool level, but kept as reminder


# -----------------------------------------------------------------------
# Formatting helpers
# -----------------------------------------------------------------------

def _fmt(v, decimals: int = 2) -> str:
    if v is None:
        return "NULL"
    try:
        f = float(v)
        return f"{f:,.{decimals}f}"
    except (TypeError, ValueError):
        return str(v)


def _pct(v) -> str:
    if v is None:
        return "NULL"
    try:
        f = float(v) * 100 if abs(float(v)) < 1 else float(v)
        sign = "+" if f > 0 else ""
        return f"{sign}{f:.1f}%"
    except (TypeError, ValueError):
        return str(v)


def _rows_to_text(rows: list[dict], cols: list[str], max_rows: int = _MAX_ROWS) -> str:
    if not rows:
        return "No rows returned."
    truncated = rows[:max_rows]
    header = " | ".join(cols)
    sep    = "-" * len(header)
    lines  = [header, sep]
    for r in truncated:
        lines.append(" | ".join(str(r.get(c, "")) for c in cols))
    if len(rows) > max_rows:
        lines.append(f"... ({len(rows) - max_rows} more rows truncated)")
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 1 — raw SQL (SELECT only, capped at 100 rows)
# -----------------------------------------------------------------------
@tool
def sql_query(query: str) -> str:
    """
    Execute any SELECT query against the TBG PostgreSQL database and return
    the results as a formatted table.  Use this for custom or complex questions
    that the other tools cannot answer.

    Schema (search_path = tbg):
      tbg_data(sheet, metric_key, metric_label, period DATE,
               reel, budget, ecart_budget, n1_reel, evol_pct)
      metric_definitions(sheet, metric_key, metric_code, metric_label)

    Views (same columns as tbg_data, pre-filtered by sheet):
      pnl_conso, ca_mobile, opex_consolides, capex_consolides,
      mobile_money, parc_mobile, marge_mobile, trafic_mobile,
      data_mobile, cash_conso

    Analytical views:
      latest_snapshot   — most recent period per metric
      yoy_summary       — adds yoy_pct and vs_budget_pct columns
      threshold_alerts  — adds severity: CRITICAL / WARNING / OK

    Results are capped at 100 rows.

    Args:
        query: A valid PostgreSQL SELECT statement.
    """
    try:
        rows, cols = execute(query)
        return _rows_to_text(rows, cols)
    except ValueError as e:
        return f"Error: {e}"
    except Exception as e:
        return f"Database error: {e}"


# -----------------------------------------------------------------------
# Tool 2 — list sheets
# -----------------------------------------------------------------------
@tool
def list_sheets() -> str:
    """
    List all available TBG report sheets in the database with their
    period range and metric count.
    """
    rows, cols = execute("""
        SELECT sheet,
               COUNT(DISTINCT metric_key)       AS metrics,
               MIN(period)::text                AS first_period,
               MAX(period)::text                AS last_period,
               COUNT(*)                         AS total_rows
        FROM   tbg_data
        GROUP  BY sheet
        ORDER  BY sheet
    """)
    lines = ["Available TBG sheets in the database:", ""]
    for r in rows:
        lines.append(
            f"  {r['sheet']:<22} {r['metrics']} metrics  "
            f"({r['first_period']} → {r['last_period']})"
        )
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 3 — list metrics in a sheet
# -----------------------------------------------------------------------
@tool
def list_metrics(sheet_name: str) -> str:
    """
    List all metric codes and labels available in a given sheet.

    Args:
        sheet_name: e.g. 'pnl_conso', 'ca_mobile', 'opex_consolides'
    """
    rows, _ = execute("""
        SELECT metric_key, metric_code, metric_label
        FROM   metric_definitions
        WHERE  sheet = %s
        ORDER  BY metric_key
    """, (sheet_name,))
    if not rows:
        return f"Sheet '{sheet_name}' not found."
    lines = [f"Metrics in '{sheet_name}':"]
    for r in rows:
        code = f"[{r['metric_code']}]" if r['metric_code'] else ""
        lines.append(f"  {r['metric_key']:<12} {code:<10} {r['metric_label']}")
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 4 — query a single metric for one period
# -----------------------------------------------------------------------
@tool
def query_metric(sheet_name: str, metric_key: str, period: str) -> str:
    """
    Return Réel, Budget, Écart, N-1, and YoY% for a specific metric and period.

    Args:
        sheet_name:  e.g. 'pnl_conso'
        metric_key:  metric code like 'PL1' or label substring like 'EBITDA'
        period:      YYYY-MM, e.g. '2025-06'
    """
    period_date = period + "-01" if len(period) == 7 else period
    rows, _ = execute("""
        SELECT metric_label, period::text,
               reel, budget, ecart_budget, n1_reel, evol_pct,
               CASE WHEN n1_reel <> 0
                    THEN ROUND((reel - n1_reel) / ABS(n1_reel) * 100, 2)
               END AS yoy_pct,
               CASE WHEN budget <> 0
                    THEN ROUND((reel - budget) / ABS(budget) * 100, 2)
               END AS vs_budget_pct
        FROM   tbg_data
        WHERE  sheet = %s
          AND  (metric_key = %s OR metric_label ILIKE %s)
          AND  period = %s::date
        LIMIT 1
    """, (sheet_name, metric_key, f"%{metric_key}%", period_date))

    if not rows:
        return f"No data found for metric '{metric_key}' in '{sheet_name}' at {period}."

    r = rows[0]
    sign = lambda v: f"+{v}" if v and float(v) > 0 else str(v)
    lines = [
        f"{r['metric_label']} ({r['period'][:7]}):",
        f"  Réel (Actual) : {_fmt(r['reel'])} M CFA",
        f"  Budget        : {_fmt(r['budget'])} M CFA",
        f"  Écart/Budget  : {_fmt(r['ecart_budget'])} M CFA  ({_fmt(r['vs_budget_pct'], 1)}%)",
        f"  N-1 Réel      : {_fmt(r['n1_reel'])} M CFA",
        f"  YoY change    : {_fmt(r['yoy_pct'], 1)}%",
    ]
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 5 — metric trend (all periods)
# -----------------------------------------------------------------------
@tool
def get_metric_trend(sheet_name: str, metric_key: str) -> str:
    """
    Return the full month-by-month trend for a metric: Réel, Budget, N-1, YoY%.
    Use this for Scenario 2 (is this a spike or a trend?) and Scenario 1.

    Args:
        sheet_name: e.g. 'opex_consolides'
        metric_key: metric code or label substring
    """
    rows, _ = execute("""
        SELECT period::text,
               reel, budget, n1_reel,
               CASE WHEN n1_reel <> 0
                    THEN ROUND((reel - n1_reel) / ABS(n1_reel) * 100, 2)
               END AS yoy_pct,
               CASE WHEN budget <> 0
                    THEN ROUND((reel - budget) / ABS(budget) * 100, 2)
               END AS vs_bgt_pct
        FROM   tbg_data
        WHERE  sheet = %s
          AND  (metric_key = %s OR metric_label ILIKE %s)
          AND  reel IS NOT NULL
        ORDER  BY period
    """, (sheet_name, metric_key, f"%{metric_key}%"))

    if not rows:
        return f"No data for '{metric_key}' in '{sheet_name}'."

    label = sheet_name + "/" + metric_key
    lines = [f"Trend: {label}", "",
             f"{'Period':<10} {'Réel':>12} {'Budget':>12} {'N-1':>12} {'YoY%':>8} {'vsBgt%':>8}",
             "-" * 68]
    for r in rows:
        lines.append(
            f"{r['period'][:7]:<10} {_fmt(r['reel']):>12} {_fmt(r['budget']):>12} "
            f"{_fmt(r['n1_reel']):>12} {_fmt(r['yoy_pct'],1):>8} {_fmt(r['vs_bgt_pct'],1):>8}"
        )
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 6 — variance decomposition (why did X change?)
# -----------------------------------------------------------------------
@tool
def analyze_variance(sheet_name: str, period: str, top_n: int = 15) -> str:
    """
    Rank ALL metrics in a sheet by their absolute YoY change for a period.
    Use this for Scenario 2: "Why did X change?"

    Args:
        sheet_name: e.g. 'pnl_conso' or 'opex_consolides'
        period:     YYYY-MM, e.g. '2025-06'
        top_n:      number of top contributors to show (default 15)
    """
    period_date = period + "-01" if len(period) == 7 else period
    rows, _ = execute("""
        SELECT metric_label,
               reel, n1_reel, budget,
               reel - n1_reel AS delta,
               CASE WHEN n1_reel <> 0
                    THEN ROUND((reel - n1_reel) / ABS(n1_reel) * 100, 2)
               END AS yoy_pct,
               CASE WHEN budget <> 0
                    THEN ROUND((reel - budget) / ABS(budget) * 100, 2)
               END AS vs_bgt_pct
        FROM   tbg_data
        WHERE  sheet = %s
          AND  period = %s::date
          AND  reel IS NOT NULL
          AND  n1_reel IS NOT NULL
        ORDER  BY ABS(reel - n1_reel) DESC
        LIMIT  %s
    """, (sheet_name, period_date, top_n))

    if not rows:
        return f"No data for '{sheet_name}' at {period}."

    lines = [f"Variance decomposition — '{sheet_name}' — {period}",
             f"Ranked by absolute YoY impact:", ""]
    for i, r in enumerate(rows, 1):
        arrow = "▲" if float(r['delta'] or 0) > 0 else "▼"
        lines.append(
            f"  {i:2}. {arrow} {r['metric_label'][:45]:<45} "
            f"Δ {_fmt(r['delta'])} M  ({_fmt(r['yoy_pct'],1)}% YoY | {_fmt(r['vs_bgt_pct'],1)}% vs Bgt)"
        )
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 7 — compare two periods
# -----------------------------------------------------------------------
@tool
def compare_periods(sheet_name: str, period1: str, period2: str, top_n: int = 20) -> str:
    """
    Compare every metric in a sheet between two months. Ranked by absolute change.
    Use this for Scenario 3.

    Args:
        sheet_name: e.g. 'pnl_conso'
        period1:    earlier period YYYY-MM
        period2:    later period YYYY-MM
        top_n:      rows to return (default 20)
    """
    p1 = period1 + "-01" if len(period1) == 7 else period1
    p2 = period2 + "-01" if len(period2) == 7 else period2
    rows, _ = execute("""
        SELECT a.metric_label,
               a.reel AS reel1, b.reel AS reel2,
               b.reel - a.reel AS delta,
               CASE WHEN a.reel <> 0
                    THEN ROUND((b.reel - a.reel) / ABS(a.reel) * 100, 2)
               END AS pct_change
        FROM   tbg_data a
        JOIN   tbg_data b
               ON  a.sheet = b.sheet
               AND a.metric_key = b.metric_key
        WHERE  a.sheet  = %s
          AND  a.period = %s::date
          AND  b.period = %s::date
          AND  a.reel IS NOT NULL
          AND  b.reel IS NOT NULL
        ORDER  BY ABS(b.reel - a.reel) DESC
        LIMIT  %s
    """, (sheet_name, p1, p2, top_n))

    if not rows:
        return f"No comparable data in '{sheet_name}' for {period1} vs {period2}."

    lines = [f"Period comparison — '{sheet_name}'",
             f"  {period1}  →  {period2}  (ranked by absolute change)", ""]
    for r in rows:
        arrow = "▲" if float(r['delta'] or 0) > 0 else "▼"
        lines.append(
            f"  {arrow} {r['metric_label'][:45]:<45} "
            f"{_fmt(r['reel1'])} → {_fmt(r['reel2'])}  "
            f"(Δ {_fmt(r['delta'])}, {_fmt(r['pct_change'],1)}%)"
        )
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 8 — alert scan across all sheets
# -----------------------------------------------------------------------
@tool
def check_all_alerts(period: str) -> str:
    """
    Scan every metric in every sheet against YoY thresholds for a given period.
    Uses the threshold_alerts view. Use this for Scenario 5.

    Args:
        period: YYYY-MM, e.g. '2025-12'
    """
    period_date = period + "-01" if len(period) == 7 else period
    rows, _ = execute("""
        SELECT sheet, metric_label, period::text,
               reel, n1_reel, yoy_pct, severity
        FROM   threshold_alerts
        WHERE  period = %s::date
        ORDER  BY
            CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'WARNING' THEN 2 ELSE 3 END,
            ABS(yoy_pct) DESC
    """, (period_date,))

    if not rows:
        return f"No alert data found for period {period}."

    critical = [r for r in rows if r['severity'] == 'CRITICAL']
    warning  = [r for r in rows if r['severity'] == 'WARNING']
    ok       = [r for r in rows if r['severity'] == 'OK']

    lines = [f"=== ALERT SCAN — {period} ===", ""]
    if critical:
        lines.append(f"🔴 CRITICAL ({len(critical)}):")
        for r in critical:
            lines.append(
                f"   [{r['sheet']}] {r['metric_label'][:45]:<45} "
                f"Réel={_fmt(r['reel'])}  N-1={_fmt(r['n1_reel'])}  YoY={_fmt(r['yoy_pct'],1)}%"
            )
        lines.append("")
    if warning:
        lines.append(f"🟡 WARNING ({len(warning)}):")
        for r in warning:
            lines.append(
                f"   [{r['sheet']}] {r['metric_label'][:45]:<45} "
                f"Réel={_fmt(r['reel'])}  N-1={_fmt(r['n1_reel'])}  YoY={_fmt(r['yoy_pct'],1)}%"
            )
        lines.append("")
    lines.append(f"✅ OK: {len(ok)} metrics within thresholds")
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 9 — search metric by keyword
# -----------------------------------------------------------------------
@tool
def search_metrics(keyword: str) -> str:
    """
    Search for metrics whose label contains a keyword, across all sheets.
    Useful when you don't know the exact metric_key.

    Args:
        keyword: word or phrase to search, e.g. 'EBITDA', 'personnel', 'mobile money'
    """
    rows, _ = execute("""
        SELECT sheet, metric_key, metric_code, metric_label
        FROM   metric_definitions
        WHERE  metric_label ILIKE %s
            OR metric_key   ILIKE %s
        ORDER  BY sheet, metric_key
        LIMIT  40
    """, (f"%{keyword}%", f"%{keyword}%"))

    if not rows:
        return f"No metrics found matching '{keyword}'."

    lines = [f"Metrics matching '{keyword}':"]
    for r in rows:
        lines.append(f"  [{r['sheet']}]  {r['metric_key']:<12}  {r['metric_label']}")
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 10 — cross-sheet comparison (all sheets, two periods)
# -----------------------------------------------------------------------
@tool
def compare_all_sheets(period1: str, period2: str, top_n: int = 25) -> str:
    """
    Compare two periods across ALL sheets, ranked by absolute % change.
    Best for Scenario 3 full-file mode.

    Args:
        period1: earlier period YYYY-MM
        period2: later period YYYY-MM
        top_n:   number of top movers to return (default 25)
    """
    p1 = period1 + "-01" if len(period1) == 7 else period1
    p2 = period2 + "-01" if len(period2) == 7 else period2
    rows, _ = execute("""
        SELECT a.sheet, a.metric_label,
               a.reel AS reel1, b.reel AS reel2,
               b.reel - a.reel AS delta,
               ROUND((b.reel - a.reel) / NULLIF(ABS(a.reel), 0) * 100, 2) AS pct_change
        FROM   tbg_data a
        JOIN   tbg_data b
               ON  a.sheet = b.sheet
               AND a.metric_key = b.metric_key
        WHERE  a.period = %s::date
          AND  b.period = %s::date
          AND  a.reel IS NOT NULL
          AND  b.reel IS NOT NULL
          AND  a.reel <> 0
        ORDER  BY ABS(b.reel - a.reel) DESC
        LIMIT  %s
    """, (p1, p2, top_n))

    if not rows:
        return f"No data for cross-sheet comparison {period1} vs {period2}."

    lines = [f"Cross-sheet comparison: {period1} → {period2}",
             f"Top {top_n} movers by absolute change:", ""]
    for r in rows:
        arrow = "▲" if float(r['delta'] or 0) > 0 else "▼"
        lines.append(
            f"  {arrow} [{r['sheet']:<22}] {r['metric_label'][:40]:<40} "
            f"{_fmt(r['reel1'])} → {_fmt(r['reel2'])}  ({_fmt(r['pct_change'],1)}%)"
        )
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Factory — returns the full tool list for the DB agent
# -----------------------------------------------------------------------
def build_db_tools() -> list:
    return [
        sql_query,
        list_sheets,
        list_metrics,
        query_metric,
        get_metric_trend,
        analyze_variance,
        compare_periods,
        check_all_alerts,
        search_metrics,
        compare_all_sheets,
    ]
