import asyncio
import logging

from app.workers.celery_app import celery_app

logger = logging.getLogger(__name__)


async def _generate_for_all_users():
    from app.core.database import async_session_factory
    from app.models.user import User
    from app.services.insights_service import insights_service
    from sqlalchemy import select

    async with async_session_factory() as db:
        stmt = select(User.id).where(User.is_active == True)
        result = await db.execute(stmt)
        user_ids = list(result.scalars().all())

        total_insights = 0
        for user_id in user_ids:
            try:
                insights = await insights_service.generate_daily_insights(db, user_id)
                total_insights += len(insights)
            except Exception:
                logger.error(f"Insight generation failed for user {user_id}", exc_info=True)

        await db.commit()
        logger.info(f"Generated {total_insights} insights for {len(user_ids)} users")


@celery_app.task
def generate_all_user_insights():
    asyncio.run(_generate_for_all_users())
