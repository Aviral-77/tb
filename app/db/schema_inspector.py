"""
Introspects a PostgreSQL schema and returns structured metadata about
tables, columns, primary keys, foreign keys, and indexes.

All queries target information_schema / pg_catalog so they work on any
Postgres database without any privileges beyond CONNECT + SELECT.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from functools import lru_cache

from app.db.connection import execute


@dataclass
class ColumnInfo:
    name: str
    data_type: str
    nullable: bool
    default: str | None
    is_pk: bool = False


@dataclass
class ForeignKey:
    column: str
    ref_table: str
    ref_column: str
    constraint_name: str


@dataclass
class TableInfo:
    schema: str
    name: str
    columns: list[ColumnInfo] = field(default_factory=list)
    foreign_keys: list[ForeignKey] = field(default_factory=list)
    row_count_estimate: int | None = None


def _get_search_path_schema() -> str:
    """Return the first non-public schema from the current search_path."""
    rows, _ = execute("SELECT current_schema() AS s")
    return rows[0]["s"] if rows else "public"


def get_tables(schema: str | None = None) -> list[str]:
    """Return all base-table names in the given schema (default: current schema)."""
    schema = schema or _get_search_path_schema()
    rows, _ = execute(
        """
        SELECT table_name
        FROM   information_schema.tables
        WHERE  table_schema = %s
          AND  table_type   = 'BASE TABLE'
        ORDER  BY table_name
        """,
        (schema,),
    )
    return [r["table_name"] for r in rows]


def get_views(schema: str | None = None) -> list[str]:
    """Return all view names in the given schema."""
    schema = schema or _get_search_path_schema()
    rows, _ = execute(
        """
        SELECT table_name
        FROM   information_schema.views
        WHERE  table_schema = %s
        ORDER  BY table_name
        """,
        (schema,),
    )
    return [r["table_name"] for r in rows]


def get_columns(table: str, schema: str | None = None) -> list[ColumnInfo]:
    """Return column metadata for a table."""
    schema = schema or _get_search_path_schema()

    rows, _ = execute(
        """
        SELECT c.column_name,
               c.data_type,
               c.is_nullable,
               c.column_default,
               CASE WHEN pk.column_name IS NOT NULL THEN TRUE ELSE FALSE END AS is_pk
        FROM   information_schema.columns c
        LEFT JOIN (
            SELECT ku.column_name
            FROM   information_schema.table_constraints tc
            JOIN   information_schema.key_column_usage   ku
                   ON  ku.table_schema    = tc.table_schema
                   AND ku.table_name      = tc.table_name
                   AND ku.constraint_name = tc.constraint_name
            WHERE  tc.constraint_type = 'PRIMARY KEY'
              AND  tc.table_schema    = %s
              AND  tc.table_name      = %s
        ) pk ON pk.column_name = c.column_name
        WHERE  c.table_schema = %s
          AND  c.table_name   = %s
        ORDER  BY c.ordinal_position
        """,
        (schema, table, schema, table),
    )
    return [
        ColumnInfo(
            name=r["column_name"],
            data_type=r["data_type"],
            nullable=r["is_nullable"] == "YES",
            default=r["column_default"],
            is_pk=bool(r["is_pk"]),
        )
        for r in rows
    ]


def get_foreign_keys(table: str, schema: str | None = None) -> list[ForeignKey]:
    """Return FK constraints for a table."""
    schema = schema or _get_search_path_schema()
    rows, _ = execute(
        """
        SELECT kcu.constraint_name,
               kcu.column_name,
               ccu.table_name  AS ref_table,
               ccu.column_name AS ref_column
        FROM   information_schema.table_constraints        tc
        JOIN   information_schema.key_column_usage         kcu
               ON  kcu.constraint_name = tc.constraint_name
               AND kcu.table_schema    = tc.table_schema
        JOIN   information_schema.constraint_column_usage  ccu
               ON  ccu.constraint_name = tc.constraint_name
               AND ccu.table_schema    = tc.table_schema
        WHERE  tc.constraint_type = 'FOREIGN KEY'
          AND  tc.table_schema    = %s
          AND  tc.table_name      = %s
        ORDER  BY kcu.column_name
        """,
        (schema, table),
    )
    return [
        ForeignKey(
            constraint_name=r["constraint_name"],
            column=r["column_name"],
            ref_table=r["ref_table"],
            ref_column=r["ref_column"],
        )
        for r in rows
    ]


def get_row_count_estimates(schema: str | None = None) -> dict[str, int]:
    """Return pg_stat estimate of row counts (fast, not exact)."""
    schema = schema or _get_search_path_schema()
    rows, _ = execute(
        """
        SELECT relname AS table_name,
               reltuples::bigint AS estimate
        FROM   pg_class c
        JOIN   pg_namespace n ON n.oid = c.relnamespace
        WHERE  n.nspname = %s
          AND  c.relkind = 'r'
        ORDER  BY relname
        """,
        (schema,),
    )
    return {r["table_name"]: int(r["estimate"]) for r in rows}


def inspect_schema(schema: str | None = None) -> list[TableInfo]:
    """
    Full schema introspection: tables + columns + FK relationships + row estimates.
    Returns a list of TableInfo objects.
    """
    schema = schema or _get_search_path_schema()
    tables = get_tables(schema)
    row_counts = get_row_count_estimates(schema)

    result: list[TableInfo] = []
    for tname in tables:
        info = TableInfo(
            schema=schema,
            name=tname,
            columns=get_columns(tname, schema),
            foreign_keys=get_foreign_keys(tname, schema),
            row_count_estimate=row_counts.get(tname),
        )
        result.append(info)
    return result


def build_schema_context(schema: str | None = None) -> str:
    """
    Build a human + LLM-readable description of the full database schema,
    including tables, columns (with types and PK markers), FK relationships,
    and available views.

    This string is injected into the agent system prompt so the LLM knows
    the full schema without needing to call a tool every time.
    """
    schema = schema or _get_search_path_schema()
    table_infos = inspect_schema(schema)
    views = get_views(schema)

    lines: list[str] = [
        f"DATABASE SCHEMA  (schema: {schema})",
        "=" * 60,
        "",
    ]

    # ── Tables ──────────────────────────────────────────────────────────
    lines.append(f"TABLES ({len(table_infos)}):")
    lines.append("")
    for ti in table_infos:
        row_hint = f"  (~{ti.row_count_estimate:,} rows)" if ti.row_count_estimate else ""
        lines.append(f"  {ti.name}{row_hint}")

        for col in ti.columns:
            pk_marker = " [PK]" if col.is_pk else ""
            null_marker = "" if col.nullable else " NOT NULL"
            lines.append(f"    - {col.name}: {col.data_type}{pk_marker}{null_marker}")

        if ti.foreign_keys:
            lines.append("    Foreign keys:")
            for fk in ti.foreign_keys:
                lines.append(
                    f"      {fk.column} → {fk.ref_table}.{fk.ref_column}"
                )
        lines.append("")

    # ── Views ────────────────────────────────────────────────────────────
    if views:
        lines.append(f"VIEWS ({len(views)}):")
        for v in views:
            lines.append(f"  {v}")
        lines.append("")

    # ── Relationships summary ────────────────────────────────────────────
    all_fks = [
        (ti.name, fk)
        for ti in table_infos
        for fk in ti.foreign_keys
    ]
    if all_fks:
        lines.append("RELATIONSHIPS:")
        for tname, fk in all_fks:
            lines.append(
                f"  {tname}.{fk.column} → {fk.ref_table}.{fk.ref_column}"
            )
        lines.append("")

    return "\n".join(lines)
