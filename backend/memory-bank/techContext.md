# Tech Context — Golden Chicken Backend

## Runtime & framework
- **Python**: 3.12+
- **Web framework**: FastAPI (target noted: 0.110+)
- **Server**: Uvicorn + Gunicorn
- **Validation**: Pydantic v2 (+ `pydantic-settings`)

## Data & storage
- **PostgreSQL 16** (primary relational DB)
- **pgvector** extension (embeddings for RAG)
- **Redis 7** (cache, session store, Celery broker, pub/sub)
- **Object storage**: S3 / MinIO (local dev uses MinIO)

## Database/ORM
- **SQLAlchemy 2.0** async ORM
- **Migrations**: Alembic
- Mixed drivers noted:
  - `asyncpg` for FastAPI
  - `psycopg` (sync) for Celery workers

## Background jobs
- **Celery** workers and Celery Beat schedules

## AI / ML stack
- **Gemini**:
  - `gemini-3-flash-preview` (text + vision)
  - `gemini-3.1-flash-live-preview` (real-time audio-to-audio + vision)
  - `gemini-3.1-flash-lite-preview` (cheap routing tasks)
- **SDK**: `google-genai` Python SDK (including Live API WS)
- **RAG**:
  - Embeddings: Sentence Transformers (planned model: `BAAI/bge-m3`, dim 1024)
  - Reranker: `BAAI/bge-reranker-v2-m3` (cross-encoder)
  - Orchestration: LangChain (optional)
- **Document ingestion**:
  - PDF: `pypdf`, `pdfplumber`
  - OCR: `pytesseract` (requires system packages) + `pdf2image` (requires poppler)

## External integrations
- Weather: **OpenWeatherMap**
- Geocoding: **Google Maps Geocoding API**
- Market data: Bangladesh DAM / TCB / custom scraping (BeautifulSoup + lxml)
- Social auth: Firebase Auth / Google OAuth (token verification)

## Observability & security tooling
- Error tracking: Sentry
- Logging: structlog
- Security: passlib[bcrypt], PyJWT
- CI: GitHub Actions (ruff, pytest, coverage, pip-audit)

## Local development
- Docker + Docker Compose stack:
  - app
  - postgres (pgvector image)
  - redis
  - minio
  - celery-worker
  - celery-beat

## Environment configuration (high-level)
Key groups expected in `.env` / `.env.example`:
- App basics (env/debug/version/allowed origins/secret)
- DB + Redis URLs
- Gemini API key + model names
- RAG model names + top-k configs
- External API keys (OWM, Maps)
- S3/MinIO creds and bucket
- Firebase settings
- Live AI guardrails (caps/limits)
- Market scraping toggles + staleness window
- Retention and logging settings

