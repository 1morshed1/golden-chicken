from typing import Any, Generic, TypeVar

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.base import BaseModel

ModelType = TypeVar("ModelType", bound=BaseModel)


class BaseRepository(Generic[ModelType]):
    def __init__(self, model: type[ModelType]):
        self.model = model

    async def get_by_id(self, db: AsyncSession, id: str) -> ModelType | None:
        return await db.get(self.model, id)

    async def get_all(
        self,
        db: AsyncSession,
        *,
        offset: int = 0,
        limit: int = 20,
        filters: list[Any] | None = None,
    ) -> list[ModelType]:
        stmt = select(self.model)
        if filters:
            for f in filters:
                stmt = stmt.where(f)
        stmt = stmt.offset(offset).limit(limit)
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def count(self, db: AsyncSession, *, filters: list[Any] | None = None) -> int:
        stmt = select(func.count()).select_from(self.model)
        if filters:
            for f in filters:
                stmt = stmt.where(f)
        result = await db.execute(stmt)
        return result.scalar_one()

    async def create(self, db: AsyncSession, **kwargs) -> ModelType:
        instance = self.model(**kwargs)
        db.add(instance)
        await db.flush()
        await db.refresh(instance)
        return instance

    async def update(self, db: AsyncSession, instance: ModelType, **kwargs) -> ModelType:
        for key, value in kwargs.items():
            if value is not None:
                setattr(instance, key, value)
        await db.flush()
        await db.refresh(instance)
        return instance

    async def delete(self, db: AsyncSession, instance: ModelType) -> None:
        await db.delete(instance)
        await db.flush()

    async def soft_delete(self, db: AsyncSession, instance: ModelType) -> ModelType:
        instance.is_active = False
        await db.flush()
        await db.refresh(instance)
        return instance
