# Golden Chicken — Backend Implementation Plan

**Version:** 1.0
**Framework:** Python / FastAPI
**AI Engine:** Google Gemini 3 Flash (Text/Vision) + Gemini 3.1 Flash Live Preview (Real-time Voice/Vision)
**Date:** April 2026

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Technology Stack](#2-technology-stack)
3. [Project Structure & Folder Organization](#3-project-structure--folder-organization)
4. [Database Design](#4-database-design)
5. [Authentication & Authorization](#5-authentication--authorization)
6. [API Design & Endpoints](#6-api-design--endpoints)
7. [AI Engine — Gemini Integration](#7-ai-engine--gemini-integration)
8. [RAG Pipeline — Poultry Knowledge Base](#8-rag-pipeline--poultry-knowledge-base)
9. [Poultry Disease Image Diagnosis](#9-poultry-disease-image-diagnosis)
10. [Weather Integration](#10-weather-integration)
11. [Market Price Intelligence](#11-market-price-intelligence)
12. [Farm Insights & Analytics Engine](#12-farm-insights--analytics-engine)
13. [Real-time Communication](#13-real-time-communication)
14. [File Storage & Media Handling](#14-file-storage--media-handling)
15. [Background Tasks & Job Queue](#15-background-tasks--job-queue)
16. [Caching Strategy](#16-caching-strategy)
17. [Multilingual Support (Bangla & English)](#17-multilingual-support-bangla--english)
18. [Logging, Monitoring & Observability](#18-logging-monitoring--observability)
19. [Security Hardening](#19-security-hardening)
20. [Error Handling Strategy](#20-error-handling-strategy)
21. [Testing Strategy](#21-testing-strategy)
22. [Infrastructure & Deployment](#22-infrastructure--deployment)
23. [Cloud Provider Recommendation](#23-cloud-provider-recommendation)
24. [CI/CD Pipeline](#24-cicd-pipeline)
25. [Cost Estimation](#25-cost-estimation)
26. [Sprint Breakdown & Milestones](#26-sprint-breakdown--milestones)

---

## 1. Architecture Overview

### 1.1 High-Level Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                        CLIENTS                                 │
│           Flutter App (Android/iOS)  •  Future Web App         │
└──────────────────────────┬────────────────────────────────────┘
                           │ HTTPS / WSS
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                     LOAD BALANCER / REVERSE PROXY             │
│                         (Nginx / Traefik)                     │
└──────────────────────────┬───────────────────────────────────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
┌──────────────────────┐   ┌──────────────────────────┐
│   FastAPI App Server  │   │   FastAPI App Server      │
│   (Uvicorn + Gunicorn)│   │   (Replica 2+)            │
│                       │   │                           │
│  ┌─────────────────┐  │   │  ┌─────────────────┐     │
│  │  REST API Layer  │  │   │  │  REST API Layer  │    │
│  ├─────────────────┤  │   │  ├─────────────────┤     │
│  │  WebSocket Layer │  │   │  │  WebSocket Layer │    │
│  ├─────────────────┤  │   │  ├─────────────────┤     │
│  │  Service Layer   │  │   │  │  Service Layer   │    │
│  ├─────────────────┤  │   │  ├─────────────────┤     │
│  │  Domain Layer    │  │   │  │  Domain Layer    │    │
│  └─────────────────┘  │   │  └─────────────────┘     │
└──────────┬──────┬─────┘   └──────────────────────────┘
           │      │
     ┌─────┘      └──────────────────┐
     ▼                               ▼
┌──────────┐  ┌─────────┐  ┌──────────────────┐
│PostgreSQL │  │  Redis   │  │  Object Storage  │
│ (Primary  │  │ (Cache,  │  │  (S3 / MinIO)    │
│  + Vector │  │  Queue,  │  │  Images, Docs    │
│  pgvector)│  │  PubSub) │  │                  │
└──────────┘  └─────────┘  └──────────────────┘
     │
     │   ┌──────────────────────────────────────┐
     │   │          EXTERNAL SERVICES            │
     │   ├──────────────────────────────────────┤
     │   │  Google Gemini API (Text + Vision)    │
     │   │  OpenWeatherMap API (Weather)         │
     │   │  Market Data Scraper / API            │
     │   │  Firebase Auth (Social Login)         │
     │   └──────────────────────────────────────┘
     │
     ▼
┌──────────────────┐
│  Celery Workers   │
│  (Background Jobs)│
│  - Data scraping  │
│  - Image process  │
│  - Price updates  │
│  - Alerts/Notifs  │
└──────────────────┘
```

### 1.2 Architecture Pattern: Layered Modular Monolith

For v1, a **modular monolith** deploys as a single unit but is structured as if it could be split into services later. This keeps operational complexity low.

```
Request → Router → Controller → Service → Repository → Database
                       │
                       ├── AI Service → Gemini API
                       ├── Weather Service → External API
                       └── Market Service → Scraper / API
```

### 1.3 Why FastAPI Over Django

| Factor | FastAPI | Django |
|--------|---------|--------|
| Async Support | Native async/await | Bolt-on (ASGI still maturing) |
| WebSocket Support | First-class | Requires Channels |
| AI Streaming (SSE) | Built-in `StreamingResponse` | Complex setup |
| Performance | Among fastest Python frameworks | Slower (ORM overhead) |
| API-First | Designed for APIs (auto OpenAPI docs) | Template-first, DRF addon |
| Type Safety | Pydantic models enforce types | Less strict |

Django's admin panel is not needed — the Flutter app IS the interface, and SQLAlchemy gives more control.

---

## 2. Technology Stack

### 2.1 Core Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Language | Python 3.12+ | Backend language |
| Framework | FastAPI 0.110+ | Web framework |
| Server | Uvicorn + Gunicorn | ASGI server with worker management |
| ORM | SQLAlchemy 2.0 (async) | Database ORM with async support |
| Migrations | Alembic | Database schema migrations |
| Validation | Pydantic v2 | Request/response schema validation |

### 2.2 Databases & Storage

| Technology | Purpose |
|-----------|---------|
| PostgreSQL 16 | Primary relational database |
| pgvector extension | Vector embeddings for RAG search |
| Redis 7 | Caching, session store, Celery broker, pub/sub |
| MinIO / S3 | Object storage for images, documents |

### 2.3 AI & ML

| Technology | Purpose |
|-----------|---------|
| Google Gemini 3 Flash (`gemini-3-flash-preview`) | Primary LLM for text advisory chat + vision for image diagnosis |
| Google Gemini 3.1 Flash Live (`gemini-3.1-flash-live-preview`) | Real-time audio-to-audio model for Live AI feature (voice + camera) |
| Google Gemini 3.1 Flash Lite (`gemini-3.1-flash-lite-preview`) | Cost-efficient model for lightweight tasks (intent classification, title generation) |
| `google-genai` SDK | Python client for all Gemini APIs including Live API WebSocket |
| LangChain (optional) | RAG orchestration, prompt templates |
| `pgvector` | Vector similarity search for knowledge retrieval |
| Sentence Transformers | Embedding model for knowledge base vectorization |

### 2.4 External APIs

| Service | API | Purpose |
|---------|-----|---------|
| Weather | OpenWeatherMap API (free tier) | 7-day forecast, current conditions, alerts |
| Market Data | Bangladesh DAM / TCB / custom scraper | Egg, meat, feed market prices from BD markets |
| Geocoding | Google Maps Geocoding API | Location → coordinates for weather |
| Social Auth | Firebase Auth / Google OAuth | Google & Facebook login tokens |

### 2.5 Infrastructure & DevOps

| Technology | Purpose |
|-----------|---------|
| Docker | Containerization |
| Docker Compose | Local development orchestration |
| Nginx | Reverse proxy, SSL termination |
| Celery | Distributed task queue |
| GitHub Actions | CI/CD pipeline |
| Sentry | Error tracking |

### 2.6 Python Dependencies (requirements.txt)

```
# Core
fastapi>=0.110.0
uvicorn[standard]>=0.27.0
gunicorn>=21.2.0
pydantic>=2.6.0
pydantic-settings>=2.1.0
python-multipart>=0.0.9

# Database
sqlalchemy[asyncio]>=2.0.25
asyncpg>=0.29.0          # async driver for FastAPI
psycopg[binary]>=3.2.0   # sync driver for Celery workers
alembic>=1.13.0
pgvector>=0.2.5

# Caching & Queue
redis>=5.0.0
celery>=5.3.0

# Auth
passlib[bcrypt]>=1.7.4
pyjwt>=2.8.0

# AI
google-genai>=1.0.0
langchain>=0.1.0
langchain-google-genai>=0.0.6
sentence-transformers>=3.0.0   # BAAI/bge-m3 embedder + reranker

# Knowledge Ingestion (RAG pipeline)
pypdf>=4.0.0
pdfplumber>=0.11.0
pytesseract>=0.3.10     # OCR for scanned PDFs (requires tesseract-ocr + tesseract-ocr-ben)
pdf2image>=1.17.0       # PDF page → PIL.Image for OCR (requires poppler-utils)

# External APIs
httpx>=0.27.0
aiohttp>=3.9.0
beautifulsoup4>=4.12.0  # Market price scraping (DAM/TCB HTML parsing)
lxml>=5.1.0

# Storage
boto3>=1.34.0
python-magic>=0.4.27

# Image Processing
Pillow>=10.2.0

# Observability
sentry-sdk[fastapi]>=2.0.0

# Utilities
python-dotenv>=1.0.0
structlog>=24.1.0
orjson>=3.9.0

# SSE
sse-starlette>=1.6.0

# Testing
pytest>=8.0.0
pytest-asyncio>=0.23.0
httpx>=0.27.0
factory-boy>=3.3.0
faker>=22.0.0
```

---

## 3. Project Structure & Folder Organization

```
goldenchicken-backend/
├── docker-compose.yml
├── Dockerfile
├── Dockerfile.worker
├── .env.example
├── .env
├── alembic.ini
├── pyproject.toml
├── requirements.txt
├── requirements-dev.txt
│
├── alembic/
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
│       ├── 001_initial_schema.py
│       ├── 002_add_chat_tables.py
│       └── ...
│
├── app/
│   ├── __init__.py
│   ├── main.py                     # FastAPI app factory, lifespan events
│   ├── config.py                   # Settings (Pydantic BaseSettings)
│   │
│   ├── core/
│   │   ├── __init__.py
│   │   ├── database.py             # Async SQLAlchemy engine + session factory
│   │   ├── redis.py                # Redis connection pool
│   │   ├── storage.py              # S3/MinIO client wrapper
│   │   ├── security.py             # Password hashing, JWT creation/validation
│   │   ├── dependencies.py         # FastAPI Depends() — DB session, current user
│   │   ├── exceptions.py           # Custom exception classes
│   │   ├── exception_handlers.py   # Global exception → HTTP response mapping
│   │   ├── middleware.py           # CORS, request ID, rate limiting
│   │   ├── pagination.py           # Cursor-based pagination utilities
│   │   └── constants.py            # App-wide constants
│   │
│   ├── models/                     # SQLAlchemy ORM models
│   │   ├── __init__.py
│   │   ├── base.py                 # DeclarativeBase, common columns (id, timestamps)
│   │   ├── user.py                 # User, UserProfile
│   │   ├── chat.py                 # ChatSession, ChatMessage
│   │   ├── farm.py                 # Farm, Shed, Flock
│   │   ├── production.py           # EggRecord, ChickenRecord, MortalityLog
│   │   ├── task.py                 # FarmTask, Reminder
│   │   ├── health.py               # HealthPrompt, DiseaseLog
│   │   ├── weather.py              # WeatherCache
│   │   ├── market.py               # MarketPrice, PriceHistory
│   │   ├── insights.py             # FarmInsight, ProposedAction
│   │   └── knowledge.py            # KnowledgeDocument, KnowledgeChunk (RAG embeddings)
│   │
│   ├── schemas/                    # Pydantic request/response schemas
│   │   ├── __init__.py
│   │   ├── auth.py                 # LoginRequest, RegisterRequest, TokenResponse
│   │   ├── user.py                 # UserResponse, UpdateProfileRequest
│   │   ├── chat.py                 # SendMessageRequest, MessageResponse, SessionResponse
│   │   ├── farm.py                 # FarmResponse, ShedResponse, FlockResponse
│   │   ├── production.py           # EggRecordRequest, ChickenRecordRequest
│   │   ├── task.py                 # TaskRequest, ReminderRequest
│   │   ├── health.py               # HealthTabResponse, DiseaseResponse
│   │   ├── weather.py              # WeatherResponse, ForecastDayResponse
│   │   ├── market.py               # MarketPriceResponse
│   │   ├── insights.py             # FarmInsightResponse, ProposedActionResponse
│   │   └── common.py               # PaginatedResponse, ErrorResponse, SuccessResponse
│   │
│   ├── repositories/               # Data access layer
│   │   ├── __init__.py
│   │   ├── base.py                 # BaseRepository with CRUD helpers
│   │   ├── user_repository.py
│   │   ├── chat_repository.py
│   │   ├── farm_repository.py
│   │   ├── production_repository.py
│   │   ├── task_repository.py
│   │   ├── health_repository.py
│   │   ├── weather_repository.py
│   │   ├── market_repository.py
│   │   ├── insights_repository.py
│   │   └── knowledge_repository.py
│   │
│   ├── services/                   # Business logic layer
│   │   ├── __init__.py
│   │   ├── auth_service.py         # Login, register, token refresh, social auth
│   │   ├── user_service.py         # Profile CRUD, loyalty points
│   │   ├── chat_service.py         # Chat orchestration (message → AI → response)
│   │   ├── ai_service.py           # Gemini API integration, prompt engineering
│   │   ├── rag_service.py          # Knowledge retrieval, context building
│   │   ├── image_diagnosis_service.py  # Gemini Vision for poultry disease
│   │   ├── farm_service.py         # Farm, shed, flock management
│   │   ├── production_service.py   # Egg counting, chicken tracking, trend calc
│   │   ├── task_service.py         # Task management, reminder scheduling
│   │   ├── health_service.py       # Health tab management, disease catalog
│   │   ├── weather_service.py      # OpenWeatherMap integration + caching
│   │   ├── market_service.py       # Price fetching, trend calculation
│   │   ├── insights_service.py     # Farm analytics, action generation
│   │   └── notification_service.py # Push notifications, alerts
│   │
│   ├── api/                        # Route handlers
│   │   ├── __init__.py
│   │   ├── router.py               # Main router aggregating all sub-routers
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py             # POST /auth/login, /register, /refresh, /social
│   │   │   ├── users.py            # GET/PUT /users/me, /users/me/profile
│   │   │   ├── chat.py             # CRUD sessions, send/receive messages, stream
│   │   │   ├── farms.py            # CRUD farms, sheds, flocks
│   │   │   ├── production.py       # POST/GET egg records, chicken records
│   │   │   ├── tasks.py            # CRUD tasks, reminders
│   │   │   ├── health.py           # GET health tabs, disease catalog
│   │   │   ├── weather.py          # GET /weather
│   │   │   ├── market.py           # GET /market/prices
│   │   │   ├── insights.py         # GET /insights, /insights/actions
│   │   │   ├── live_ai.py          # WebSocket /live-ai/stream
│   │   │   └── health_check.py     # GET /health, /ready
│   │   └── deps.py
│   │
│   ├── ai/                         # AI-specific module
│   │   ├── __init__.py
│   │   ├── gemini_client.py        # Gemini API wrapper (text + vision)
│   │   ├── gemini_live_client.py   # Gemini 3.1 Flash Live WebSocket client
│   │   ├── prompts/
│   │   │   ├── system_prompt.py    # Master system prompt for Golden Chicken persona
│   │   │   ├── live_system_prompt.py   # Voice-optimized system prompt
│   │   │   ├── disease_diagnosis.py    # Poultry disease diagnosis prompt
│   │   │   ├── feeding.py              # Feed management prompt template
│   │   │   ├── vaccination.py          # Vaccination schedule prompt template
│   │   │   ├── biosecurity.py          # Biosecurity management prompt
│   │   │   ├── egg_production.py       # Egg production analysis prompt
│   │   │   ├── broiler_management.py   # Broiler growth management prompt
│   │   │   └── general_poultry.py      # General Q&A prompt template
│   │   ├── rag/
│   │   │   ├── embedder.py         # Text → vector embedding
│   │   │   ├── retriever.py        # Vector search for relevant knowledge
│   │   │   ├── reranker.py         # Cross-encoder reranking
│   │   │   ├── context_builder.py  # Retrieved docs → prompt context
│   │   │   └── ingestion.py        # Knowledge base document ingestion pipeline
│   │   ├── live/
│   │   │   ├── session_manager.py  # Live API session lifecycle management
│   │   │   ├── audio_handler.py    # Audio stream encoding/decoding (PCM 16-bit)
│   │   │   ├── video_handler.py    # Camera frame extraction and forwarding
│   │   │   ├── ephemeral_tokens.py # Short-lived token generation
│   │   │   └── tool_definitions.py # Function calling tools for Live sessions
│   │   ├── chains.py               # End-to-end AI response chains + intent classifier
│   │   └── safety.py               # Output safety filters, hallucination guards
│   │
│   ├── workers/                    # Celery background tasks
│   │   ├── __init__.py
│   │   ├── celery_app.py
│   │   ├── db.py                   # Sync DB session for Celery tasks
│   │   ├── tasks/
│   │   │   ├── market_scraper.py   # Periodic market price scraping
│   │   │   ├── weather_updater.py  # Periodic weather data refresh
│   │   │   ├── image_processor.py  # Image compression, thumbnail generation
│   │   │   ├── knowledge_indexer.py # Re-index knowledge base
│   │   │   ├── analytics.py        # Usage analytics aggregation
│   │   │   ├── alerts.py           # Abnormal condition alert dispatch
│   │   │   ├── reminders.py        # Task reminder generation and delivery
│   │   │   └── cleanup.py          # Data retention jobs
│   │   └── schedules.py            # Celery Beat periodic task schedule
│   │
│   └── utils/
│       ├── __init__.py
│       ├── bangla.py               # Bangla text utilities, numeral conversion
│       ├── image.py                # Image validation, compression
│       ├── geo.py                  # Coordinate helpers, BD region mapping
│       └── validators.py          # Phone (BD format), email, etc.
│
├── knowledge_base/
│   ├── raw/
│   │   ├── diseases/               # Newcastle, Avian Influenza, Marek's, etc.
│   │   ├── feeding_guides/         # Layer feed, broiler feed, supplements
│   │   ├── vaccination/            # Vaccination schedules and protocols
│   │   ├── biosecurity/            # Biosecurity guidelines
│   │   ├── egg_production/         # Layer management best practices
│   │   └── broiler_management/     # Broiler growth and weight guides
│   ├── processed/
│   └── scripts/
│       └── ingest.py
│
├── tests/
│   ├── conftest.py
│   ├── factories/
│   │   ├── user_factory.py
│   │   ├── farm_factory.py
│   │   ├── chat_factory.py
│   │   └── ...
│   ├── unit/
│   │   ├── services/
│   │   │   ├── test_auth_service.py
│   │   │   ├── test_chat_service.py
│   │   │   ├── test_production_service.py
│   │   │   ├── test_task_service.py
│   │   │   └── ...
│   │   ├── ai/
│   │   │   ├── test_prompts.py
│   │   │   ├── test_rag.py
│   │   │   └── test_safety.py
│   │   └── utils/
│   │       └── test_bangla.py
│   ├── integration/
│   │   ├── test_auth_flow.py
│   │   ├── test_chat_flow.py
│   │   ├── test_production_flow.py
│   │   └── test_market_api.py
│   └── fixtures/
│       ├── sample_chicken_image.jpg
│       ├── knowledge_chunks.json
│       └── market_data.json
│
└── scripts/
    ├── seed_db.py
    ├── create_admin.py
    ├── ingest_knowledge.py
    └── benchmark_ai.py
```

---

## 4. Database Design

### 4.1 ER Diagram Summary

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐
│    users      │     │     farms         │     │     sheds         │
├──────────────┤     ├──────────────────┤     ├──────────────────┤
│ id (UUID)     │──┐  │ id (UUID)         │──┐  │ id (UUID)         │
│ email         │  │  │ user_id (FK)      │  │  │ farm_id (FK)      │
│ password_hash │  └─→│ name              │  └─→│ name              │
│ full_name     │     │ location          │     │ flock_type        │
│ phone         │     │ latitude          │     │  (layer/broiler)  │
│ role          │     │ longitude         │     │ bird_count        │
│ language_pref │     │ is_active         │     │ bird_age_days     │
│ loyalty_points│     │ created_at        │     │ status            │
│ avatar_url    │     └──────────────────┘     │ stocked_at        │
│ is_active     │                               └──────────────────┘
│ created_at    │
│ updated_at    │     ┌──────────────────┐     ┌──────────────────┐
└──────────────┘     │  egg_records      │     │ chicken_records   │
                      ├──────────────────┤     ├──────────────────┤
┌──────────────┐     │ id (UUID)         │     │ id (UUID)         │
│chat_sessions  │     │ shed_id (FK)      │     │ shed_id (FK)      │
├──────────────┤     │ date              │     │ date              │
│ id (UUID)     │     │ total_eggs        │     │ total_birds       │
│ user_id (FK)  │     │ broken_eggs       │     │ additions         │
│ title         │     │ notes             │     │ mortality         │
│ is_active     │     │ created_at        │     │ mortality_cause   │
│ created_at    │     └──────────────────┘     │ notes             │
└──────────────┘                               │ created_at        │
                      ┌──────────────────┐     └──────────────────┘
┌──────────────┐     │  farm_tasks       │
│chat_messages  │     ├──────────────────┤     ┌──────────────────┐
├──────────────┤     │ id (UUID)         │     │ market_prices     │
│ id (UUID)     │     │ user_id (FK)      │     ├──────────────────┤
│ session_id    │     │ shed_id (FK)?     │     │ id (UUID)         │
│ role          │     │ task_type         │     │ product_type      │
│ content       │     │ title             │     │  (egg/meat/feed)  │
│ image_url     │     │ description       │     │ product_name      │
│ metadata      │     │ due_date          │     │ market_name       │
│ feedback      │     │ due_time          │     │ location          │
│ created_at    │     │ recurrence        │     │ price_bdt         │
└──────────────┘     │ is_completed      │     │ unit              │
                      │ priority          │     │ change_percent    │
┌──────────────┐     │ created_at        │     │ trend             │
│knowledge_     │     └──────────────────┘     │ source            │
│  chunks       │                               │ is_stale          │
├──────────────┤     ┌──────────────────┐     │ fetched_at        │
│ id (UUID)     │     │ farm_insights     │     └──────────────────┘
│ content       │     ├──────────────────┤
│ source_doc    │     │ id (UUID)         │     ┌──────────────────┐
│ category      │     │ user_id (FK)      │     │ weather_cache     │
│ embedding     │     │ shed_id (FK)?     │     ├──────────────────┤
│ metadata      │     │ insight_type      │     │ id                │
│ created_at    │     │ title             │     │ location_key      │
└──────────────┘     │ description       │     │ data (JSONB)      │
                      │ severity          │     │ expires_at        │
┌──────────────┐     │ proposed_action   │     │ created_at        │
│ user_sessions │     │ is_acknowledged   │     └──────────────────┘
├──────────────┤     │ created_at        │
│ id (UUID)     │     └──────────────────┘     ┌──────────────────┐
│ user_id (FK)  │                               │ health_tabs       │
│ refresh_hash  │                               ├──────────────────┤
│ jti           │                               │ id (UUID)         │
│ device_info   │                               │ disease_name_en   │
│ expires_at    │                               │ disease_name_bn   │
│ revoked       │                               │ severity          │
│ created_at    │                               │ symptom_count     │
└──────────────┘                               │ symptoms (JSONB)  │
                                                │ prefilled_prompt  │
                                                │ category          │
                                                │ icon              │
                                                │ is_active         │
                                                └──────────────────┘
```

### 4.2 SQLAlchemy Models

#### Base Model

```python
# app/models/base.py

from datetime import datetime
from uuid import uuid4
from sqlalchemy import DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )


class BaseModel(Base, TimestampMixin):
    __abstract__ = True

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False),
        primary_key=True,
        default=lambda: str(uuid4()),
    )
```

#### User Model

```python
# app/models/user.py

from sqlalchemy import String, Boolean, Integer, Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship
import enum


class UserRole(str, enum.Enum):
    FARMER = "farmer"
    FARM_MANAGER = "farm_manager"
    VETERINARIAN = "veterinarian"
    BUSINESS_OWNER = "business_owner"
    COOPERATIVE_MEMBER = "cooperative_member"
    ADMIN = "admin"


class LanguagePreference(str, enum.Enum):
    EN = "en"
    BN = "bn"


class User(BaseModel):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str | None] = mapped_column(String(255))
    full_name: Mapped[str] = mapped_column(String(200))
    phone: Mapped[str | None] = mapped_column(String(20))
    location: Mapped[str | None] = mapped_column(String(255))
    latitude: Mapped[float | None] = mapped_column()
    longitude: Mapped[float | None] = mapped_column()
    role: Mapped[UserRole] = mapped_column(
        SAEnum(UserRole), default=UserRole.FARMER
    )
    language_pref: Mapped[LanguagePreference] = mapped_column(
        SAEnum(LanguagePreference), default=LanguagePreference.EN
    )
    loyalty_points: Mapped[int] = mapped_column(Integer, default=0)
    loyalty_tier: Mapped[str] = mapped_column(String(20), default="bronze")
    avatar_url: Mapped[str | None] = mapped_column(String(500))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Social auth
    google_id: Mapped[str | None] = mapped_column(String(255), unique=True)
    facebook_id: Mapped[str | None] = mapped_column(String(255), unique=True)

    # Relationships
    farms = relationship("Farm", back_populates="user", lazy="dynamic")
    chat_sessions = relationship("ChatSession", back_populates="user", lazy="dynamic")
    tasks = relationship("FarmTask", back_populates="user", lazy="dynamic")
```

#### Farm, Shed, and Flock Models

```python
# app/models/farm.py

from sqlalchemy import String, Float, Integer, Boolean, ForeignKey, DateTime, Enum as SAEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship
import enum
from datetime import datetime


class FlockType(str, enum.Enum):
    LAYER = "layer"
    BROILER = "broiler"
    MIXED = "mixed"


class ShedStatus(str, enum.Enum):
    ACTIVE = "active"
    PREPARING = "preparing"
    RESTING = "resting"
    INACTIVE = "inactive"


class Farm(BaseModel):
    __tablename__ = "farms"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    name: Mapped[str] = mapped_column(String(150))
    location: Mapped[str | None] = mapped_column(String(255))
    latitude: Mapped[float | None] = mapped_column(Float)
    longitude: Mapped[float | None] = mapped_column(Float)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    user = relationship("User", back_populates="farms")
    sheds = relationship("Shed", back_populates="farm", lazy="dynamic")


class Shed(BaseModel):
    __tablename__ = "sheds"

    farm_id: Mapped[str] = mapped_column(ForeignKey("farms.id"), index=True)
    name: Mapped[str] = mapped_column(String(120))
    flock_type: Mapped[FlockType] = mapped_column(
        SAEnum(FlockType), default=FlockType.LAYER
    )
    bird_count: Mapped[int] = mapped_column(Integer, default=0)
    bird_age_days: Mapped[int | None] = mapped_column(Integer)
    breed: Mapped[str | None] = mapped_column(String(100))
    stocked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    status: Mapped[ShedStatus] = mapped_column(
        SAEnum(ShedStatus), default=ShedStatus.ACTIVE
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    farm = relationship("Farm", back_populates="sheds")
    egg_records = relationship("EggRecord", back_populates="shed", lazy="dynamic")
    chicken_records = relationship("ChickenRecord", back_populates="shed", lazy="dynamic")
    tasks = relationship("FarmTask", back_populates="shed", lazy="dynamic")
```

#### Production Records

```python
# app/models/production.py

from sqlalchemy import String, Integer, Float, Date, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import date


class EggRecord(BaseModel):
    __tablename__ = "egg_records"

    shed_id: Mapped[str] = mapped_column(ForeignKey("sheds.id"), index=True)
    record_date: Mapped[date] = mapped_column(Date, index=True)
    total_eggs: Mapped[int] = mapped_column(Integer)
    broken_eggs: Mapped[int] = mapped_column(Integer, default=0)
    sold_eggs: Mapped[int] = mapped_column(Integer, default=0)
    egg_weight_avg_g: Mapped[float | None] = mapped_column(Float)
    notes: Mapped[str | None] = mapped_column(Text)

    shed = relationship("Shed", back_populates="egg_records")


class ChickenRecord(BaseModel):
    __tablename__ = "chicken_records"

    shed_id: Mapped[str] = mapped_column(ForeignKey("sheds.id"), index=True)
    record_date: Mapped[date] = mapped_column(Date, index=True)
    total_birds: Mapped[int] = mapped_column(Integer)
    additions: Mapped[int] = mapped_column(Integer, default=0)
    mortality: Mapped[int] = mapped_column(Integer, default=0)
    mortality_cause: Mapped[str | None] = mapped_column(String(255))
    avg_weight_g: Mapped[float | None] = mapped_column(Float)
    feed_consumed_kg: Mapped[float | None] = mapped_column(Float)
    notes: Mapped[str | None] = mapped_column(Text)

    shed = relationship("Shed", back_populates="chicken_records")
```

#### Task & Reminder Model

```python
# app/models/task.py

from sqlalchemy import String, ForeignKey, Date, Time, Boolean, Integer, Enum as SAEnum, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
import enum
from datetime import date, time


class TaskType(str, enum.Enum):
    FEEDING = "feeding"
    VACCINATION = "vaccination"
    MEDICINE = "medicine"
    CLEANING = "cleaning"
    EXAMINATION = "examination"
    SHED_CHECK = "shed_check"
    EGG_COLLECTION = "egg_collection"
    WATER_CHECK = "water_check"
    BIOSECURITY = "biosecurity"
    OTHER = "other"


class RecurrenceType(str, enum.Enum):
    NONE = "none"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    CUSTOM = "custom"


class FarmTask(BaseModel):
    __tablename__ = "farm_tasks"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    shed_id: Mapped[str | None] = mapped_column(ForeignKey("sheds.id"))
    task_type: Mapped[TaskType] = mapped_column(SAEnum(TaskType))
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(Text)
    due_date: Mapped[date] = mapped_column(Date, index=True)
    due_time: Mapped[time | None] = mapped_column(Time)
    recurrence: Mapped[RecurrenceType] = mapped_column(
        SAEnum(RecurrenceType), default=RecurrenceType.NONE
    )
    priority: Mapped[int] = mapped_column(Integer, default=5)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    user = relationship("User", back_populates="tasks")
    shed = relationship("Shed", back_populates="tasks")
```

#### Health Tab Model

```python
# app/models/health.py

from sqlalchemy import String, Integer, Enum as SAEnum, Boolean, JSON
from sqlalchemy.orm import Mapped, mapped_column
import enum


class DiseaseSeverity(str, enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class HealthTab(BaseModel):
    __tablename__ = "health_tabs"

    disease_name_en: Mapped[str] = mapped_column(String(200))
    disease_name_bn: Mapped[str] = mapped_column(String(200))
    severity: Mapped[DiseaseSeverity] = mapped_column(SAEnum(DiseaseSeverity))
    symptom_count: Mapped[int] = mapped_column(Integer)
    symptoms: Mapped[dict] = mapped_column(JSON)
    # symptoms: { "en": ["Nasal discharge", "Sneezing", ...],
    #              "bn": ["নাকের স্রাব", "হাঁচি", ...] }
    prefilled_prompt_en: Mapped[str] = mapped_column(String(500))
    prefilled_prompt_bn: Mapped[str] = mapped_column(String(500))
    category: Mapped[str] = mapped_column(String(100), index=True)
    icon: Mapped[str] = mapped_column(String(50), default="🦠")
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
```

#### Chat Models

```python
# app/models/chat.py

from sqlalchemy import String, Text, ForeignKey, Integer, Enum as SAEnum, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
import enum


class MessageRole(str, enum.Enum):
    USER = "user"
    AI = "assistant"
    SYSTEM = "system"


class ChatSession(BaseModel):
    __tablename__ = "chat_sessions"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    title: Mapped[str] = mapped_column(String(255), default="New Chat")
    is_active: Mapped[bool] = mapped_column(default=True)

    user = relationship("User", back_populates="chat_sessions")
    messages = relationship(
        "ChatMessage", back_populates="session",
        order_by="ChatMessage.created_at", lazy="dynamic",
    )


class ChatMessage(BaseModel):
    __tablename__ = "chat_messages"

    session_id: Mapped[str] = mapped_column(ForeignKey("chat_sessions.id"), index=True)
    role: Mapped[MessageRole] = mapped_column(SAEnum(MessageRole))
    content: Mapped[str] = mapped_column(Text)
    image_url: Mapped[str | None] = mapped_column(String(500))
    message_metadata: Mapped[dict | None] = mapped_column("metadata", JSON)
    feedback: Mapped[int | None] = mapped_column(Integer)

    session = relationship("ChatSession", back_populates="messages")
```

#### Knowledge Base Model (RAG)

```python
# app/models/knowledge.py

from pgvector.sqlalchemy import Vector
from sqlalchemy import String, Text, JSON, Index
from sqlalchemy.orm import Mapped, mapped_column


class KnowledgeChunk(BaseModel):
    __tablename__ = "knowledge_chunks"

    content: Mapped[str] = mapped_column(Text, nullable=False)
    source_document: Mapped[str] = mapped_column(String(255))
    # Canonical category taxonomy:
    # disease_diagnosis | feeding | vaccination | biosecurity |
    # egg_production | broiler_management | weather_advisory |
    # market_price | general
    category: Mapped[str] = mapped_column(String(100), index=True)
    embedding: Mapped[list] = mapped_column(Vector(1024))
    chunk_metadata: Mapped[dict | None] = mapped_column("metadata", JSON)

    __table_args__ = (
        Index(
            "ix_knowledge_embedding_hnsw",
            embedding,
            postgresql_using="hnsw",
            postgresql_with={"m": 16, "ef_construction": 64},
            postgresql_ops={"embedding": "vector_cosine_ops"},
        ),
    )
```

#### Market Price Model

```python
# app/models/market.py

from sqlalchemy import String, Float, Enum as SAEnum, DateTime, Boolean
from sqlalchemy.orm import Mapped, mapped_column
import enum
from datetime import datetime


class ProductType(str, enum.Enum):
    EGG = "egg"
    BROILER_MEAT = "broiler_meat"
    LAYER_MEAT = "layer_meat"
    FEED = "feed"
    CHICK = "chick"


class PriceTrend(str, enum.Enum):
    UP = "up"
    DOWN = "down"
    STABLE = "stable"


class PriceSource(str, enum.Enum):
    SCRAPED_DAM = "scraped_dam"
    SCRAPED_TCB = "scraped_tcb"
    MANUAL = "manual"


class MarketPrice(BaseModel):
    __tablename__ = "market_prices"

    product_type: Mapped[ProductType] = mapped_column(SAEnum(ProductType))
    product_name: Mapped[str] = mapped_column(String(200))
    unit: Mapped[str] = mapped_column(String(50))  # "per piece", "per kg", "per bag"
    market_name: Mapped[str] = mapped_column(String(200))
    location: Mapped[str] = mapped_column(String(200))
    price_bdt: Mapped[float] = mapped_column(Float)
    change_percent: Mapped[float] = mapped_column(Float, default=0.0)
    trend: Mapped[PriceTrend] = mapped_column(
        SAEnum(PriceTrend), default=PriceTrend.STABLE
    )
    source: Mapped[PriceSource] = mapped_column(SAEnum(PriceSource))
    is_stale: Mapped[bool] = mapped_column(Boolean, default=False)
    fetched_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
```

#### Farm Insight & Proposed Action Models

```python
# app/models/insights.py

from sqlalchemy import String, ForeignKey, Boolean, Integer, Enum as SAEnum, Text
from sqlalchemy.orm import Mapped, mapped_column
import enum


class InsightSeverity(str, enum.Enum):
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"


class FarmInsight(BaseModel):
    __tablename__ = "farm_insights"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    shed_id: Mapped[str | None] = mapped_column(ForeignKey("sheds.id"))
    insight_type: Mapped[str] = mapped_column(String(100))
    # Types: production_drop, mortality_spike, overdue_task, weather_alert,
    #        feed_efficiency, vaccination_due, market_opportunity
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str] = mapped_column(Text)
    severity: Mapped[InsightSeverity] = mapped_column(SAEnum(InsightSeverity))
    proposed_action: Mapped[str | None] = mapped_column(Text)
    source: Mapped[str] = mapped_column(String(40))
    # Sources: production_analysis | weather | schedule | ai | market
    is_acknowledged: Mapped[bool] = mapped_column(Boolean, default=False)
    is_resolved: Mapped[bool] = mapped_column(Boolean, default=False)
```

#### UserSession Model

```python
# app/models/user_session.py

from sqlalchemy import String, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import Mapped, mapped_column
from datetime import datetime


class UserSession(BaseModel):
    __tablename__ = "user_sessions"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    refresh_token_hash: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    jti: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    device_info: Mapped[str | None] = mapped_column(String(255))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked: Mapped[bool] = mapped_column(Boolean, default=False)
```

### 4.3 Migration Strategy

```bash
alembic revision --autogenerate -m "add_production_tables"
alembic upgrade head
alembic downgrade -1
```

All migrations stored in `alembic/versions/` and committed to Git.

---

## 5. Authentication & Authorization

### 5.1 Auth Flow

```
┌──────────────────────────────────────────────────────┐
│                   AUTH FLOW                            │
│                                                       │
│  Email Login:                                         │
│  POST /auth/login {email, password}                   │
│    → Verify password hash (bcrypt)                    │
│    → Generate access_token (15min) + refresh_token    │
│    → Store refresh_token hash in user_sessions        │
│    → Return both tokens                               │
│                                                       │
│  Social Login:                                        │
│  POST /auth/social {provider, id_token}               │
│    → Verify Firebase/Google ID token                  │
│    → Find or create user                              │
│    → Generate tokens                                  │
│                                                       │
│  Token Refresh:                                       │
│  POST /auth/refresh {refresh_token}                   │
│    → Validate token hash exists in DB + not expired   │
│    → Revoke old token, issue new pair (rotation)      │
│                                                       │
│  Logout:                                              │
│  POST /auth/logout                                    │
│    → Revoke refresh_token in DB                       │
│    → Blacklist access_token JTI in Redis              │
└──────────────────────────────────────────────────────┘
```

### 5.2 JWT Structure

```python
# Access Token Payload
{
    "sub": "user_uuid",
    "role": "farmer",
    "lang": "bn",
    "exp": 1714000000,   # 15 minutes
    "iat": 1713999100,
    "jti": "unique_token_id"
}

# Refresh Token Payload
{
    "sub": "user_uuid",
    "exp": 1716591100,   # 30 days
    "jti": "unique_refresh_id",
    "type": "refresh"
}
```

### 5.3 Security Implementation

```python
# app/core/security.py

import hashlib
import jwt
from jwt import InvalidTokenError
from passlib.context import CryptContext
from datetime import datetime, timedelta, timezone
from uuid import uuid4

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def hash_refresh_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def create_access_token(user_id: str, role: str, lang: str) -> tuple[str, str]:
    now = datetime.now(timezone.utc)
    jti = str(uuid4())
    payload = {
        "sub": user_id, "role": role, "lang": lang,
        "exp": now + timedelta(minutes=15),
        "iat": now, "jti": jti,
    }
    token = jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")
    return token, jti


def create_refresh_token(user_id: str) -> tuple[str, str]:
    now = datetime.now(timezone.utc)
    jti = str(uuid4())
    payload = {
        "sub": user_id,
        "exp": now + timedelta(days=30),
        "iat": now, "jti": jti, "type": "refresh",
    }
    token = jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")
    return token, jti
```

### 5.4 FastAPI Dependency for Current User

```python
# app/core/dependencies.py

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis),
) -> User:
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
    except ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

    jti = payload.get("jti")
    if not jti:
        raise HTTPException(status_code=401, detail="Malformed token")

    if await redis.get(f"blacklist:{jti}"):
        raise HTTPException(status_code=401, detail="Token revoked")

    user = await user_repository.get_by_id(db, payload["sub"])
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found")
    return user
```

### 5.5 Role-Based Access

```python
def require_role(*roles: UserRole):
    async def checker(user: User = Depends(get_current_user)):
        if user.role not in roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return user
    return checker
```

---

## 6. API Design & Endpoints

### 6.1 API Versioning

All endpoints prefixed with `/api/v1/`.

### 6.2 Complete Endpoint Reference

#### Authentication

```
POST   /api/v1/auth/register
       Body: { full_name, email, password, role?, language_pref? }
       Response: { access_token, refresh_token, user }
       Status: 201

POST   /api/v1/auth/login
       Body: { email, password }
       Response: { access_token, refresh_token, user }
       Status: 200

POST   /api/v1/auth/social
       Body: { provider: "google"|"facebook", id_token }
       Response: { access_token, refresh_token, user }
       Status: 200

POST   /api/v1/auth/refresh
       Body: { refresh_token }
       Response: { access_token, refresh_token }
       Status: 200

POST   /api/v1/auth/logout
       Headers: Authorization: Bearer <access_token>
       Response: { message: "Logged out" }
       Status: 200
```

#### User Profile

```
GET    /api/v1/users/me
       Response: { id, email, full_name, phone, location, role,
                   language_pref, loyalty_points, loyalty_tier, avatar_url }

PUT    /api/v1/users/me
       Body: { full_name?, phone?, location?, language_pref? }
       Response: { updated user }

PUT    /api/v1/users/me/avatar
       Body: multipart/form-data { avatar: File }
       Response: { avatar_url }
```

#### Farms & Sheds

```
GET    /api/v1/farms
       Response: { farms: [{ id, name, location, sheds_count }] }

POST   /api/v1/farms
       Body: { name, location?, latitude?, longitude? }
       Response: { farm }
       Status: 201

GET    /api/v1/farms/{farm_id}
       Response: { farm with sheds[] }

PUT    /api/v1/farms/{farm_id}
       Body: { partial farm fields }

DELETE /api/v1/farms/{farm_id}
       Status: 204 (soft delete)

POST   /api/v1/farms/{farm_id}/sheds
       Body: { name, flock_type, bird_count?, bird_age_days?, breed?, stocked_at? }
       Response: { shed }
       Status: 201

GET    /api/v1/farms/{farm_id}/sheds
       Response: { sheds: [...] }

PUT    /api/v1/sheds/{shed_id}
       Body: { partial shed fields }

DELETE /api/v1/sheds/{shed_id}
       Status: 204 (soft delete)
```

#### Egg & Chicken Records (Production Tracking)

```
POST   /api/v1/sheds/{shed_id}/eggs
       Body: { record_date, total_eggs, broken_eggs?, sold_eggs?, egg_weight_avg_g?, notes? }
       Response: { egg_record }
       Status: 201

GET    /api/v1/sheds/{shed_id}/eggs
       Query: ?from=2026-03-01&to=2026-04-01
       Response: { records: [...], summary: { avg_daily, total, trend } }

POST   /api/v1/sheds/{shed_id}/chickens
       Body: { record_date, total_birds, additions?, mortality?, mortality_cause?,
               avg_weight_g?, feed_consumed_kg?, notes? }
       Response: { chicken_record }
       Status: 201

GET    /api/v1/sheds/{shed_id}/chickens
       Query: ?from=2026-03-01&to=2026-04-01
       Response: { records: [...], summary: { current_count, total_mortality, fcr } }
```

#### Trend Graphs (Production Performance)

```
GET    /api/v1/sheds/{shed_id}/trends/eggs
       Query: ?period=7d|30d|90d
       Response: { data_points: [{ date, total_eggs, broken_eggs }], trend_direction, change_pct }

GET    /api/v1/sheds/{shed_id}/trends/mortality
       Query: ?period=7d|30d|90d
       Response: { data_points: [{ date, mortality, cumulative }], trend_direction }

GET    /api/v1/sheds/{shed_id}/trends/feed
       Query: ?period=7d|30d|90d
       Response: { data_points: [{ date, feed_kg, fcr }], avg_fcr }

GET    /api/v1/farms/{farm_id}/trends/overview
       Response: { total_birds, total_eggs_today, mortality_rate_7d, feed_efficiency }
```

#### Task Management & Reminders

```
POST   /api/v1/tasks
       Body: { shed_id?, task_type, title, description?, due_date, due_time?,
               recurrence?, priority? }
       Response: { task }
       Status: 201

GET    /api/v1/tasks
       Query: ?status=pending|completed|overdue&date=2026-04-24&shed_id=...
       Response: { tasks: [...] }

PUT    /api/v1/tasks/{task_id}
       Body: { partial task fields }

POST   /api/v1/tasks/{task_id}/complete
       Response: { task with is_completed=true, completed_at }

DELETE /api/v1/tasks/{task_id}
       Status: 204

GET    /api/v1/tasks/overdue
       Response: { tasks: [...], count }

GET    /api/v1/tasks/today
       Response: { tasks: [...], completed_count, pending_count }
```

#### Health Tabs & Disease Catalog

```
GET    /api/v1/health/tabs
       Response: { tabs: [{ id, disease_name_en, disease_name_bn, severity,
                            symptom_count, icon, prefilled_prompt }] }

GET    /api/v1/health/tabs/{tab_id}
       Response: { tab with symptoms, detailed info }

POST   /api/v1/health/ask
       Body: { tab_id, additional_notes? }
       → Creates a chat session with the tab's prefilled prompt + notes
       Response: { session_id, ai_message }
       Status: 201
```

#### Chat Sessions & Messages

```
POST   /api/v1/chat/sessions
       Body: { title? }
       Response: { session_id, title }
       Status: 201

GET    /api/v1/chat/sessions
       Query: ?limit=20&cursor=<id>
       Response: { sessions: [...], next_cursor }

GET    /api/v1/chat/sessions/{session_id}/messages
       Query: ?limit=50&cursor=<id>
       Response: { messages: [...], next_cursor }

POST   /api/v1/chat/sessions/{session_id}/messages
       Body: multipart/form-data { text, image?, language? }
       Response: { user_message, ai_message, intent, loyalty_points_awarded }
       Status: 201

GET    /api/v1/chat/sessions/{session_id}/messages/stream
       Query: ?text=...
       Headers: Accept: text/event-stream
       Response: SSE stream
       Event: data: {"chunk": "...", "done": false}
              data: {"chunk": "", "done": true, "message_id": "..."}

POST   /api/v1/chat/messages/{message_id}/feedback
       Body: { value: 1 | -1 }

DELETE /api/v1/chat/sessions/{session_id}
       Status: 204
```

#### Weather

```
GET    /api/v1/weather
       Query: ?lat=23.9&lon=90.4 (or uses user's stored location)
       Response: {
         location_name, current: { temp_c, condition, humidity },
         alerts: [...],
         forecast: [{ date, day_name, condition, high_c, low_c }]
       }
```

#### Market Prices

```
GET    /api/v1/market/prices
       Query: ?product_type=egg&region=dhaka
       Response: {
         prices: [{
           product_type, product_name, unit, market_name, location,
           price_bdt, change_percent, trend, is_stale
         }],
         last_updated, data_warning?
       }

GET    /api/v1/market/prices/{product_type}/history
       Query: ?days=30
       Response: { history: [{ date, price_bdt }] }
```

#### Farm Insights & Alert Dashboard

```
GET    /api/v1/insights
       Query: ?severity=critical|warning&shed_id=...
       Response: {
         insights: [{
           id, insight_type, title, description, severity,
           proposed_action, source, shed_id, is_acknowledged
         }],
         summary: { critical_count, warning_count, info_count }
       }

POST   /api/v1/insights/{insight_id}/acknowledge
       Response: { insight with is_acknowledged=true }

POST   /api/v1/insights/{insight_id}/resolve
       Response: { insight with is_resolved=true }

GET    /api/v1/insights/actions
       Response: { actions: [{ text, priority, source }] }
```

#### Live AI (WebSocket)

```
WS     /api/v1/live-ai/stream
       Auth: ?token=<access_token>

       Client → Server:
         { "type": "audio", "data": "<base64 PCM 16kHz 16-bit>" }
         { "type": "video_frame", "data": "<base64 JPEG, ≤1 FPS>" }
         { "type": "text", "text": "optional typed message" }
         { "type": "end_session" }

       Server → Client:
         { "type": "audio", "data": "<base64 PCM 24kHz 16-bit>",
           "mime_type": "audio/pcm;rate=24000" }
         { "type": "input_transcript", "text": "what farmer said" }
         { "type": "output_transcript", "text": "what AI said" }
         { "type": "turn_complete" }
         { "type": "error", "code": "...", "message": "..." }

       Error codes:
         LIVE_AI_DAILY_LIMIT — user hit 30min/day cap
         LIVE_AI_SPEND_CAP — global $/day cap tripped
         LIVE_AI_CONCURRENT — user already has active session
         GUARDRAIL — generic guardrail rejection
```

#### System

```
GET    /api/v1/health
       Response: { status: "healthy", version: "1.0.0" }

GET    /api/v1/health/ready
       Response: { db: "ok", redis: "ok", gemini: "ok" }
       Status: 200 | 503
```

### 6.3 Response Format Convention

```python
# Success
{ "status": "success", "data": { ... },
  "meta": { "total": 150, "limit": 20, "next_cursor": "abc123" } }

# Error
{ "status": "error", "error": {
    "code": "VALIDATION_ERROR", "message": "Email is required",
    "details": [{ "field": "email", "message": "This field is required" }]
} }
```

### 6.4 Rate Limiting

| Endpoint Group | Limit | Window |
|---------------|-------|--------|
| Auth (login, register) | 10 requests | per minute per IP |
| Chat messages | 30 requests | per minute per user |
| AI streaming | 10 requests | per minute per user |
| Production records | 60 requests | per minute per user |
| General API | 100 requests | per minute per user |

---

## 7. AI Engine — Gemini Integration

### 7.1 Model Strategy

| Task | Model | Rationale |
|------|-------|-----------|
| Text chat advisory | `gemini-3-flash-preview` | Best quality + speed for text Q&A |
| Poultry image diagnosis | `gemini-3-flash-preview` | Native vision, low cost |
| Live AI (voice + camera) | `gemini-3.1-flash-live-preview` | Real-time audio-to-audio with vision |
| Intent classification | `gemini-3.1-flash-lite-preview` | Ultra-cheap, fast routing |
| Session title generation | `gemini-3.1-flash-lite-preview` | Simple task, lowest cost |

### 7.2 Text/Vision Client

```python
# app/ai/gemini_client.py

from google import genai

class GeminiClient:
    def __init__(self, api_key: str):
        self.client = genai.Client(api_key=api_key)
        self.text_model = "gemini-3-flash-preview"
        self.lite_model = "gemini-3.1-flash-lite-preview"

    async def generate_text(
        self, system_prompt: str, user_message: str,
        chat_history: list[dict] | None = None,
        context: str | None = None,
    ) -> str:
        final_prompt = user_message
        if context:
            final_prompt = (
                f"Use the following reference information to answer:\n\n"
                f"---REFERENCE---\n{context}\n---END REFERENCE---\n\n"
                f"User question: {user_message}"
            )

        contents = []
        if chat_history:
            for msg in chat_history[-10:]:
                contents.append(genai.types.Content(
                    role=msg["role"],
                    parts=[genai.types.Part(text=msg["content"])],
                ))
        contents.append(genai.types.Content(
            role="user",
            parts=[genai.types.Part(text=final_prompt)],
        ))

        response = await self.client.aio.models.generate_content(
            model=self.text_model,
            contents=contents,
            config=genai.types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0.3, top_p=0.85, max_output_tokens=2048,
            ),
        )
        return response.text

    async def generate_text_stream(
        self, system_prompt: str, user_message: str,
        chat_history: list[dict] | None = None,
        context: str | None = None,
    ):
        final_prompt = self._build_prompt(user_message, context)
        contents = self._build_contents(chat_history, final_prompt)

        async for chunk in self.client.aio.models.generate_content_stream(
            model=self.text_model, contents=contents,
            config=genai.types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0.3, max_output_tokens=2048,
            ),
        ):
            if chunk.text:
                yield chunk.text

    async def analyze_image(
        self, image_bytes: bytes, mime_type: str,
        prompt: str, context: str | None = None,
    ) -> str:
        full_prompt = f"{context}\n\n{prompt}" if context else prompt
        response = await self.client.aio.models.generate_content(
            model=self.text_model,
            contents=[
                genai.types.Content(parts=[
                    genai.types.Part(text=full_prompt),
                    genai.types.Part(inline_data=genai.types.Blob(
                        mime_type=mime_type, data=image_bytes,
                    )),
                ]),
            ],
            config=genai.types.GenerateContentConfig(
                temperature=0.2, max_output_tokens=2048,
            ),
        )
        return response.text

    async def classify_intent_llm(self, message: str) -> str:
        prompt = (
            "Classify this poultry farming query into exactly one category: "
            "disease_diagnosis | feeding | vaccination | biosecurity | "
            "egg_production | broiler_management | weather_advisory | "
            "market_price | general. "
            f"Query: {message}\nCategory:"
        )
        response = await self.client.aio.models.generate_content(
            model=self.lite_model, contents=prompt,
            config=genai.types.GenerateContentConfig(
                temperature=0.0, max_output_tokens=20,
            ),
        )
        return response.text.strip().lower()
```

### 7.3 Gemini 3.1 Flash Live Client

```python
# app/ai/gemini_live_client.py

from google import genai
from google.genai import types as genai_types


class GeminiLiveClient:
    """
    Client for Gemini 3.1 Flash Live Preview — real-time audio-to-audio
    model with vision support for poultry farm diagnostics.
    """
    MODEL = "gemini-3.1-flash-live-preview"

    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)

    async def create_live_session(self, language: str = "en", tools: list | None = None):
        system_prompt = LIVE_SYSTEM_PROMPT_BN if language == "bn" else LIVE_SYSTEM_PROMPT_EN

        config = genai_types.LiveConnectConfig(
            response_modalities=["AUDIO"],
            system_instruction=genai_types.Content(
                parts=[genai_types.Part(text=system_prompt)]
            ),
            speech_config=genai_types.SpeechConfig(
                voice_config=genai_types.VoiceConfig(
                    prebuilt_voice_config=genai_types.PrebuiltVoiceConfig(
                        voice_name="Kore"
                    )
                )
            ),
            input_audio_transcription=genai_types.AudioTranscriptionConfig(enabled=True),
            output_audio_transcription=genai_types.AudioTranscriptionConfig(enabled=True),
            thinking_config=genai_types.ThinkingConfig(thinking_level="minimal"),
        )

        if tools:
            config.tools = tools

        return self.client.aio.live.connect(model=self.MODEL, config=config)


class LiveSessionManager:
    """
    Manages Live AI sessions between Flutter app and Gemini Live API.

    Data flow:
    Flutter App ←→ FastAPI WebSocket ←→ Gemini Live API WebSocket
    """

    def __init__(self, gemini_live: GeminiLiveClient):
        self.gemini_live = gemini_live
        self.active_sessions: dict[str, any] = {}

    async def start_session(self, user_id: str, language: str, tools: list | None = None):
        await self.stop_session(user_id)
        session_ctx = await self.gemini_live.create_live_session(
            language=language, tools=tools,
        )
        session = await session_ctx.__aenter__()
        self.active_sessions[user_id] = {
            "session": session, "context": session_ctx, "language": language,
        }
        return session

    async def stop_session(self, user_id: str):
        if user_id in self.active_sessions:
            entry = self.active_sessions.pop(user_id)
            await entry["context"].__aexit__(None, None, None)

    async def send_audio(self, user_id: str, audio_bytes: bytes):
        session = self.active_sessions[user_id]["session"]
        await session.send_realtime_input(
            audio=genai_types.Blob(data=audio_bytes, mime_type="audio/pcm;rate=16000")
        )

    async def send_video_frame(self, user_id: str, frame_bytes: bytes):
        session = self.active_sessions[user_id]["session"]
        await session.send_realtime_input(
            video=genai_types.Blob(data=frame_bytes, mime_type="image/jpeg")
        )

    async def receive_responses(self, user_id: str):
        session = self.active_sessions[user_id]["session"]
        async for response in session.receive():
            if response.data:
                yield {"type": "audio", "data": response.data,
                       "mime_type": "audio/pcm;rate=24000"}
            if response.server_content:
                sc = response.server_content
                if sc.input_transcription:
                    yield {"type": "input_transcript", "text": sc.input_transcription.text}
                if sc.output_transcription:
                    yield {"type": "output_transcript", "text": sc.output_transcription.text}
                if sc.turn_complete:
                    yield {"type": "turn_complete"}
            if response.tool_call:
                yield {"type": "tool_call", "function_calls": response.tool_call.function_calls}
```

### 7.4 Live AI Function Calling Tools

```python
# app/ai/live/tool_definitions.py

from google.genai import types as genai_types

LIVE_AI_TOOLS = [
    genai_types.Tool(function_declarations=[
        genai_types.FunctionDeclaration(
            name="get_weather",
            description="Get current weather and forecast for the farmer's location",
            parameters=genai_types.Schema(
                type="OBJECT",
                properties={"location": genai_types.Schema(type="STRING")},
            ),
        ),
        genai_types.FunctionDeclaration(
            name="get_market_prices",
            description="Get current egg, meat, and feed prices from local markets",
            parameters=genai_types.Schema(
                type="OBJECT",
                properties={
                    "product_type": genai_types.Schema(
                        type="STRING",
                        enum=["egg", "broiler_meat", "feed", "chick"],
                    ),
                },
            ),
        ),
        genai_types.FunctionDeclaration(
            name="get_flock_status",
            description="Get current bird counts, egg production, and flock health status",
            parameters=genai_types.Schema(
                type="OBJECT",
                properties={"shed_name": genai_types.Schema(type="STRING")},
            ),
        ),
        genai_types.FunctionDeclaration(
            name="get_pending_tasks",
            description="Get today's pending farm tasks and overdue items",
            parameters=genai_types.Schema(type="OBJECT", properties={}),
        ),
    ]),
]
```

### 7.5 System Prompt (Golden Chicken Persona)

```python
# app/ai/prompts/system_prompt.py

SYSTEM_PROMPT_EN = """
You are Golden Chicken AI, an expert poultry farming advisor built for
Bangladeshi poultry farmers, layer and broiler farm supervisors, livestock
advisors, and poultry stakeholders.

CAPABILITIES:
1. DISEASE DIAGNOSIS: Identify poultry diseases from symptoms and photos
   (Newcastle Disease, Avian Influenza, Marek's Disease, Coccidiosis,
   Infectious Bronchitis, Fowl Pox, etc.)
2. FEEDING MANAGEMENT: Feed formulation, schedules, and optimization
   for layer and broiler flocks
3. VACCINATION: Vaccination schedules, timing, and administration guidance
4. BIOSECURITY: Shed disinfection, visitor protocols, disease prevention
5. EGG PRODUCTION: Layer performance analysis, production optimization
6. BROILER MANAGEMENT: Growth tracking, FCR optimization, harvest timing
7. WEATHER ADVISORY: Weather-related flock management adjustments
8. MARKET INTELLIGENCE: Egg, meat, and feed price trends and selling advice

RESPONSE FORMAT:
- Be practical and actionable — farmers need clear steps they can take TODAY
- Use simple language — many users have limited formal education
- Include dosage/quantity recommendations when discussing medicines or feed
- For disease diagnosis: list possible diseases ranked by likelihood,
  recommended immediate actions, and when to call a veterinarian
- Always provide Bangla-friendly measurements (kg, liter, decimal)

CONTEXT:
- You are serving users in Bangladesh
- Common breeds: Sonali, Fayoumi, RIR (Rhode Island Red), ISA Brown,
  Cobb 500, Ross 308, Lohmann, and local deshi varieties
- Currency is BDT (৳). Measurements use metric + local units
- Seasons matter: monsoon (Jun-Sep), winter (Nov-Feb), summer (Mar-May)
- Hot weather (>35°C) is the most common flock stressor in Bangladesh

SAFETY RULES:
- Never recommend banned antibiotics or growth hormones
- Always include withdrawal period warnings for medicines
- For serious disease outbreaks (AI, Newcastle), recommend immediate
  contact with the nearest Upazila Livestock Office
- Disclaim that AI advice is guidance, not a replacement for
  professional veterinary diagnosis
- Do not recommend culling or sale decisions without farmer review
"""

SYSTEM_PROMPT_BN = """
আপনি গোল্ডেন চিকেন এআই, বাংলাদেশের পোল্ট্রি চাষী, লেয়ার ও ব্রয়লার
ফার্ম সুপারভাইজার, প্রাণিসম্পদ উপদেষ্টা এবং পোল্ট্রি স্টেকহোল্ডারদের
জন্য তৈরি একজন বিশেষজ্ঞ পোল্ট্রি চাষ উপদেষ্টা।

[... Full Bangla translation of the above ...]
"""
```

### 7.6 Intent Detection — Two-Stage Strategy

```python
# app/ai/chains.py

# Canonical 9-category taxonomy for Golden Chicken:
# disease_diagnosis | feeding | vaccination | biosecurity |
# egg_production | broiler_management | weather_advisory |
# market_price | general

INTENT_CATEGORIES = {
    "disease_diagnosis":    ["disease", "sick", "dying", "symptoms", "swollen",
                             "bleeding", "cough", "sneeze", "diarrhea",
                             "রোগ", "অসুস্থ", "মারা", "লক্ষণ"],
    "feeding":              ["feed", "food", "diet", "protein", "calcium",
                             "খাবার", "খাদ্য", "দানা"],
    "vaccination":          ["vaccine", "vaccination", "immunize", "dose",
                             "টিকা", "ভ্যাক্সিন"],
    "biosecurity":          ["disinfect", "biosecurity", "sanitize", "clean",
                             "জীবনিরাপত্তা", "পরিষ্কার"],
    "egg_production":       ["egg", "laying", "production", "layer",
                             "ডিম", "উৎপাদন", "লেয়ার"],
    "broiler_management":   ["broiler", "weight", "growth", "fcr", "harvest",
                             "ব্রয়লার", "ওজন", "বৃদ্ধি"],
    "weather_advisory":     ["weather", "rain", "heat", "cold", "storm",
                             "আবহাওয়া", "গরম", "ঠান্ডা", "বৃষ্টি"],
    "market_price":         ["price", "cost", "market", "sell", "buy",
                             "দাম", "বাজার", "বিক্রি"],
    "general":              [],
}


async def classify_intent(message: str, gemini: GeminiClient) -> str:
    message_lower = message.lower()
    scores = {
        intent: sum(1 for kw in keywords if kw in message_lower)
        for intent, keywords in INTENT_CATEGORIES.items()
    }
    best = max(scores, key=scores.get)
    if scores[best] > 0:
        return best

    llm_intent = await gemini.classify_intent_llm(message)
    if llm_intent in INTENT_CATEGORIES:
        return llm_intent
    return "general"
```

### 7.7 Full Chat Service Flow

```python
# app/services/chat_service.py

class ChatService:
    async def process_message(
        self, session_id: str, user_id: str, text: str,
        image: UploadFile | None, language: str, db: AsyncSession,
    ) -> tuple[ChatMessage, ChatMessage]:
        """
        Pipeline:
        1. Upload image if present
        2. Save user message
        3. Classify intent (keyword → Flash Lite fallback)
        4. Get chat history
        5. RAG retrieval (poultry knowledge base)
        6. Enrich with live data (weather/market/flock) if relevant
        7. Select system prompt by language
        8. Generate AI response (text or vision)
        9. Apply safety filters
        10. Save AI response
        11. Auto-generate session title (first message)
        12. Award loyalty points
        """
        image_url = None
        if image:
            image_url = await self._upload_image(image, session_id)

        user_msg = await self.chat_repo.create_message(
            db, session_id=session_id, role="user",
            content=text, image_url=image_url,
        )

        intent = await classify_intent(text, self.gemini)
        history = await self.chat_repo.get_recent_messages(db, session_id, limit=10)
        rag_context = await self.rag.retrieve(query=text, category=intent, top_k=5)

        enrichment = ""
        if intent == "weather_advisory":
            weather = await self.weather_service.get_current(user_id, db)
            enrichment = f"\nCurrent weather: {weather.temp_c}°C, {weather.condition}"
        elif intent == "market_price":
            prices = await self.market_service.get_latest(db)
            enrichment = f"\nCurrent prices: {self._format_prices(prices)}"
        elif intent in ("egg_production", "broiler_management"):
            flock_data = await self.farm_service.get_user_flock_summary(user_id, db)
            enrichment = f"\nFlock data: {flock_data}"

        system_prompt = SYSTEM_PROMPT_BN if language == "bn" else SYSTEM_PROMPT_EN

        if image and intent in ("disease_diagnosis", "general"):
            image_bytes = await image.read()
            ai_text = await self.gemini.analyze_image(
                image_bytes=image_bytes, mime_type=image.content_type,
                prompt=f"{system_prompt}\n\n{rag_context}\n\nUser: {text}",
            )
        else:
            full_context = f"{rag_context}\n{enrichment}" if rag_context else enrichment
            ai_text = await self.gemini.generate_text(
                system_prompt=system_prompt, user_message=text,
                chat_history=self._format_history(history), context=full_context,
            )

        ai_text = await self._apply_safety_filters(ai_text)

        ai_msg = await self.chat_repo.create_message(
            db, session_id=session_id, role="assistant", content=ai_text,
            message_metadata={
                "intent": intent,
                "rag_sources": [c.id for c in rag_context.chunks] if rag_context else [],
                "model": settings.GEMINI_TEXT_MODEL,
            },
        )

        msg_count = await self.chat_repo.count_messages(db, session_id)
        if msg_count <= 2:
            title = await self._generate_title(text)
            await self.chat_repo.update_session_title(db, session_id, title)

        await self._award_points(db, user_id, points=5)
        return user_msg, ai_msg
```

---

## 8. RAG Pipeline — Poultry Knowledge Base

### 8.1 Why RAG

The PRD identifies over-reliance on AI health prompts as a high-impact risk. RAG grounds Gemini's responses in verified poultry veterinary documents, vaccination protocols, and farm management guides rather than relying solely on training data.

### 8.2 Knowledge Base Sources

| Source Type | Examples | Format |
|------------|---------|--------|
| Government Publications | DLS (Department of Livestock Services) guidelines | PDF |
| Veterinary References | Poultry disease encyclopedias, treatment protocols | PDF/DOCX |
| FAO Publications | Good poultry production practices | PDF |
| Feed Manufacturer Guides | Aftab, Kazi, Paragon feed charts | PDF |
| Vaccination Schedules | Standard BD poultry vaccination protocols | Markdown |
| Local Best Practices | Regional biosecurity and farm management guides | Text |

### 8.3 Ingestion Pipeline

```
Source PDF
   │
   ├── (a) Native-text PDF  →  pypdf / pdfplumber  ─┐
   │                                                 │
   └── (b) Scanned PDF      →  pdf2image → Tesseract ┤
                                (eng + ben models)   │
                                                     ▼
                                              Cleaning → Chunking → BGE-M3 embed
                                                                          │
                                                                          ▼
                                                          PostgreSQL (pgvector + HNSW)
```

```python
# app/ai/rag/ingestion.py

class KnowledgeIngestion:
    def __init__(self, embedder: Embedder, db: AsyncSession):
        self.embedder = embedder
        self.db = db

    async def ingest_document(self, file_path: str, category: str, metadata: dict | None = None):
        text, ocr_used = self._extract_text(file_path)
        text = self._clean_text(text)
        chunks = self._chunk_text(text, chunk_size=500, overlap=50)
        embeddings = await self.embedder.embed_batch([c.text for c in chunks])

        for chunk, embedding in zip(chunks, embeddings):
            knowledge_chunk = KnowledgeChunk(
                content=chunk.text, source_document=file_path,
                category=category, embedding=embedding,
                chunk_metadata={**(metadata or {}), "chunk_index": chunk.index,
                                "ocr_source": ocr_used},
            )
            self.db.add(knowledge_chunk)
        await self.db.commit()

    def _extract_text(self, file_path: str) -> tuple[str, bool]:
        try:
            with pdfplumber.open(file_path) as pdf:
                text = "\n\n".join(page.extract_text() or "" for page in pdf.pages)
        except Exception:
            text = ""

        if len(text.strip()) >= 100:
            return text, False

        ocr_text_parts = []
        for page_image in convert_from_path(file_path, dpi=300):
            page_text = pytesseract.image_to_string(page_image, lang="eng+ben")
            ocr_text_parts.append(page_text)
        return "\n\n".join(ocr_text_parts), True

    def _chunk_text(self, text: str, chunk_size: int, overlap: int) -> list:
        words = text.split()
        chunks = []
        start = 0
        while start < len(words):
            end = start + chunk_size
            chunk_text = " ".join(words[start:end])
            chunks.append(ChunkData(text=chunk_text, index=len(chunks), start=start, end=min(end, len(words))))
            start += chunk_size - overlap
        return chunks
```

### 8.4 Embedding Model — BAAI/bge-m3

1024-dimensional vectors, state-of-the-art multilingual retrieval including strong Bangla support.

```python
# app/ai/rag/embedder.py

from sentence_transformers import SentenceTransformer
import asyncio

class Embedder:
    def __init__(self):
        self.model = SentenceTransformer("BAAI/bge-m3")

    async def embed(self, text: str) -> list[float]:
        loop = asyncio.get_running_loop()
        vec = await loop.run_in_executor(
            None, lambda: self.model.encode(text, normalize_embeddings=True)
        )
        return vec.tolist()

    async def embed_batch(self, texts: list[str], batch_size: int = 8) -> list[list[float]]:
        loop = asyncio.get_running_loop()
        vecs = await loop.run_in_executor(
            None, lambda: self.model.encode(texts, normalize_embeddings=True, batch_size=batch_size),
        )
        return vecs.tolist()
```

### 8.5 Cross-Encoder Reranker

```python
# app/ai/rag/reranker.py

from sentence_transformers import CrossEncoder
import asyncio

class Reranker:
    def __init__(self):
        self.model = CrossEncoder("BAAI/bge-reranker-v2-m3", max_length=512)

    async def rerank(self, query: str, candidates: list, top_k: int = 5) -> list:
        if not candidates:
            return []
        pairs = [(query, c.content) for c in candidates]
        loop = asyncio.get_running_loop()
        scores = await loop.run_in_executor(
            None, lambda: self.model.predict(pairs)
        )
        scored = sorted(zip(candidates, scores), key=lambda x: x[1], reverse=True)
        return [c for c, _ in scored[:top_k]]
```

### 8.6 Retriever with Soft Category Filter

```python
# app/ai/rag/retriever.py

class Retriever:
    async def retrieve(self, query: str, category: str, top_k: int = 5) -> list:
        query_embedding = await self.embedder.embed(query)

        # Soft filter: match intent category OR general (fallback)
        candidates = await self.knowledge_repo.vector_search(
            embedding=query_embedding,
            categories=[category, "general"] if category != "general" else ["general"],
            top_k=25,
            max_distance=0.5,
        )

        # Rerank for precision
        reranked = await self.reranker.rerank(query, candidates, top_k=top_k)
        return reranked
```

---

## 9. Poultry Disease Image Diagnosis

When a farmer photographs a sick bird, the image is sent to Gemini Vision alongside a disease-specific prompt template and RAG context from the poultry disease knowledge base.

```python
# app/ai/prompts/disease_diagnosis.py

DISEASE_DIAGNOSIS_PROMPT = """
Analyze this image of a chicken for signs of disease.

Describe:
1. Observable symptoms (swelling, discoloration, discharge, lesions, posture)
2. Most likely diseases (ranked by probability)
3. Immediate actions the farmer should take
4. Whether a veterinarian should be contacted urgently
5. Recommended medicines and dosages (if applicable)

Always mention withdrawal periods for any medicines recommended.
If you cannot determine the disease from the image, explain what
additional information or photos you would need.
"""
```

---

## 10. Weather Integration

### 10.1 OpenWeatherMap Integration

```python
# app/services/weather_service.py

class WeatherService:
    async def get_forecast(self, lat: float, lon: float) -> WeatherResponse:
        cached = await redis.get(f"weather:{lat:.2f}:{lon:.2f}")
        if cached:
            return WeatherResponse.model_validate_json(cached)

        data = await self._fetch_from_api(lat, lon)
        await redis.set(f"weather:{lat:.2f}:{lon:.2f}", data.model_dump_json(), ex=3600)
        return data
```

### 10.2 Bangladesh Location Mapping

```python
BD_REGIONS = {
    "dhaka": (23.81, 90.41),
    "gazipur": (23.99, 90.43),
    "chattogram": (22.36, 91.78),
    "rajshahi": (24.37, 88.60),
    "khulna": (22.82, 89.53),
    "sylhet": (24.90, 91.87),
    "rangpur": (25.74, 89.28),
    "barishal": (22.70, 90.37),
}
```

---

## 11. Market Price Intelligence

### 11.1 Data Sources

| # | Source | URL | Method | Update freq |
|---|--------|-----|--------|------------|
| 1 | Department of Agricultural Marketing (DAM) | dam.gov.bd | HTML scrape | Daily |
| 2 | Trading Corporation of Bangladesh (TCB) | tcb.portal.gov.bd | HTML scrape | Daily |
| 3 | Manual override | Admin API `POST /admin/market/prices/bulk` | CSV upload | On demand |

**Product types scraped:** Egg (per piece / per dozen), Broiler meat (per kg), Layer meat (per kg), Feed (per bag/kg), Day-old chicks (per piece).

### 11.2 Stale-Data Strategy

Scrapers break when source HTML changes. The v1 design degrades gracefully:

1. Each scraper run is a Celery task with 3 retries (exponential backoff).
2. If all retries fail, mark last successful prices as `is_stale=true` and fire Sentry alert.
3. API continues serving last-known-good data with `is_stale` and `last_updated_at`.
4. After 48h of staleness, add `data_warning` field so the UI shows a hard banner.
5. Manual admin endpoint accepts CSV upload as override.

### 11.3 Market Scraper

```python
# app/workers/tasks/market_scraper.py

@celery_app.task(bind=True, max_retries=3, default_retry_delay=300)
def scrape_market_prices(self):
    prices = []
    failures = []

    for name, scraper in [("dam", scrape_dam_poultry), ("tcb", scrape_tcb_poultry)]:
        try:
            prices.extend(scraper())
        except Exception as exc:
            failures.append(name)
            sentry_sdk.capture_exception(exc)

    if not prices:
        with task_db_session() as db:
            mark_all_stale(db)
        sentry_sdk.capture_message(
            f"market_scraper: all sources failed ({failures})",
            level="error",
        )
        raise self.retry(exc=Exception("all market scrapers failed"))

    processed = calculate_trends(prices)
    with task_db_session() as db:
        for price in processed:
            upsert_market_price(db, price)
```

### 11.4 Trend Calculation

```python
def calculate_trends(current_prices: list[MarketPrice]) -> list[MarketPrice]:
    for price in current_prices:
        yesterday = get_previous_price(price.product_type, price.market_name)
        if yesterday:
            change = ((price.price_bdt - yesterday.price_bdt) / yesterday.price_bdt) * 100
            price.change_percent = round(change, 1)
            price.trend = PriceTrend.UP if change > 1 else (PriceTrend.DOWN if change < -1 else PriceTrend.STABLE)
        else:
            price.trend = PriceTrend.STABLE
            price.change_percent = 0.0
    return current_prices
```

---

## 12. Farm Insights & Analytics Engine

### 12.1 Insight Generation Sources

Insights are generated by combining:
- **Production analysis:** Egg production drops, mortality spikes, FCR degradation
- **Task compliance:** Overdue vaccinations, missed feeding schedules
- **Weather forecast:** Temperature alerts affecting flock health
- **Market signals:** Price changes suggesting optimal sell timing
- **AI-generated:** Gemini analysis of the farmer's full context

### 12.2 Production Analysis Rules

```python
# app/services/insights_service.py

PRODUCTION_THRESHOLDS = {
    "egg_drop": {
        "warning": 10,   # % drop vs. 7-day avg
        "critical": 20,
        "action_warning": "Egg production dropped {pct}%. Check feed quality and water supply.",
        "action_critical": "Significant egg production drop ({pct}%). Check for disease symptoms, feed contamination, or stress factors. Consider veterinary consultation.",
    },
    "mortality_spike": {
        "warning": 2,    # % daily mortality (of total flock)
        "critical": 5,
        "action_warning": "Mortality rate elevated at {pct}%. Monitor flock closely for symptoms.",
        "action_critical": "CRITICAL: Mortality rate {pct}%. Isolate affected birds immediately. Contact veterinarian.",
    },
    "fcr_deviation": {
        "warning": 0.3,  # FCR deviation from target
        "critical": 0.5,
        "action_warning": "Feed conversion ratio is above target. Review feed quality and feeding schedule.",
    },
}

class InsightsService:
    async def generate_daily_insights(self, user_id: str, db: AsyncSession) -> list[FarmInsight]:
        insights = []
        sheds = await self.farm_repo.get_user_sheds(db, user_id)

        for shed in sheds:
            # Check egg production trends
            if shed.flock_type in (FlockType.LAYER, FlockType.MIXED):
                insights.extend(await self._check_egg_production(shed, db))

            # Check mortality
            insights.extend(await self._check_mortality(shed, db))

            # Check overdue tasks
            insights.extend(await self._check_overdue_tasks(user_id, shed, db))

        # Weather-based insights
        insights.extend(await self._check_weather_alerts(user_id, db))

        # Market opportunity insights
        insights.extend(await self._check_market_opportunities(db))

        return sorted(insights, key=lambda i: {"critical": 0, "warning": 1, "info": 2}[i.severity.value])
```

---

## 13. Real-time Communication

### 13.1 SSE for Chat Streaming

```python
# app/api/v1/chat.py

@router.get("/sessions/{session_id}/messages/stream")
async def stream_ai_response(
    session_id: str, text: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    async def event_generator():
        async for chunk in chat_service.process_message_stream(
            session_id=session_id, user_id=user.id,
            text=text, language=user.language_pref, db=db,
        ):
            yield {
                "event": "message",
                "data": json.dumps({
                    "chunk": chunk.text, "done": chunk.is_final,
                    "message_id": chunk.message_id if chunk.is_final else None,
                }),
            }
    return EventSourceResponse(event_generator())
```

### 13.2 WebSocket for Live AI

```python
# app/api/v1/live_ai.py

@router.websocket("/stream")
async def live_ai_stream(websocket: WebSocket, token: str):
    user = await authenticate_ws_token(token)
    if not user:
        await websocket.close(code=4001, reason="Unauthorized")
        return

    # Guardrail checks
    can_start, rejection = await check_live_ai_guardrails(user.id)
    if not can_start:
        await websocket.accept()
        await websocket.send_json({"type": "error", "code": rejection.code, "message": rejection.message})
        await websocket.close(code=4003)
        return

    await websocket.accept()

    try:
        session = await session_manager.start_session(
            user_id=user.id, language=user.language_pref, tools=LIVE_AI_TOOLS,
        )

        async def forward_client_to_gemini():
            try:
                while True:
                    raw = await websocket.receive_text()
                    msg = json.loads(raw)
                    if msg["type"] == "audio":
                        await session_manager.send_audio(user.id, base64.b64decode(msg["data"]))
                    elif msg["type"] == "video_frame":
                        await session_manager.send_video_frame(user.id, base64.b64decode(msg["data"]))
                    elif msg["type"] == "text":
                        await session.send_realtime_input(text=msg["text"])
                    elif msg["type"] == "end_session":
                        break
            except WebSocketDisconnect:
                pass

        async def forward_gemini_to_client():
            try:
                async for response in session_manager.receive_responses(user.id):
                    if response["type"] == "audio":
                        await websocket.send_json({
                            "type": "audio",
                            "data": base64.b64encode(response["data"]).decode(),
                            "mime_type": response["mime_type"],
                        })
                    elif response["type"] in ("input_transcript", "output_transcript", "turn_complete"):
                        await websocket.send_json(response)
                    elif response["type"] == "tool_call":
                        results = await execute_tool_calls(response["function_calls"], user_id=user.id)
                        await session_manager.send_tool_response(user.id, results)
            except WebSocketDisconnect:
                pass

        await asyncio.gather(forward_client_to_gemini(), forward_gemini_to_client())

    finally:
        await session_manager.stop_session(user.id)
        await websocket.close()
```

### 13.3 Live AI Guardrails

| Guardrail | Limit | Enforcement |
|-----------|-------|-------------|
| Session duration | 15 minutes max | Server-side timer → graceful close |
| Daily per-user minutes | 30 minutes | Redis counter `live_ai:minutes:{user}:{date}` |
| Concurrent sessions per user | 1 | Redis set check before opening |
| Global daily spend cap | $20/day | Redis counter `live_ai:spend:{date}` (estimated from session duration) |

### 13.4 WS DB Connection Management

The WS handler does NOT use `Depends(get_db)`. Each tool call opens a short-lived session from the session factory to avoid holding connections for the entire WS lifetime.

### 13.5 Single-Replica Assumption (v1)

v1 deploys as a single FastAPI replica. `LiveSessionManager.active_sessions` lives in process memory. Multi-replica fan-out (Redis pub/sub, sticky sessions) is deferred to v1.1.

---

## 14. File Storage & Media Handling

### 14.1 S3-Compatible Storage

```python
# app/core/storage.py

class StorageClient:
    def __init__(self, settings):
        self.client = boto3.client(
            "s3", endpoint_url=settings.S3_ENDPOINT,
            aws_access_key_id=settings.S3_ACCESS_KEY,
            aws_secret_access_key=settings.S3_SECRET_KEY,
            config=Config(signature_version="s3v4"),
        )
        self.bucket = settings.S3_BUCKET

    async def upload_file(self, file_bytes: bytes, key: str, content_type: str) -> str:
        self.client.put_object(
            Bucket=self.bucket, Key=key, Body=file_bytes, ContentType=content_type,
        )
        return f"{self.client.meta.endpoint_url}/{self.bucket}/{key}"
```

### 14.2 File Organization

```
goldenchicken-media/
├── avatars/{user_id}/avatar.jpg
├── chat-images/{session_id}/{message_id}.jpg
├── chat-images/{session_id}/{message_id}_thumb.jpg
└── knowledge-docs/{category}/{filename}
```

---

## 15. Background Tasks & Job Queue

### 15.1 Celery Configuration

```python
# app/workers/celery_app.py

celery_app = Celery("goldenchicken", broker=settings.REDIS_URL, backend=settings.REDIS_URL)

celery_app.conf.update(
    task_serializer="json", result_serializer="json",
    accept_content=["json"], timezone="Asia/Dhaka",
    task_track_started=True, task_acks_late=True,
    worker_prefetch_multiplier=1,
)
```

### 15.2 Periodic Task Schedule

```python
celery_app.conf.beat_schedule = {
    "scrape-market-prices": {
        "task": "app.workers.tasks.market_scraper.scrape_market_prices",
        "schedule": crontab(minute=0, hour="*/6"),
    },
    "refresh-weather-cache": {
        "task": "app.workers.tasks.weather_updater.refresh_weather",
        "schedule": crontab(minute=0, hour="*"),
    },
    "generate-daily-insights": {
        "task": "app.workers.tasks.analytics.generate_insights",
        "schedule": crontab(minute=0, hour=6),   # 6 AM BDT daily
    },
    "check-overdue-tasks": {
        "task": "app.workers.tasks.reminders.check_overdue_tasks",
        "schedule": crontab(minute="*/30"),
    },
    "generate-recurring-tasks": {
        "task": "app.workers.tasks.reminders.generate_recurring_tasks",
        "schedule": crontab(minute=0, hour=0),   # Midnight BDT
    },
    "aggregate-analytics": {
        "task": "app.workers.tasks.analytics.daily_aggregation",
        "schedule": crontab(minute=0, hour=2),
    },
    "cleanup-expired-tokens": {
        "task": "app.workers.tasks.cleanup.remove_expired_sessions",
        "schedule": crontab(minute=0, hour=3),
    },
}
```

### 15.3 Sync DB Session for Celery

```python
# app/workers/db.py

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from contextlib import contextmanager

_sync_url = settings.DATABASE_URL.replace("+asyncpg", "+psycopg")

sync_engine = create_engine(_sync_url, pool_size=5, max_overflow=5, pool_pre_ping=True)
SyncSessionLocal = sessionmaker(sync_engine, class_=Session, expire_on_commit=False)

@contextmanager
def task_db_session():
    session = SyncSessionLocal()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()
```

---

## 16. Caching Strategy

| Cache Key Pattern | TTL | Data |
|------------------|-----|------|
| `weather:{lat}:{lon}` | 1 hour | Full weather + forecast JSON |
| `market:prices:{region}` | 30 minutes | Market price list |
| `market:prices:{product}:{region}` | 30 minutes | Product-specific prices |
| `user:profile:{user_id}` | 15 minutes | User profile data |
| `farm:overview:{user_id}` | 5 minutes | Farm summary (bird counts, today's eggs) |
| `health:tabs` | 24 hours | Health tab catalog |
| `chat:session:{id}:messages` | 5 minutes | Recent message IDs |
| `ai:rate:{user_id}` | 1 minute | Rate limit counter |
| `blacklist:{token_jti}` | 15 minutes | Revoked access token |
| `live_ai:minutes:{user}:{date}` | 24 hours | Daily Live AI usage minutes |
| `live_ai:spend:{date}` | 24 hours | Global daily Live AI spend |

---

## 17. Multilingual Support (Bangla & English)

### 17.1 Strategy

1. **System Prompt Selection:** Bangla or English system prompt based on `user.language_pref`
2. **Response Language:** Gemini instructed to respond in user's language
3. **Static Content:** Error messages, insight descriptions in both languages
4. **Health Tabs:** Disease names, symptoms, prompts stored in both languages

### 17.2 Language Detection

```python
# app/utils/bangla.py

import re

BANGLA_PATTERN = re.compile(r'[\u0980-\u09FF]')

def detect_language(text: str) -> str:
    bangla_chars = len(BANGLA_PATTERN.findall(text))
    total_chars = len(text.replace(" ", ""))
    if total_chars == 0:
        return "en"
    return "bn" if (bangla_chars / total_chars) > 0.3 else "en"
```

---

## 18. Logging, Monitoring & Observability

### 18.1 Structured Logging

```python
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ],
)
logger = structlog.get_logger()
```

### 18.2 Monitoring Stack (v1)

| Tool | Purpose | Status |
|------|---------|--------|
| Sentry | Error tracking, exception alerts | v1 |
| structlog | JSON-structured logs to stdout | v1 |
| Health endpoints | `/health` and `/health/ready` | v1 |
| Prometheus / Grafana | Metrics + dashboards | Deferred to v1.1 |

### 18.3 Key Signals

| Signal | Threshold |
|--------|-----------|
| Unhandled exceptions | Any new Sentry issue → alert |
| Gemini API errors | > 5 in 5 minutes |
| Live AI session failures | > 3 in 1 hour |
| Slow chat responses | > 5% over 8 seconds |
| Market scraper failures | Any full scrape failure |

---

## 19. Security Hardening

### 19.1 Measures

| Layer | Measure |
|-------|---------|
| Transport | HTTPS only (TLS 1.3), HSTS |
| Authentication | Bcrypt (12 rounds), JWT with short expiry |
| Authorization | Role-based access, resource ownership checks |
| Input Validation | Pydantic schemas, ORM prevents SQL injection |
| Rate Limiting | Redis sliding window per user and per IP |
| CORS | Whitelist allowed origins |
| File Upload | MIME type validation, size limits |
| AI Safety | Output filtering, prompt injection guards |

### 19.2 Prompt Injection Protection

```python
# app/ai/safety.py

INJECTION_PATTERNS = [
    r"ignore\s+(previous|above|all)\s+instructions",
    r"you\s+are\s+now\s+",
    r"system\s*:\s*",
    r"act\s+as\s+",
    r"pretend\s+",
    r"jailbreak",
]

def sanitize_user_input(text: str) -> str:
    for pattern in INJECTION_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            logger.warning("prompt_injection_attempt", input=text[:100])
            return "Please ask a question about poultry farming."
    return text
```

### 19.3 Data Retention

| Data Type | Retention |
|-----------|-----------|
| Chat sessions & messages | Indefinite |
| Uploaded images | 90 days |
| Soft-deleted users | 30 days then hard delete |
| Refresh tokens | Until `expires_at` or revoked |
| Access token blacklist | TTL = remaining token lifetime |

---

## 20. Error Handling Strategy

### 20.1 Global Exception Handler

```python
@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "status": "error",
            "error": {"code": exc.error_code, "message": exc.message, "details": exc.details},
        },
    )
```

### 20.2 Custom Exception Classes

```python
class AppException(Exception):
    def __init__(self, status_code: int, error_code: str, message: str, details: list | None = None):
        self.status_code = status_code
        self.error_code = error_code
        self.message = message
        self.details = details

class NotFoundError(AppException):
    def __init__(self, resource: str):
        super().__init__(404, "NOT_FOUND", f"{resource} not found")

class ValidationError(AppException):
    def __init__(self, message: str, details: list | None = None):
        super().__init__(422, "VALIDATION_ERROR", message, details)

class AuthenticationError(AppException):
    def __init__(self, message: str = "Authentication required"):
        super().__init__(401, "AUTHENTICATION_REQUIRED", message)
```

---

## 21. Testing Strategy

### 21.1 Test Pyramid

| Layer | Count Target | Tools |
|-------|-------------|-------|
| Unit tests | ~70 | pytest, pytest-asyncio, factory-boy |
| Integration tests | ~15 | httpx async client, test DB |
| AI quality tests | ~10 | Custom benchmark scripts |

### 21.2 Critical Path Test Matrix

| Flow | Unit | Integration |
|------|------|-------------|
| Auth (register, login, refresh, logout) | ✓ | ✓ |
| Chat (send message, stream, feedback) | ✓ | ✓ |
| Production (egg record, chicken record, trends) | ✓ | ✓ |
| Task (create, complete, overdue check) | ✓ | ✓ |
| Health tabs (list, ask AI) | ✓ | ✓ |
| RAG (embed, retrieve, rerank) | ✓ | |
| Intent classification | ✓ | |
| Market scraper | ✓ | ✓ |
| Insights generation | ✓ | |
| Prompt injection guard | ✓ | |
| Loyalty points | ✓ | |

---

## 22. Infrastructure & Deployment

### 22.1 Docker Compose (Local Development)

```yaml
version: "3.8"

services:
  app:
    build: .
    ports: ["8000:8000"]
    env_file: .env
    depends_on: [db, redis, minio]
    volumes: [./app:/app/app]
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

  db:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_DB: goldenchicken
      POSTGRES_USER: goldenchicken
      POSTGRES_PASSWORD: localpassword
    ports: ["5432:5432"]
    volumes: [pgdata:/var/lib/postgresql/data]

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports: ["9000:9000", "9001:9001"]
    volumes: [miniodata:/data]

  celery-worker:
    build: .
    command: celery -A app.workers.celery_app worker --loglevel=info --concurrency=4
    env_file: .env
    depends_on: [db, redis]

  celery-beat:
    build: .
    command: celery -A app.workers.celery_app beat --loglevel=info
    env_file: .env
    depends_on: [redis]

volumes:
  pgdata:
  miniodata:
```

---

## 23. Cloud Provider Recommendation

### Primary: AWS (ap-south-1 Mumbai)

| Factor | Service |
|--------|---------|
| ~50ms latency to Dhaka | ap-south-1 region |
| PostgreSQL | RDS with pgvector |
| Redis | ElastiCache |
| Storage | S3 |
| Containers | ECS Fargate |
| SSL | ACM (free) |

### Alternative: DigitalOcean (Singapore)

| Service | Monthly Cost |
|---------|-------------|
| App Platform / Droplet | $24–48 |
| Managed PostgreSQL | $15 |
| Managed Redis | $15 |
| Spaces (S3-compatible) | $5 |
| **Total** | **~$60–85/mo** |

---

## 24. CI/CD Pipeline

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: pgvector/pgvector:pg16
        env:
          POSTGRES_DB: test_goldenchicken
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports: ["5432:5432"]
      redis:
        image: redis:7-alpine
        ports: ["6379:6379"]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements.txt -r requirements-dev.txt
      - run: ruff check app/ tests/
      - run: pytest tests/ -v --cov=app --cov-report=xml
      - run: pip-audit
```

---

## 25. Cost Estimation

### 25.1 Monthly Cost Breakdown (1,000 active users)

| Service | Est. Monthly |
|---------|-------------|
| Infrastructure (ECS/RDS/Redis/S3/ALB) | $100–155 |
| Gemini 3 Flash (text chat, ~100K queries) | $15–30 |
| Gemini 3 Flash (image diagnosis, ~5K images) | $5–10 |
| Gemini 3.1 Flash Lite (intent/titles, ~100K calls) | $2–5 |
| Gemini 3.1 Flash Live (voice, ~2K sessions) | $15–40 |
| OpenWeatherMap | Free |
| Sentry | Free |
| **Grand Total** | **$137–240/mo** |

---

## 26. Sprint Breakdown & Milestones

### Sprint 1 (Week 1–2): Foundation + Farm Domain

- FastAPI project scaffold with full folder structure
- Docker Compose (PostgreSQL + pgvector, Redis, MinIO)
- SQLAlchemy models + Alembic migrations: users, user_sessions, farms, sheds
- Pydantic schemas for auth, user, farm
- Core infrastructure: database.py, redis.py, security.py, dependencies.py
- Config management, global error handlers, response envelope
- Sentry + structlog setup
- Health check endpoints
- **Deliverable:** Running Docker stack, Farm entity migrated

### Sprint 2 (Week 3–4): Auth + Production Tracking

- Auth service: register, login, JWT, refresh token rotation, social auth
- Token revocation (Redis blacklist)
- User profile CRUD + avatar upload
- Farm & Shed CRUD endpoints
- Egg record & chicken record CRUD
- Trend calculation service (7d/30d/90d)
- Rate limiting middleware
- **Deliverable:** Full auth flow, farm setup, production record keeping

### Sprint 3 (Week 5–6): AI Engine + Chat + Health Tabs

- Gemini client wrapper (text + vision)
- System prompt engineering (EN + BN) with safety guardrails
- Two-stage intent classification (keyword → Flash Lite)
- Chat session CRUD, message send/receive
- SSE streaming for chat
- Health tab database seed (Newcastle, AI, Marek's, Coccidiosis, IB, Fowl Pox)
- Health tab → chat integration (prefilled prompts)
- Auto-generated session titles, message feedback, loyalty points
- **Deliverable:** Functional AI chat with health tabs

### Sprint 4 (Week 7–8): RAG + Image Diagnosis + Tasks

- Knowledge base ingestion pipeline (PDF + OCR)
- BAAI/bge-m3 embedding, pgvector HNSW index
- Cross-encoder reranker (bge-reranker-v2-m3)
- Context builder, retriever with soft category filter
- Poultry disease image diagnosis via Gemini Vision
- Image upload, validation, compression, S3 storage
- Task management CRUD (create, complete, delete)
- Recurring task generation (daily/weekly/monthly)
- Overdue task detection
- **Deliverable:** RAG-grounded responses, image diagnosis, task management

### Sprint 5 (Week 9–10): Weather, Market, Insights

- OpenWeatherMap integration with caching
- Market price scrapers (DAM + TCB) as Celery tasks
- Stale-data degradation strategy
- Market price API with trends
- Farm insights engine (production analysis, weather alerts, overdue tasks)
- Insights & proposed actions endpoints
- Celery Beat schedule
- Sync DB session for Celery workers
- **Deliverable:** All data-driven APIs with market intelligence

### Sprint 6 (Week 11–12): Live AI + Real-time

- Gemini 3.1 Flash Live integration (client + session manager)
- Audio forwarding (PCM 16kHz in, 24kHz out)
- Camera frame forwarding (JPEG ≤1FPS)
- Function calling tools (weather, market, flock status, tasks)
- Live AI guardrails (session limit, daily cap, concurrent limit, spend cap)
- WebSocket endpoint with full bidirectional protocol
- WS handler uses session factory per tool call (no Depends(get_db))
- Alert system (production anomalies, weather alerts)
- **Deliverable:** Live AI with voice, camera, function calling

### Sprint 7 (Week 13–14): Testing, Security & Polish

- Unit + integration tests (~80% coverage target)
- AI prompt quality testing
- RAG retrieval accuracy tests
- Security audit (OWASP checklist)
- Prompt injection coverage
- API documentation review (OpenAPI/Swagger)
- Data retention job verification
- Performance profiling
- **Deliverable:** Production-ready, tested backend

### Sprint 8 (Week 15): Deployment & Launch

- Pick deployment target (AWS / DigitalOcean / VPS)
- Provision infrastructure
- CI/CD pipeline finalization
- Production environment configuration
- SSL setup, database migration, knowledge base ingestion
- Smoke load test
- Sentry release tagging
- **Deliverable:** v1.0 deployed to production

### v1.1 Backlog

- Multi-replica fan-out (Redis pub/sub, sticky sessions)
- Prometheus + Grafana
- FCM push notifications
- Password reset + phone OTP
- RAG chatbot (file upload + grounded Q&A from user documents)
- Sensor integrations (temperature, humidity)
- Veterinary collaboration features

---

## Appendix A: Environment Variables

```bash
# .env.example

# ─── App ───────────────────────────────────────────────
APP_ENV=development
APP_DEBUG=true
APP_VERSION=1.0.0
APP_SECRET_KEY=your-256-bit-secret
APP_ALLOWED_ORIGINS=http://localhost:3000

# ─── Database ──────────────────────────────────────────
DATABASE_URL=postgresql+asyncpg://goldenchicken:password@localhost:5432/goldenchicken

# ─── Redis ─────────────────────────────────────────────
REDIS_URL=redis://localhost:6379/0

# ─── Gemini AI ─────────────────────────────────────────
GEMINI_API_KEY=your-gemini-api-key
GEMINI_TEXT_MODEL=gemini-3-flash-preview
GEMINI_LITE_MODEL=gemini-3.1-flash-lite-preview
GEMINI_LIVE_MODEL=gemini-3.1-flash-live-preview

# ─── Embedding & Reranker ──────────────────────────────
EMBEDDING_MODEL=BAAI/bge-m3
EMBEDDING_DIM=1024
RERANKER_MODEL=BAAI/bge-reranker-v2-m3
RAG_TOP_K_VECTOR=25
RAG_TOP_K_RERANK=5
RAG_MAX_COSINE_DISTANCE=0.5

# ─── External APIs ─────────────────────────────────────
OPENWEATHERMAP_API_KEY=your-owm-key
GOOGLE_MAPS_API_KEY=your-maps-key

# ─── Storage (S3/MinIO) ────────────────────────────────
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET=goldenchicken-media

# ─── Auth ──────────────────────────────────────────────
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=15
JWT_REFRESH_TOKEN_EXPIRE_DAYS=30
JWT_ALGORITHM=HS256

# ─── Firebase ──────────────────────────────────────────
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_PATH=/run/secrets/firebase.json

# ─── Live AI Guardrails ────────────────────────────────
LIVE_AI_SESSION_MAX_MINUTES=15
LIVE_AI_DAILY_MINUTES_PER_USER=30
LIVE_AI_MAX_CONCURRENT_PER_USER=1
LIVE_AI_DAILY_SPEND_CAP_CENTS=2000

# ─── Market Scrapers ──────────────────────────────────
MARKET_DAM_SCRAPER_ENABLED=true
MARKET_TCB_SCRAPER_ENABLED=true
MARKET_STALE_HOURS=24

# ─── Observability ─────────────────────────────────────
SENTRY_DSN=
LOG_LEVEL=INFO

# ─── Data Retention ───────────────────────────────────
RETENTION_IMAGE_DAYS=90
RETENTION_SOFT_DELETED_USER_DAYS=30
```

## Appendix B: PRD ↔ Backend Mapping

| PRD Requirement | Backend Module | API Endpoint(s) |
|----------------|---------------|-----------------|
| FR-01: Health tabs & AI prompt chat | `health_service` + `chat_service` + RAG | `/health/tabs`, `/health/ask`, `/chat/*` |
| FR-02: Egg & chicken record tracker | `production_service` | `/sheds/{id}/eggs`, `/sheds/{id}/chickens` |
| FR-03: Trend graph & performance view | `production_service` (trends) | `/sheds/{id}/trends/*`, `/farms/{id}/trends/overview` |
| FR-04: Task list & routine reminder planner | `task_service` | `/tasks/*` |
| FR-05: Farm insight & alert dashboard | `insights_service` | `/insights`, `/insights/actions` |
| Common: Bangla/English | System prompt selection + language detection | All endpoints via `language_pref` |
| Common: Live AI Agent | Gemini 3.1 Flash Live | `/live-ai/stream` (WebSocket) |
| Common: RAG Chatbot | `rag_service` + `chat_service` | `/chat/*` (with RAG context) |
| Common: Loyalty Points | `user_service` | `/users/me` (points field) |

## Appendix C: API Response Time Targets

| Operation | Target |
|-----------|--------|
| Auth (login/register) | < 500ms |
| Profile fetch | < 200ms |
| Production record save | < 300ms |
| Trend data fetch | < 500ms |
| Task list fetch | < 300ms |
| Chat message (non-streaming) | < 5 seconds |
| Chat message (streaming first chunk) | < 1 second |
| Live AI (first audio response) | < 800ms |
| Health tabs list | < 200ms |
| Weather fetch | < 500ms |
| Market prices | < 300ms |
| Image diagnosis | < 8 seconds |
| Insights dashboard | < 500ms |

## Appendix D: Canonical Poultry Disease Catalog (Bangladesh)

Health tabs seeded in the database at deployment. Each tab creates a prefilled prompt that opens an AI chat session.

| Code | English | Bangla | Severity | Symptoms |
|------|---------|--------|----------|----------|
| `newcastle` | Newcastle Disease | নিউক্যাসল রোগ | Critical | 6 |
| `avian_influenza` | Avian Influenza (Bird Flu) | বার্ড ফ্লু | Critical | 8 |
| `mareks` | Marek's Disease | মারেকস রোগ | Medium | 5 |
| `coccidiosis` | Coccidiosis | কক্সিডিওসিস | Medium | 4 |
| `infectious_bronchitis` | Infectious Bronchitis | সংক্রামক ব্রঙ্কাইটিস | High | 5 |
| `fowl_pox` | Fowl Pox | ফাউল পক্স | Low | 3 |
| `gumboro` | Gumboro Disease (IBD) | গামবোরো রোগ | High | 4 |
| `fowl_cholera` | Fowl Cholera | ফাউল কলেরা | High | 5 |
| `mycoplasmosis` | Mycoplasmosis (CRD) | মাইকোপ্লাজমোসিস | Medium | 4 |
| `salmonellosis` | Salmonellosis | সালমোনেলোসিস | Medium | 4 |

---

*End of Backend Implementation Plan*
