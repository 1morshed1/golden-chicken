from celery import Celery
from celery.schedules import crontab

from app.config import settings

celery_app = Celery(
    "goldenchicken",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="Asia/Dhaka",
    enable_utc=True,
    task_track_started=True,
    task_acks_late=True,
    worker_prefetch_multiplier=1,
    beat_schedule={
        "scrape-market-prices-morning": {
            "task": "app.workers.tasks.market_scraper.scrape_market_prices",
            "schedule": crontab(hour="8", minute="0"),
        },
        "scrape-market-prices-evening": {
            "task": "app.workers.tasks.market_scraper.scrape_market_prices",
            "schedule": crontab(hour="18", minute="0"),
        },
        "refresh-weather-cache": {
            "task": "app.workers.tasks.weather_refresh.refresh_weather_cache",
            "schedule": crontab(minute="0", hour="*/2"),
        },
        "generate-daily-insights": {
            "task": "app.workers.tasks.insights_generator.generate_all_user_insights",
            "schedule": crontab(hour="6", minute="30"),
        },
    },
)

celery_app.autodiscover_tasks(["app.workers.tasks"])
