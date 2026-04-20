import os
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    GEMINI_API_KEY: str
    LANGSMITH_API_KEY: str = ""
    LANGCHAIN_PROJECT: str = "tbg-ai-copilot"
    LANGCHAIN_TRACING_V2: str = "true"
    MAX_SESSIONS: int = 50
    SESSION_TTL_HOURS: int = 24
    APP_TITLE: str = "TBG AI Copilot"
    APP_VERSION: str = "1.0.0"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()

# Configure LangSmith tracing
if settings.LANGSMITH_API_KEY:
    os.environ["LANGCHAIN_TRACING_V2"] = settings.LANGCHAIN_TRACING_V2
    os.environ["LANGCHAIN_API_KEY"] = settings.LANGSMITH_API_KEY
    os.environ["LANGCHAIN_PROJECT"] = settings.LANGCHAIN_PROJECT
