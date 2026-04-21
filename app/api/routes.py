"""
FastAPI route definitions for the TBG AI Copilot.

File-based endpoints (Excel upload)
------------------------------------
POST   /api/v1/sessions                      Upload one TBG Excel file, create session
POST   /api/v1/sessions/compare              Upload two files for period comparison
POST   /api/v1/sessions/{id}/chat            Chat with parsed data
GET    /api/v1/sessions/{id}                 Session metadata
GET    /api/v1/sessions/{id}/sheets          List available sheets
GET    /api/v1/sessions/{id}/metrics/{sheet} List metrics for a sheet
DELETE /api/v1/sessions/{id}                 Delete session
GET    /api/v1/health                        Health check

Database-backed endpoints (PostgreSQL)
---------------------------------------
POST   /api/v1/db/chat                       Chat directly against the Postgres DB
GET    /api/v1/db/health                     Check DB connectivity
GET    /api/v1/db/sheets                     List sheets available in the DB
GET    /api/v1/db/metrics/{sheet}            List metrics for a sheet (from DB)
"""
from __future__ import annotations

import tempfile
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status

from app.agents.graph import evict_graph, run_agent, run_db_agent
from app.db.connection import execute as db_execute, ping as db_ping
from app.models.schemas import (
    ChatRequest,
    ChatResponse,
    CompareUploadResponse,
    HealthResponse,
    MetricListItem,
    MetricListResponse,
    SessionInfo,
    UploadResponse,
)
from app.parsers.excel_parser import parse_tbg_file

router = APIRouter(prefix="/api/v1")

# ---------------------------------------------------------------------------
# In-memory session store  { session_id -> SessionData }
# ---------------------------------------------------------------------------
_sessions: dict[str, dict] = {}


def _require_session(session_id: str) -> dict:
    session = _sessions.get(session_id)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Session '{session_id}' not found or expired.",
        )
    return session


async def _save_and_parse(upload: UploadFile) -> tuple[str, dict]:
    """Save uploaded file to a temp path and parse it. Returns (path, parsed_data)."""
    suffix = Path(upload.filename or "file.xlsx").suffix or ".xlsx"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        content = await upload.read()
        tmp.write(content)
        tmp_path = tmp.name
    parsed = parse_tbg_file(tmp_path)
    return tmp_path, parsed


# ---------------------------------------------------------------------------
# POST /api/v1/sessions  — single file upload
# ---------------------------------------------------------------------------
@router.post("/sessions", response_model=UploadResponse, status_code=status.HTTP_201_CREATED)
async def create_session(file: Annotated[UploadFile, File(description="TBG Excel file (.xlsx)")]):
    """
    Upload a single TBG Excel file.  Returns a session_id used for all
    subsequent chat and metadata requests.
    """
    if not (upload_filename := file.filename or ""):
        raise HTTPException(status_code=400, detail="File has no filename.")

    _, parsed = await _save_and_parse(file)

    if not parsed.get("sheets"):
        raise HTTPException(
            status_code=422,
            detail="Could not parse any TBG sheets from the uploaded file. "
                   "Ensure it is a valid TBG Excel export.",
        )

    session_id = str(uuid.uuid4())
    _sessions[session_id] = {
        "session_id": session_id,
        "files": [upload_filename],
        "parsed_data": parsed,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }

    return UploadResponse(
        session_id=session_id,
        file_name=upload_filename,
        sheets_parsed=list(parsed["sheets"].keys()),
        periods_available=parsed.get("all_periods", []),
        message=f"Session created. {len(parsed['sheets'])} reports parsed, "
                f"{len(parsed.get('all_periods', []))} periods available.",
    )


