"""
LangGraph ReAct agent for the TBG AI Copilot.

One compiled graph is cached per session.  Each graph has its tools
closed over the session's parsed data, and a MemorySaver so multi-turn
conversations retain history (keyed by thread_id = conversation_id).
"""
from __future__ import annotations

import json
from pathlib import Path

from langchain_core.messages import SystemMessage
from langchain_ollama import ChatOllama
from langgraph.checkpoint.memory import MemorySaver
from langgraph.prebuilt import create_react_agent

from app.agents.db_tools import build_db_tools
from app.agents.tools import build_tools
from app.config.settings import settings

_THRESHOLDS_PATH = Path(__file__).parent.parent / "thresholds.json"

# ---------------------------------------------------------------------------
# Session-scoped graph cache  { session_id -> compiled graph }
# ---------------------------------------------------------------------------
_graph_cache: dict[str, object] = {}


def _load_thresholds() -> dict:
    with open(_THRESHOLDS_PATH) as f:
        return json.load(f)


def _build_system_prompt(parsed_data: dict) -> str:
    sheets = list(parsed_data.get("sheets", {}).keys())
    periods = parsed_data.get("all_periods", [])
    period_range = f"{periods[0]} to {periods[-1]}" if periods else "unknown"
    file_name = parsed_data.get("file", "uploaded file")

    return f"""You are the TBG AI Copilot — an expert financial analyst assistant for Moov Benin.

You have access to data parsed from the TBG (Tableau de Bord de Gestion) report: {file_name}

Available report sheets: {', '.join(sheets)}
Available periods: {period_range}
All monetary values are in Millions CFA (FCFA) unless otherwise stated.

You support two languages: respond in the same language the user writes (French or English).

You cover five core use cases:
1. EXPLAIN THIS REPORT — Answer natural language queries about any metric.
   Always show: Réel | Budget | Écart% | N-1 | YoY%
2. WHY DID X CHANGE? — Decompose variance for any metric by ranking sub-line drivers.
   Identify if it is a one-month spike or an accelerating trend.
3. COMPARE TWO PERIODS — Show what changed MoM across all metrics, ranked by impact.
4. GENERATE CHARTS — Produce a JSON chart specification for any metric set.
5. FLAG CONCERNS — Run a full threshold scan and prioritise critical alerts.

Operational rules:
- Always use tools to retrieve real data before answering; do NOT invent numbers.
- For monetary values: format with thousands separators, one decimal place, unit M CFA.
- For percentages: always show the sign (+/-).
- When a value breaches a threshold, explicitly label it CRITICAL or WARNING.
- After answering, offer the next logical follow-up question.
- Keep responses structured with bullet points or tables where helpful.
"""


def get_or_create_graph(session_id: str, parsed_data: dict):
    """Return a cached compiled graph for the given session, creating if needed."""
    if session_id in _graph_cache:
        return _graph_cache[session_id]

    thresholds = _load_thresholds()
    tools = build_tools(parsed_data, thresholds)

    llm = ChatOllama(
        model=settings.OLLAMA_MODEL,
        base_url=settings.OLLAMA_BASE_URL,
        temperature=0,
    )

    system_message = SystemMessage(content=_build_system_prompt(parsed_data))

    graph = create_react_agent(
        model=llm,
        tools=tools,
        prompt=system_message,
        checkpointer=MemorySaver(),
    )

    _graph_cache[session_id] = graph
    return graph


def _build_db_system_prompt() -> str:
    """
    Build the DB-agent system prompt by loading the live schema from the
    database.  Falls back to a generic prompt if the DB is unreachable.
    """
    try:
        from app.db.schema_inspector import build_schema_context
        schema_block = build_schema_context()
    except Exception as exc:
        schema_block = f"(Schema could not be loaded: {exc})"

    return f"""You are a database AI assistant connected to a PostgreSQL database.

You can answer any natural-language question by writing and executing SQL queries.
You know the full schema (tables, columns, data types, primary keys, and
foreign-key relationships) shown below — use it to write correct JOIN conditions
and filter expressions.

{schema_block}

HOW TO ANSWER QUESTIONS
1. Read the user's question carefully.
2. Identify which tables and columns are relevant using the schema above.
3. Call `sql_query` with a correct SELECT statement.
4. Format the result clearly for the user.
5. If you are unsure about a table's contents, call `get_sample_rows` first.
6. If you need to refresh or drill into schema details, call `describe_table`
   or `get_schema_overview`.

SQL RULES
- Only write SELECT (or WITH … SELECT) statements — no INSERT/UPDATE/DELETE/DDL.
- Always qualify ambiguous column names with the table name.
- Use proper JOIN syntax based on the foreign keys listed in the schema.
- Results are capped at 100 rows; add ORDER BY + LIMIT clauses when appropriate.
- For monetary values: format with thousands separators, 1 decimal place.
- For percentages: always show the sign (+/-).

Respond in the same language the user writes.
After answering, suggest a natural follow-up question.
"""


def get_or_create_db_graph(session_id: str):
    """
    Return a DB-backed compiled graph for the given session.
    The system prompt is built dynamically from the live database schema.
    Cached with a 'db:' prefix to avoid collision with file-based graphs.
    """
    cache_key = f"db:{session_id}"
    if cache_key in _graph_cache:
        return _graph_cache[cache_key]

    tools = build_db_tools()

    llm = ChatOllama(
        model=settings.OLLAMA_MODEL,
        base_url=settings.OLLAMA_BASE_URL,
        temperature=0,
    )

    graph = create_react_agent(
        model=llm,
        tools=tools,
        prompt=SystemMessage(content=_build_db_system_prompt()),
        checkpointer=MemorySaver(),
    )

    _graph_cache[cache_key] = graph
    return graph


def evict_graph(session_id: str) -> None:
    """Remove the compiled graph for a session (called on session deletion)."""
    _graph_cache.pop(session_id, None)


async def run_db_agent(
    session_id: str,
    message: str,
    conversation_id: str = "default",
) -> str:
    """Invoke the DB-backed agent and return the final text response."""
    graph = get_or_create_db_graph(session_id)
    thread_id = f"db:{session_id}:{conversation_id}"
    config = {"configurable": {"thread_id": thread_id}}

    from langchain_core.messages import HumanMessage

    result = await graph.ainvoke(
        {"messages": [HumanMessage(content=message)]},
        config=config,
    )
    messages = result.get("messages", [])
    for msg in reversed(messages):
        if hasattr(msg, "content") and msg.content and not getattr(msg, "tool_calls", None):
            return msg.content
    return "I was unable to generate a response. Please try again."


async def run_agent(
    session_id: str,
    parsed_data: dict,
    message: str,
    conversation_id: str = "default",
) -> str:
    """
    Invoke the agent and return the final text response.

    The conversation_id is used as the LangGraph thread_id so
    multi-turn history is preserved per conversation.
    """
    graph = get_or_create_graph(session_id, parsed_data)
    thread_id = f"{session_id}:{conversation_id}"
    config = {"configurable": {"thread_id": thread_id}}

    from langchain_core.messages import HumanMessage

    result = await graph.ainvoke(
        {"messages": [HumanMessage(content=message)]},
        config=config,
    )

    # The last message in the result is the AI response
    messages = result.get("messages", [])
    for msg in reversed(messages):
        if hasattr(msg, "content") and msg.content and not getattr(msg, "tool_calls", None):
            return msg.content

    return "I was unable to generate a response. Please try again."
