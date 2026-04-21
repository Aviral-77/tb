"""
LangChain tools for querying the Digiwise PostgreSQL database.

Two layers:
  1. Schema discovery — let the LLM understand tables, columns, and relationships.
  2. sql_query — execute any SELECT the LLM generates.
"""
from __future__ import annotations

from langchain_core.tools import tool

from app.db.connection import execute
from app.db.schema_inspector import (
    build_schema_context,
    get_columns,
    get_foreign_keys,
    get_tables,
    get_views,
    inspect_schema,
)

_MAX_ROWS = 100


# -----------------------------------------------------------------------
# Formatting helpers
# -----------------------------------------------------------------------

def _fmt(v, decimals: int = 2) -> str:
    if v is None:
        return "NULL"
    try:
        return f"{float(v):,.{decimals}f}"
    except (TypeError, ValueError):
        return str(v)


def _rows_to_text(rows: list[dict], cols: list[str], max_rows: int = _MAX_ROWS) -> str:
    if not rows:
        return "No rows returned."
    truncated = rows[:max_rows]
    header = " | ".join(cols)
    sep = "-" * len(header)
    lines = [header, sep]
    for r in truncated:
        lines.append(" | ".join(str(r.get(c, "")) for c in cols))
    if len(rows) > max_rows:
        lines.append(f"... ({len(rows) - max_rows} more rows truncated)")
    return "\n".join(lines)


# -----------------------------------------------------------------------
# Tool 1 — raw SQL execution
# -----------------------------------------------------------------------
@tool
def sql_query(query: str) -> str:
    """
    Execute any SELECT query against the Digiwise PostgreSQL database and
    return the results as a formatted table.

    The search_path is set to digiwise_schema, public — you can reference
    tables in digiwise_schema without a schema prefix, but use the full
    schema.table form for public schema tables if there is ambiguity.

    Results are capped at 100 rows.

    Args:
        query: A valid PostgreSQL SELECT (or WITH … SELECT) statement.
    """
    try:
        rows, cols = execute(query)
        return _rows_to_text(rows, cols)
    except ValueError as e:
        return f"Error: {e}"
    except Exception as e:
        return f"Database error: {e}"


# -----------------------------------------------------------------------
# Tool 2 — full schema overview
# -----------------------------------------------------------------------
@tool
def get_schema_overview() -> str:
    """
    Return a full description of every table and view in the database,
    including column names, data types, primary keys, foreign-key
    relationships, and approximate row counts.

    Call this when you are unsure which tables exist or how they relate
    to each other before writing a SQL query.
    """
    try:
        return build_schema_context()
    except Exception as e:
        return f"Error retrieving schema: {e}"


# -----------------------------------------------------------------------
# Tool 3 — describe a single table
# -----------------------------------------------------------------------
@tool
def describe_table(table_name: str) -> str:
    """
    Return detailed column and relationship information for a single table.

    Args:
        table_name: exact table name (no schema prefix), e.g. 'financial_metric'
    """
    try:
        cols = get_columns(table_name)
        fks  = get_foreign_keys(table_name)

        if not cols:
            all_tables = get_tables()
            return (
                f"Table '{table_name}' not found. "
                f"Available tables: {', '.join(all_tables)}"
            )

        lines = [f"Table: {table_name}", "", "Columns:"]
        for c in cols:
            pk_m   = " [PK]"              if c.is_pk   else ""
            null_m = ""                   if c.nullable else " NOT NULL"
            def_m  = f" DEFAULT {c.default}" if c.default  else ""
            lines.append(f"  {c.name}: {c.data_type}{pk_m}{null_m}{def_m}")

        if fks:
            lines.append("")
            lines.append("Foreign keys:")
            for fk in fks:
                lines.append(f"  {fk.column} → {fk.ref_table}.{fk.ref_column}")

        return "\n".join(lines)
    except Exception as e:
        return f"Error describing table: {e}"


# -----------------------------------------------------------------------
# Tool 4 — list all tables
# -----------------------------------------------------------------------
@tool
def list_all_tables() -> str:
    """
    List every table and view in the database with a one-line summary
    (column count and approximate row count).

    Use this for a quick orientation before calling get_schema_overview
    or describe_table.
    """
    try:
        tables = inspect_schema()
        views  = get_views()

        lines = ["Tables:"]
        for ti in tables:
            n_cols    = len(ti.columns)
            rows_hint = f"~{ti.row_count_estimate:,} rows" if ti.row_count_estimate else "? rows"
            lines.append(f"  {ti.name:<40} {n_cols} columns  {rows_hint}")

        if views:
            lines.append("")
            lines.append("Views:")
            for v in views:
                lines.append(f"  {v}")

        return "\n".join(lines)
    except Exception as e:
        return f"Error listing tables: {e}"


# -----------------------------------------------------------------------
# Tool 5 — sample rows from a table
# -----------------------------------------------------------------------
@tool
def get_sample_rows(table_name: str, limit: int = 5) -> str:
    """
    Return a few sample rows from a table to understand real data shapes
    and values before writing a query.

    Args:
        table_name: exact table name, e.g. 'financial_metrics_data'
        limit:      number of rows to return (default 5, max 20)
    """
    try:
        safe_limit = min(max(1, limit), 20)
        known = get_tables() + get_views()
        if table_name not in known:
            return (
                f"Table '{table_name}' not found. "
                f"Available: {', '.join(known)}"
            )
        rows, cols = execute(f'SELECT * FROM "{table_name}" LIMIT %s', (safe_limit,))
        return _rows_to_text(rows, cols)
    except Exception as e:
        return f"Error fetching sample rows: {e}"


# -----------------------------------------------------------------------
# Factory
# -----------------------------------------------------------------------
def build_db_tools() -> list:
    return [
        get_schema_overview,
        list_all_tables,
        describe_table,
        get_sample_rows,
        sql_query,
    ]
