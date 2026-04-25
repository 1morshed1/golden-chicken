from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.exceptions import ValidationError
from app.models.market import ProductType
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.market import (
    MarketPriceListResponse,
    MarketPriceResponse,
    PriceHistoryResponse,
)
from app.services.market_service import market_service

router = APIRouter(prefix="/market", tags=["market"])

VALID_PRODUCT_TYPES = {e.value for e in ProductType}


@router.get("/prices", response_model=SuccessResponse[MarketPriceListResponse])
async def get_market_prices(
    product_type: str | None = Query(default=None),
    region: str | None = Query(default=None),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if product_type and product_type not in VALID_PRODUCT_TYPES:
        raise ValidationError(
            f"Invalid product_type. Must be one of: {', '.join(sorted(VALID_PRODUCT_TYPES))}"
        )

    result = await market_service.get_latest_prices(
        db, product_type=product_type, region=region
    )
    return SuccessResponse(
        data=MarketPriceListResponse(
            prices=[MarketPriceResponse.model_validate(p) for p in result["prices"]],
            last_updated=result["last_updated"],
            data_warning=result["data_warning"],
        )
    )


@router.get(
    "/prices/{product_type}/history",
    response_model=SuccessResponse[PriceHistoryResponse],
)
async def get_price_history(
    product_type: str,
    days: int = Query(default=30, ge=1, le=365),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if product_type not in VALID_PRODUCT_TYPES:
        raise ValidationError(
            f"Invalid product_type. Must be one of: {', '.join(sorted(VALID_PRODUCT_TYPES))}"
        )

    result = await market_service.get_price_history(db, product_type, days=days)
    return SuccessResponse(data=PriceHistoryResponse(**result))
