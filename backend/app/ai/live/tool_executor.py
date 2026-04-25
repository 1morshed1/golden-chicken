import logging
from datetime import date, timedelta

from google.genai import types as genai_types
from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import async_session_factory
from app.core.redis import get_redis
from app.models.farm import Farm, Shed
from app.models.production import ChickenRecord, EggRecord
from app.models.task import FarmTask
from app.services.market_service import market_service
from app.services.weather_service import weather_service

logger = logging.getLogger(__name__)


async def execute_tool_calls(
    function_calls: list, user_id: str
) -> list[genai_types.FunctionResponse]:
    responses = []
    for fc in function_calls:
        try:
            result = await _dispatch(fc.name, fc.args or {}, user_id)
        except Exception:
            logger.exception("Tool call %s failed", fc.name)
            result = {"error": f"Failed to execute {fc.name}"}
        responses.append(
            genai_types.FunctionResponse(name=fc.name, response=result)
        )
    return responses


async def _dispatch(name: str, args: dict, user_id: str) -> dict:
    if name == "get_weather":
        return await _get_weather(args.get("location", "dhaka"))
    elif name == "get_market_prices":
        return await _get_market_prices(args.get("product_type"))
    elif name == "get_flock_status":
        return await _get_flock_status(user_id, args.get("shed_name"))
    elif name == "get_pending_tasks":
        return await _get_pending_tasks(user_id)
    return {"error": f"Unknown tool: {name}"}


async def _get_weather(location: str) -> dict:
    redis = await get_redis()
    result = await weather_service.get_weather_by_region(location, redis)
    if not result:
        return {"error": f"Unknown region: {location}. Try: dhaka, gazipur, rajshahi, etc."}
    return {
        "location": result.location_name,
        "temperature_c": result.current.temp_c,
        "feels_like_c": result.current.feels_like_c,
        "condition": result.current.condition,
        "humidity": result.current.humidity,
        "advisory": result.poultry_advisory.message if result.poultry_advisory else "No weather alerts",
    }


async def _get_market_prices(product_type: str | None) -> dict:
    async with async_session_factory() as db:
        data = await market_service.get_latest_prices(
            db, product_type=product_type
        )
    prices = []
    for p in data.get("prices", []):
        prices.append({
            "product": p.product_type if hasattr(p, "product_type") else str(p),
            "price_bdt": p.price_per_unit if hasattr(p, "price_per_unit") else None,
            "unit": p.unit if hasattr(p, "unit") else None,
            "market": p.market_name if hasattr(p, "market_name") else None,
            "trend": p.trend if hasattr(p, "trend") else None,
        })
    return {
        "prices": prices,
        "warning": data.get("data_warning"),
    }


async def _get_flock_status(user_id: str, shed_name: str | None) -> dict:
    async with async_session_factory() as db:
        return await _query_flock_status(db, user_id, shed_name)


async def _query_flock_status(
    db: AsyncSession, user_id: str, shed_name: str | None
) -> dict:
    farm_stmt = select(Farm).where(
        and_(Farm.user_id == user_id, Farm.is_active.is_(True))
    )
    farms = (await db.execute(farm_stmt)).scalars().all()
    if not farms:
        return {"error": "No farms found"}

    farm_ids = [str(f.id) for f in farms]
    shed_stmt = select(Shed).where(
        and_(Shed.farm_id.in_(farm_ids), Shed.is_active.is_(True))
    )
    if shed_name:
        shed_stmt = shed_stmt.where(Shed.name.ilike(f"%{shed_name}%"))

    sheds = (await db.execute(shed_stmt)).scalars().all()
    if not sheds:
        return {"error": f"No sheds found{f' matching {shed_name}' if shed_name else ''}"}

    today = date.today()
    week_ago = today - timedelta(days=7)
    shed_summaries = []

    for shed in sheds:
        sid = str(shed.id)
        egg_stmt = select(EggRecord).where(
            and_(EggRecord.shed_id == sid, EggRecord.record_date == today)
        )
        egg_today = (await db.execute(egg_stmt)).scalar_one_or_none()

        mortality_stmt = select(ChickenRecord).where(
            and_(
                ChickenRecord.shed_id == sid,
                ChickenRecord.record_date >= week_ago,
            )
        )
        chicken_recs = (await db.execute(mortality_stmt)).scalars().all()
        total_mortality_7d = sum(r.mortality for r in chicken_recs)

        latest_birds = shed.bird_count
        if chicken_recs:
            latest = max(chicken_recs, key=lambda r: r.record_date)
            latest_birds = latest.total_birds

        shed_summaries.append({
            "shed_name": shed.name,
            "flock_type": shed.flock_type.value,
            "bird_count": latest_birds,
            "breed": shed.breed,
            "eggs_today": egg_today.total_eggs if egg_today else 0,
            "mortality_7d": total_mortality_7d,
            "status": shed.status.value,
        })

    return {"sheds": shed_summaries}


async def _get_pending_tasks(user_id: str) -> dict:
    async with async_session_factory() as db:
        today = date.today()
        today_stmt = (
            select(FarmTask)
            .where(
                and_(
                    FarmTask.user_id == user_id,
                    FarmTask.due_date == today,
                    FarmTask.is_completed.is_(False),
                )
            )
            .order_by(FarmTask.priority, FarmTask.due_time)
        )
        today_tasks = (await db.execute(today_stmt)).scalars().all()

        overdue_stmt = (
            select(FarmTask)
            .where(
                and_(
                    FarmTask.user_id == user_id,
                    FarmTask.is_completed.is_(False),
                    FarmTask.due_date < today,
                )
            )
            .order_by(FarmTask.due_date)
        )
        overdue_tasks = (await db.execute(overdue_stmt)).scalars().all()

    def _task_to_dict(t: FarmTask) -> dict:
        return {
            "title": t.title,
            "type": t.task_type,
            "due_date": str(t.due_date),
            "due_time": str(t.due_time) if t.due_time else None,
            "priority": t.priority,
        }

    return {
        "today_pending": [_task_to_dict(t) for t in today_tasks],
        "overdue": [_task_to_dict(t) for t in overdue_tasks],
        "today_count": len(today_tasks),
        "overdue_count": len(overdue_tasks),
    }
