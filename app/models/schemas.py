from __future__ import annotations

from typing import Any
from pydantic import BaseModel, Field


class UploadResponse(BaseModel):
    session_id: str
    file_name: str
    sheets_parsed: list[str]
    periods_available: list[str]
    message: str


class CompareUploadResponse(BaseModel):
    session_id: str
    file1_name: str
    file2_name: str
    sheets_parsed: list[str]
    periods_available: list[str]
    message: str


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    conversation_id: str = Field(default="default")


class ChartSpec(BaseModel):
    chart_type: str
    title: str
    data: list[dict[str, Any]]
    x_key: str
    y_keys: list[str]
    colors: list[str] = []
    unit: str = "M CFA"


class Alert(BaseModel):
    severity: str
    metric_label: str
    sheet: str
    period: str
    actual_value: float | None
    comparison_value: float | None
    change_pct: float | None
    threshold_pct: float
    message: str


class ChatResponse(BaseModel):
    response: str
    conversation_id: str
    charts: list[ChartSpec] = []
    alerts: list[Alert] = []
    session_id: str


class SessionInfo(BaseModel):
    session_id: str
    files: list[str]
    sheets: list[str]
    periods: list[str]
    created_at: str


class HealthResponse(BaseModel):
    status: str
    version: str
    active_sessions: int


class MetricListItem(BaseModel):
    code: str | None
    label: str
    periods_available: list[str]


class MetricListResponse(BaseModel):
    sheet: str
    metrics: list[MetricListItem]
