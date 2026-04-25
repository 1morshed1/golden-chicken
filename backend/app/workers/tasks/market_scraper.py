import logging
from datetime import datetime, timezone

from sqlalchemy import update

from app.models.market import MarketPrice, PriceTrend, PriceSource, ProductType
from app.workers.celery_app import celery_app
from app.workers.db import task_db_session

logger = logging.getLogger(__name__)


def scrape_dam_poultry() -> list[dict]:
    """Scrape poultry prices from DAM (dam.gov.bd).

    Returns list of price dicts ready for DB insertion.
    NOTE: Actual scraping logic depends on DAM's HTML structure which
    changes periodically. This is a structured placeholder that will be
    filled with real selectors once the site is analyzed.
    """
    import httpx
    from bs4 import BeautifulSoup

    try:
        resp = httpx.get(
            "http://dam.gov.bd/",
            timeout=30,
            headers={"User-Agent": "GoldenChicken/1.0 (poultry price monitor)"},
        )
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        prices = []
        # DAM price table parsing
        # Structure varies — this extracts from the main commodity table
        tables = soup.find_all("table", class_="table")
        for table in tables:
            rows = table.find_all("tr")
            for row in rows[1:]:  # skip header
                cols = row.find_all("td")
                if len(cols) < 4:
                    continue
                product_name = cols[0].get_text(strip=True).lower()

                if not any(kw in product_name for kw in ["egg", "ডিম", "broiler", "ব্রয়লার", "chicken", "মুরগি", "feed", "খাদ্য"]):
                    continue

                try:
                    price_bdt = float(cols[2].get_text(strip=True).replace(",", ""))
                except (ValueError, IndexError):
                    continue

                product_type = _classify_product(product_name)
                if not product_type:
                    continue

                prices.append({
                    "product_type": product_type,
                    "product_name": product_name,
                    "unit": cols[1].get_text(strip=True) if len(cols) > 1 else "per unit",
                    "market_name": "DAM National Average",
                    "location": "Bangladesh",
                    "price_bdt": price_bdt,
                    "source": PriceSource.SCRAPED_DAM,
                    "fetched_at": datetime.now(timezone.utc),
                    "is_stale": False,
                })

        return prices

    except Exception as e:
        logger.error(f"DAM scraper failed: {e}")
        raise


def scrape_tcb_poultry() -> list[dict]:
    """Scrape poultry prices from TCB (tcb.portal.gov.bd).

    Similar structured placeholder as DAM scraper.
    """
    import httpx
    from bs4 import BeautifulSoup

    try:
        resp = httpx.get(
            "https://www.tcb.gov.bd/",
            timeout=30,
            headers={"User-Agent": "GoldenChicken/1.0 (poultry price monitor)"},
        )
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        prices = []
        tables = soup.find_all("table")
        for table in tables:
            rows = table.find_all("tr")
            for row in rows[1:]:
                cols = row.find_all("td")
                if len(cols) < 3:
                    continue
                product_name = cols[0].get_text(strip=True).lower()

                if not any(kw in product_name for kw in ["egg", "ডিম", "broiler", "ব্রয়লার", "chicken", "মুরগি"]):
                    continue

                try:
                    price_bdt = float(cols[-1].get_text(strip=True).replace(",", ""))
                except (ValueError, IndexError):
                    continue

                product_type = _classify_product(product_name)
                if not product_type:
                    continue

                prices.append({
                    "product_type": product_type,
                    "product_name": product_name,
                    "unit": cols[1].get_text(strip=True) if len(cols) > 1 else "per unit",
                    "market_name": "TCB Reference",
                    "location": "Bangladesh",
                    "price_bdt": price_bdt,
                    "source": PriceSource.SCRAPED_TCB,
                    "fetched_at": datetime.now(timezone.utc),
                    "is_stale": False,
                })

        return prices

    except Exception as e:
        logger.error(f"TCB scraper failed: {e}")
        raise


def _classify_product(name: str) -> ProductType | None:
    name = name.lower()
    if any(kw in name for kw in ["egg", "ডিম"]):
        return ProductType.EGG
    if any(kw in name for kw in ["broiler", "ব্রয়লার"]):
        return ProductType.BROILER_MEAT
    if any(kw in name for kw in ["layer", "লেয়ার"]):
        return ProductType.LAYER_MEAT
    if any(kw in name for kw in ["feed", "খাদ্য"]):
        return ProductType.FEED
    if any(kw in name for kw in ["chick", "বাচ্চা"]):
        return ProductType.CHICK
    if any(kw in name for kw in ["chicken", "মুরগি"]):
        return ProductType.BROILER_MEAT
    return None


def _calculate_trends(prices: list[dict], db_session) -> list[dict]:
    from sqlalchemy import select, and_

    for price_data in prices:
        stmt = (
            select(MarketPrice)
            .where(
                and_(
                    MarketPrice.product_type == price_data["product_type"],
                    MarketPrice.market_name == price_data["market_name"],
                )
            )
            .order_by(MarketPrice.fetched_at.desc())
            .limit(1)
        )
        result = db_session.execute(stmt)
        previous = result.scalar_one_or_none()

        if previous:
            change = ((price_data["price_bdt"] - previous.price_bdt) / previous.price_bdt) * 100
            price_data["change_percent"] = round(change, 1)
            if change > 1:
                price_data["trend"] = PriceTrend.UP
            elif change < -1:
                price_data["trend"] = PriceTrend.DOWN
            else:
                price_data["trend"] = PriceTrend.STABLE
        else:
            price_data["change_percent"] = 0.0
            price_data["trend"] = PriceTrend.STABLE

    return prices


@celery_app.task(bind=True, max_retries=3, default_retry_delay=300)
def scrape_market_prices(self):
    prices = []
    failures = []

    for name, scraper in [("dam", scrape_dam_poultry), ("tcb", scrape_tcb_poultry)]:
        try:
            result = scraper()
            prices.extend(result)
            logger.info(f"{name} scraper returned {len(result)} prices")
        except Exception as exc:
            failures.append(name)
            logger.error(f"{name} scraper failed: {exc}")

    if not prices:
        with task_db_session() as db:
            db.execute(
                update(MarketPrice)
                .where(MarketPrice.is_stale == False)
                .values(is_stale=True)
            )
        logger.error(f"All market scrapers failed: {failures}")
        raise self.retry(exc=Exception("all market scrapers failed"))

    with task_db_session() as db:
        prices = _calculate_trends(prices, db)
        for price_data in prices:
            market_price = MarketPrice(**price_data)
            db.add(market_price)

    logger.info(f"Market scraping complete: {len(prices)} prices from {len(failures)} failures")
