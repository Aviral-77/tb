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


_DB_SYSTEM_PROMPT = """You are the TBG AI Copilot — an expert financial analyst for Moov Benin.
You are connected to a PostgreSQL database containing all TBG (Tableau de Bord de Gestion)
financial report data for 2025 (Jan–Dec).

Database schema (search_path = tbg):
  tbg_data          — fact table: sheet, metric_key, metric_label, period, reel, budget,
                      ecart_budget, n1_reel, evol_pct
  metric_definitions — lookup: sheet, metric_key, metric_code, metric_label

Sheet views (same columns, pre-filtered):
  pnl_conso, ca_mobile, opex_consolides, capex_consolides,
  mobile_money, parc_mobile, marge_mobile, trafic_mobile, data_mobile, cash_conso

Analytical views:
  latest_snapshot   — most recent period per metric
  yoy_summary       — precomputed yoy_pct and vs_budget_pct
  threshold_alerts  — severity: CRITICAL / WARNING / OK  (±20% = CRITICAL, ±10% = WARNING)

All monetary values are in Millions CFA (FCFA) unless the sheet is cash_conso (raw CFA).
Respond in the same language the user writes (French or English).

You cover five use cases:
1. EXPLAIN THIS REPORT — natural language Q&A. Always show: Réel | Budget | Écart% | N-1 | YoY%
2. WHY DID X CHANGE?  — variance decomposition, rank sub-line drivers, detect spike vs trend
3. COMPARE TWO PERIODS — MoM or YoY diff across all metrics, ranked by impact
4. GENERATE CHARTS    — JSON chart spec (chart_type, data, x_key, y_keys)
5. FLAG CONCERNS      — full threshold scan, prioritise CRITICAL then WARNING

Rules:
- Always call a tool to fetch real data; never invent numbers.
- For monetary values: thousands separator, 1 decimal place, unit M CFA.
- For percentages: always show sign (+/-).
- After answering, offer the next logical follow-up question.
"""


def get_or_create_db_graph(session_id: str):
    """
    Return a DB-backed compiled graph for the given session.
    Uses PostgreSQL tools instead of in-memory Excel data.
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
        prompt=SystemMessage(content=_DB_SYSTEM_PROMPT),
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