# ---------------------------------------------------------------------------
# POST /api/v1/sessions/compare  — two-file upload for period comparison
# ---------------------------------------------------------------------------
@router.post(
    "/sessions/compare",
    response_model=CompareUploadResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_comparison_session(
    file1: Annotated[UploadFile, File(description="First TBG Excel file (earlier period)")],
    file2: Annotated[UploadFile, File(description="Second TBG Excel file (later period)")],
):
    """
    Upload two TBG Excel files for cross-period comparison (Scenario 3).
    Both files are merged into a single parsed dataset keyed by period.
    """
    _, parsed1 = await _save_and_parse(file1)
    _, parsed2 = await _save_and_parse(file2)

    if not parsed1.get("sheets") or not parsed2.get("sheets"):
        raise HTTPException(status_code=422, detail="One or both files could not be parsed.")

    # Merge sheets: for each sheet key, merge the metrics dicts
    merged_sheets: dict = {}
    all_sheet_keys = set(parsed1["sheets"]) | set(parsed2["sheets"])

    for sk in all_sheet_keys:
        s1 = parsed1["sheets"].get(sk, {"periods": [], "metrics": {}})
        s2 = parsed2["sheets"].get(sk, {"periods": [], "metrics": {}})

        merged_metrics: dict = {}
        all_metric_keys = set(s1["metrics"]) | set(s2["metrics"])

        for mk in all_metric_keys:
            m1 = s1["metrics"].get(mk)
            m2 = s2["metrics"].get(mk)
            if m1 and m2:
                merged_values = {**m1["values"], **m2["values"]}
                merged_metrics[mk] = {**m1, "values": merged_values}
            else:
                merged_metrics[mk] = (m1 or m2)

        all_periods = sorted(set(s1.get("periods", [])) | set(s2.get("periods", [])))
        merged_sheets[sk] = {"periods": all_periods, "metrics": merged_metrics}

    all_periods_global = sorted(
        set(parsed1.get("all_periods", [])) | set(parsed2.get("all_periods", []))
    )

    merged_data = {
        "file": f"{file1.filename} + {file2.filename}",
        "files": [file1.filename, file2.filename],
        "sheets": merged_sheets,
        "all_periods": all_periods_global,
    }

    session_id = str(uuid.uuid4())
    _sessions[session_id] = {
        "session_id": session_id,
        "files": [file1.filename, file2.filename],
        "parsed_data": merged_data,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }

    return CompareUploadResponse(
        session_id=session_id,
        file1_name=file1.filename or "",
        file2_name=file2.filename or "",
        sheets_parsed=list(merged_sheets.keys()),
        periods_available=all_periods_global,
        message=f"Comparison session created. {len(merged_sheets)} sheets, "
                f"{len(all_periods_global)} periods merged.",
    )


# ---------------------------------------------------------------------------
# POST /api/v1/sessions/{session_id}/chat
# ---------------------------------------------------------------------------
@router.post("/sessions/{session_id}/chat", response_model=ChatResponse)
async def chat(session_id: str, request: ChatRequest):
    """
    Send a message to the TBG AI Copilot for the given session.

    Covers all five scenarios:
    1. Natural language Q&A about metrics
    2. Root-cause variance analysis
    3. Period comparison
    4. Chart specification generation
    5. Anomaly / alert detection
    """
    session = _require_session(session_id)
    parsed_data = session["parsed_data"]

    try:
        response_text = await run_agent(
            session_id=session_id,
            parsed_data=parsed_data,
            message=request.message,
            conversation_id=request.conversation_id,
        )
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Agent error: {str(exc)}",
        ) from exc

    return ChatResponse(
        response=response_text,
        conversation_id=request.conversation_id,
        session_id=session_id,
    )


# ---------------------------------------------------------------------------
# GET /api/v1/sessions/{session_id}
# ---------------------------------------------------------------------------
@router.get("/sessions/{session_id}", response_model=SessionInfo)
async def get_session(session_id: str):
    """Return metadata for the given session."""
    session = _require_session(session_id)
    parsed = session["parsed_data"]
    return SessionInfo(
        session_id=session_id,
        files=session.get("files", []),
        sheets=list(parsed.get("sheets", {}).keys()),
        periods=parsed.get("all_periods", []),
        created_at=session.get("created_at", ""),
    )


# ---------------------------------------------------------------------------
# GET /api/v1/sessions/{session_id}/sheets
# ---------------------------------------------------------------------------
@router.get("/sessions/{session_id}/sheets")
async def list_sheets(session_id: str):
    """List all parsed report sheets and their period coverage."""
    session = _require_session(session_id)
    parsed = session["parsed_data"]
    result = {}
    for sk, sd in parsed.get("sheets", {}).items():
        result[sk] = {
            "periods": sd.get("periods", []),
            "metric_count": len(sd.get("metrics", {})),
        }
    return {"session_id": session_id, "sheets": result}


