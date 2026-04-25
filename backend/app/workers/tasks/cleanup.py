import logging
from datetime import datetime, timedelta, timezone

from sqlalchemy import and_, delete, select, update

from app.models.user import User
from app.models.user_session import UserSession
from app.workers.celery_app import celery_app
from app.workers.db import task_db_session

logger = logging.getLogger(__name__)

IMAGE_RETENTION_DAYS = 90
SOFT_DELETE_RETENTION_DAYS = 30


@celery_app.task(name="app.workers.tasks.cleanup.run_data_retention")
def run_data_retention():
    with task_db_session() as db:
        expired_sessions = _cleanup_expired_sessions(db)
        hard_deleted = _cleanup_soft_deleted_users(db)
        db.commit()

    logger.info(
        "data_retention_complete",
        extra={
            "expired_sessions_removed": expired_sessions,
            "hard_deleted_users": hard_deleted,
        },
    )
    return {
        "expired_sessions_removed": expired_sessions,
        "hard_deleted_users": hard_deleted,
    }


def _cleanup_expired_sessions(db) -> int:
    now = datetime.now(timezone.utc)
    stmt = delete(UserSession).where(
        and_(
            UserSession.expires_at < now,
            UserSession.revoked.is_(True),
        )
    )
    result = db.execute(stmt)
    return result.rowcount


def _cleanup_soft_deleted_users(db) -> int:
    cutoff = datetime.now(timezone.utc) - timedelta(days=SOFT_DELETE_RETENTION_DAYS)
    stmt = select(User).where(
        and_(
            User.is_active.is_(False),
            User.updated_at < cutoff,
        )
    )
    users = db.execute(stmt).scalars().all()

    count = 0
    for user in users:
        db.delete(user)
        count += 1

    return count
