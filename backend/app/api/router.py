from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.chat import router as chat_router
from app.api.v1.diagnosis import router as diagnosis_router
from app.api.v1.farms import router as farms_router
from app.api.v1.health_check import router as health_router
from app.api.v1.health_tabs import router as health_tabs_router
from app.api.v1.insights import router as insights_router
from app.api.v1.live_ai import router as live_ai_router
from app.api.v1.market import router as market_router
from app.api.v1.production import router as production_router
from app.api.v1.tasks import router as tasks_router
from app.api.v1.users import router as users_router
from app.api.v1.weather import router as weather_router
from app.core.constants import API_V1_PREFIX

api_router = APIRouter(prefix=API_V1_PREFIX)

api_router.include_router(health_router)
api_router.include_router(auth_router)
api_router.include_router(users_router)
api_router.include_router(farms_router)
api_router.include_router(production_router)
api_router.include_router(chat_router)
api_router.include_router(health_tabs_router)
api_router.include_router(tasks_router)
api_router.include_router(diagnosis_router)
api_router.include_router(weather_router)
api_router.include_router(market_router)
api_router.include_router(insights_router)
api_router.include_router(live_ai_router)
