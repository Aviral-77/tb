import os
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Ollama
    OLLAMA_BASE_URL: str = "http://localhost:11434"
    OLLAMA_MODEL: str = "mistral"

    # LangSmith
    LANGSMITH_API_KEY: str = ""
    LANGCHAIN_PROJECT: str = "tbg-ai-copilot"
    LANGCHAIN_TRACING_V2: str = "true"

    MAX_SESSIONS: int = 50
    SESSION_TTL_HOURS: int = 24
    APP_TITLE: str = "TBG AI Copilot"
    APP_VERSION: str = "1.0.0"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()

# Configure LangSmith tracing — set env vars immediately so every
# LangChain/LangGraph call is captured, including tool calls.
if settings.LANGSMITH_API_KEY:
    os.environ["LANGCHAIN_TRACING_V2"] = "true"
    os.environ["LANGCHAIN_API_KEY"] = settings.LANGSMITH_API_KEY
    os.environ["LANGCHAIN_PROJECT"] = settings.LANGCHAIN_PROJECT
    os.environ["LANGCHAIN_ENDPOINT"] = "https://api.smith.langchain.com"