# ---------------------------------------------------------------------------
# GET /api/v1/sessions/{session_id}/metrics/{sheet_name}
# ---------------------------------------------------------------------------
@router.get("/sessions/{session_id}/metrics/{sheet_name}", response_model=MetricListResponse)
async def list_metrics(session_id: str, sheet_name: str):
    """List all metrics available in a specific sheet for this session."""
    session = _require_session(session_id)
    parsed = session["parsed_data"]
    sheet = parsed.get("sheets", {}).get(sheet_name)
    if not sheet:
        available = list(parsed.get("sheets", {}).keys())
        raise HTTPException(
            status_code=404,
            detail=f"Sheet '{sheet_name}' not found. Available: {available}",
        )

    items = [
        MetricListItem(
            code=m.get("code"),
            label=m["label"],
            periods_available=sorted(m["values"].keys()),
        )
        for m in sheet["metrics"].values()
    ]
    return MetricListResponse(sheet=sheet_name, metrics=items)


# ---------------------------------------------------------------------------
# DELETE /api/v1/sessions/{session_id}
# ---------------------------------------------------------------------------
@router.delete("/sessions/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_session(session_id: str):
    """Delete a session and free its memory."""
    _require_session(session_id)
    _sessions.pop(session_id, None)
    evict_graph(session_id)


# ---------------------------------------------------------------------------
# GET /api/v1/health
# ---------------------------------------------------------------------------
@router.get("/health", response_model=HealthResponse)
async def health():
    """Health check."""
    from app.config.settings import settings
    return HealthResponse(
        status="ok",
        version=settings.APP_VERSION,
        active_sessions=len(_sessions),
    )


# ===========================================================================
#  DATABASE-BACKED ROUTES  /api/v1/db/*
# ===========================================================================

# ---------------------------------------------------------------------------
# POST /api/v1/db/chat
# ---------------------------------------------------------------------------
@router.post("/db/chat", response_model=ChatResponse)
async def db_chat(request: ChatRequest):
    """
    Chat with the TBG AI Copilot backed by PostgreSQL.
    No file upload needed — the agent queries the database directly.

    Use conversation_id to maintain multi-turn history.
    """
    # Use a fixed "db" session so the graph is shared across all DB chats
    # but each conversation_id gets its own thread in MemorySaver.
    session_id = "db-global"
    try:
        response_text = await run_db_agent(
            session_id=session_id,
            message=request.message,
            conversation_id=request.conversation_id,
        )
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Agent error: {str(exc)}",
        ) from exc

    return ChatResponse(
        response=response_text,
        conversation_id=request.conversation_id,
        session_id=session_id,
    )


# ---------------------------------------------------------------------------
# GET /api/v1/db/health
# ---------------------------------------------------------------------------
@router.get("/db/health")
async def db_health():
    """Check that the PostgreSQL database is reachable."""
    import asyncio
    reachable = await asyncio.to_thread(db_ping)
    if not reachable:
        raise HTTPException(
            status_code=503,
            detail="Database unreachable. Check DATABASE_URL and that the Postgres container is running.",
        )
    rows, _ = await asyncio.to_thread(
        db_execute,
        "SELECT COUNT(*) AS total_rows, COUNT(DISTINCT sheet) AS sheets FROM tbg_data",
    )
    return {"status": "ok", "database": "connected", **rows[0]}


# ---------------------------------------------------------------------------
# GET /api/v1/db/sheets
# ---------------------------------------------------------------------------
@router.get("/db/sheets")
async def db_list_sheets():
    """List all TBG sheets available in the database with period range."""
    import asyncio
    rows, _ = await asyncio.to_thread(db_execute, """
        SELECT sheet,
               COUNT(DISTINCT metric_key)  AS metrics,
               MIN(period)::text           AS first_period,
               MAX(period)::text           AS last_period
        FROM   tbg_data
        GROUP  BY sheet
        ORDER  BY sheet
    """)
    return {"sheets": rows}


# ---------------------------------------------------------------------------
# GET /api/v1/db/metrics/{sheet_name}
# ---------------------------------------------------------------------------
@router.get("/db/metrics/{sheet_name}")
async def db_list_metrics(sheet_name: str):
    """List all metrics for a sheet directly from the database."""
    import asyncio
    rows, _ = await asyncio.to_thread(db_execute, """
        SELECT metric_key, metric_code, metric_label
        FROM   metric_definitions
        WHERE  sheet = %s
        ORDER  BY metric_key
    """, (sheet_name,))
    if not rows:
        raise HTTPException(status_code=404, detail=f"Sheet '{sheet_name}' not found in DB.")
    return {"sheet": sheet_name, "metrics": rows}
