from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.knowledge import KnowledgeChunk
from app.repositories.base import BaseRepository


class KnowledgeRepository(BaseRepository[KnowledgeChunk]):
    def __init__(self):
        super().__init__(KnowledgeChunk)

    async def vector_search(
        self,
        db: AsyncSession,
        embedding: list[float],
        categories: list[str] | None = None,
        top_k: int = 25,
        max_distance: float = 0.5,
    ) -> list[KnowledgeChunk]:
        stmt = (
            select(KnowledgeChunk)
            .where(
                KnowledgeChunk.embedding.cosine_distance(embedding) < max_distance
            )
            .order_by(KnowledgeChunk.embedding.cosine_distance(embedding))
            .limit(top_k)
        )
        if categories:
            stmt = stmt.where(KnowledgeChunk.category.in_(categories))
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def delete_by_source(self, db: AsyncSession, source_document: str) -> int:
        stmt = select(KnowledgeChunk).where(
            KnowledgeChunk.source_document == source_document
        )
        result = await db.execute(stmt)
        chunks = result.scalars().all()
        count = len(chunks)
        for chunk in chunks:
            await db.delete(chunk)
        await db.flush()
        return count

    async def get_sources(self, db: AsyncSession) -> list[str]:
        stmt = (
            select(KnowledgeChunk.source_document)
            .distinct()
            .order_by(KnowledgeChunk.source_document)
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    async def count_by_source(self, db: AsyncSession, source_document: str) -> int:
        from sqlalchemy import func

        stmt = (
            select(func.count())
            .select_from(KnowledgeChunk)
            .where(KnowledgeChunk.source_document == source_document)
        )
        result = await db.execute(stmt)
        return result.scalar_one()
