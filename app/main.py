"""
TBG AI Copilot — FastAPI application entry point.

Start with:
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import router
from app.config.settings import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print(f"Starting {settings.APP_TITLE} v{settings.APP_VERSION}")
    print(f"LangSmith tracing: {'enabled' if settings.LANGSMITH_API_KEY else 'disabled'}")
    yield
    # Shutdown — nothing to clean up (sessions are in-memory)


app = FastAPI(
    title=settings.APP_TITLE,
    version=settings.APP_VERSION,
    description=(
        "Agentic AI backend for the TBG (Tableau de Bord de Gestion) financial reports "
        "of Moov Benin. Powered by LangGraph + Gemini 2.5 Flash."
    ),
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)
