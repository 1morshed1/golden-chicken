from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.farms import router as farms_router
from app.api.v1.health_check import router as health_router
from app.api.v1.production import router as production_router
from app.api.v1.users import router as users_router
from app.core.constants import API_V1_PREFIX

api_router = APIRouter(prefix=API_V1_PREFIX)

api_router.include_router(health_router)
api_router.include_router(auth_router)
api_router.include_router(users_router)
api_router.include_router(farms_router)
api_router.include_router(production_router)
