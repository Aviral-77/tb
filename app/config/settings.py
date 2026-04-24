import os
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Ollama — supports both local and cloud
    # OLLAMA_BASE_URL: str = "http://localhost:11434"
    OLLAMA_BASE_URL: str = "https://api.ollama.com"
    OLLAMA_MODEL: str = "llama3"
    OLLAMA_API_KEY: str = ""  # Set for Ollama Cloud, leave empty for local
    
    # Embedding model for schema RAG — defaults to OLLAMA_MODEL if empty.
    # Pull a dedicated model for better quality: ollama pull nomic-embed-text
    OLLAMA_EMBEDDING_MODEL: str = ""

    # PostgreSQL
    DATABASE_URL: str = "postgresql://digiwise:digiwise_secret@localhost:5432/digiwise"

    # LangSmith
    LANGSMITH_API_KEY: str = ""
    LANGCHAIN_PROJECT: str = "tbg-ai-copilot"
    LANGCHAIN_TRACING_V2: str = "true"

    MAX_SESSIONS: int = 50
    SESSION_TTL_HOURS: int = 24
    APP_TITLE: str = "TBG AI Copilot"
    APP_VERSION: str = "1.0.0"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")
    
    @property
    def OLLAMA_CLIENT_KWARGS(self) -> dict[str, dict[str, str]]:
        """Return a dict of kwargs to initialize the Ollama client, based on current settings."""
        if self.OLLAMA_API_KEY:
            return {
                "headers": {'Authorization': f"Bearer {self.OLLAMA_API_KEY}"},
            }
        return {}
    @property
    def is_ollama_cloud(self) -> bool:
        """Return True if using Ollama Cloud, False if using local Ollama."""
        return bool(self.OLLAMA_API_KEY)


settings = Settings()

# Configure LangSmith tracing — set env vars immediately so every
# LangChain/LangGraph call is captured, including tool calls.
if settings.LANGSMITH_API_KEY:
    os.environ["LANGCHAIN_TRACING_V2"] = "true"
    os.environ["LANGCHAIN_API_KEY"] = settings.LANGSMITH_API_KEY
    os.environ["LANGCHAIN_PROJECT"] = settings.LANGCHAIN_PROJECT
    os.environ["LANGCHAIN_ENDPOINT"] = "https://api.smith.langchain.com"
