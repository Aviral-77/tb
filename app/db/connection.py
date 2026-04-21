"""
Thread-safe psycopg2 connection pool for the TBG database.

All queries run inside the `tbg` schema automatically.
"""
from __future__ import annotations

import psycopg2
import psycopg2.extras
from psycopg2 import pool as pg_pool

from app.config.settings import settings

_pool: pg_pool.ThreadedConnectionPool | None = None


def get_pool() -> pg_pool.ThreadedConnectionPool:
    global _pool
    if _pool is None:
        _pool = pg_pool.ThreadedConnectionPool(
            minconn=1,
            maxconn=10,
            dsn=settings.DATABASE_URL,
            options="-c search_path=digiwise_schema,public",
        )
    return _pool


def execute(sql: str, params: tuple = ()) -> tuple[list[dict], list[str]]:
    """
    Run a single SQL statement and return (rows_as_dicts, column_names).
    Always operates inside the tbg schema.
    Only SELECT / WITH statements are allowed.
    """
    normalised = sql.strip().upper().lstrip("(")
    if not (normalised.startswith("SELECT") or normalised.startswith("WITH")):
        raise ValueError("Only SELECT queries are permitted.")

    p = get_pool()
    conn = p.getconn()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params or None)
            cols = [d.name for d in cur.description] if cur.description else []
            rows = [dict(r) for r in cur.fetchall()]
        return rows, cols
    finally:
        p.putconn(conn)


def ping() -> bool:
    """Return True if the DB is reachable."""
    try:
        execute("SELECT 1 AS ok")
        return True
    except Exception:
        return False
