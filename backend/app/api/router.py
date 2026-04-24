from fastapi import APIRouter

from app.api.v1.health_check import router as health_router
from app.core.constants import API_V1_PREFIX

api_router = APIRouter(prefix=API_V1_PREFIX)

api_router.include_router(health_router)
