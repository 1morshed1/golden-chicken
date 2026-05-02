from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # App
    APP_ENV: str = "development"
    DEBUG: bool = False
    APP_VERSION: str = "1.0.0"
    SECRET_KEY: str = "change-me"
    ALLOWED_ORIGINS: str = "http://localhost:3000,http://localhost:8080"

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://goldenchicken:goldenchicken@localhost:5432/goldenchicken"
    DATABASE_URL_SYNC: str = "postgresql+psycopg://goldenchicken:goldenchicken@localhost:5432/goldenchicken"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # JWT
    JWT_SECRET_KEY: str = "change-me-jwt-secret"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # Gemini AI
    GEMINI_API_KEY: str = ""
    GEMINI_TEXT_MODEL: str = "gemini-2.5-flash"
    GEMINI_LIVE_MODEL: str = "gemini-2.5-flash-live-001"
    GEMINI_LITE_MODEL: str = "gemini-2.5-flash-lite"

    # RAG
    RAG_EMBEDDING_MODEL: str = "BAAI/bge-m3"
    RAG_RERANKER_MODEL: str = "BAAI/bge-reranker-v2-m3"
    RAG_TOP_K: int = 10
    RAG_RERANK_TOP_K: int = 5

    # External APIs
    OPENWEATHERMAP_API_KEY: str = ""
    GOOGLE_MAPS_API_KEY: str = ""

    # S3 / MinIO
    S3_ENDPOINT_URL: str = "http://localhost:9000"
    S3_ACCESS_KEY: str = "minioadmin"
    S3_SECRET_KEY: str = "minioadmin"
    S3_BUCKET_NAME: str = "goldenchicken"
    S3_REGION: str = "us-east-1"

    # Firebase
    FIREBASE_PROJECT_ID: str = ""

    # Live AI Guardrails
    LIVE_AI_SESSION_MAX_MINUTES: int = 10
    LIVE_AI_DAILY_MAX_MINUTES: int = 60
    LIVE_AI_CONCURRENT_SESSIONS: int = 1
    LIVE_AI_DAILY_SPEND_CAP_USD: float = 5.00

    # Market Scraping
    MARKET_SCRAPING_ENABLED: bool = True
    MARKET_STALENESS_HOURS: int = 24

    # Sentry
    SENTRY_DSN: str = ""

    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"

    @property
    def allowed_origins_list(self) -> list[str]:
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",") if o.strip()]


settings = Settings()
