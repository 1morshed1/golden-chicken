from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.rag.embedder import Embedder
from app.ai.rag.reranker import Reranker
from app.config import settings
from app.repositories.knowledge_repository import KnowledgeRepository


knowledge_repo = KnowledgeRepository()


class Retriever:
    def __init__(
        self,
        embedder: Embedder | None = None,
        reranker: Reranker | None = None,
    ):
        self.embedder = embedder or Embedder.get_instance()
        self.reranker = reranker or Reranker.get_instance()

    async def retrieve(
        self,
        db: AsyncSession,
        query: str,
        category: str = "general",
        top_k: int | None = None,
    ) -> list:
        top_k = top_k or settings.RAG_RERANK_TOP_K

        query_embedding = await self.embedder.embed(query)

        categories = [category, "general"] if category != "general" else ["general"]
        candidates = await knowledge_repo.vector_search(
            db,
            embedding=query_embedding,
            categories=categories,
            top_k=settings.RAG_TOP_K,
            max_distance=0.5,
        )

        if not candidates:
            return []

        reranked = await self.reranker.rerank(query, candidates, top_k=top_k)
        return reranked

    def build_context(self, chunks: list) -> str | None:
        if not chunks:
            return None
        parts = []
        for i, chunk in enumerate(chunks, 1):
            source = chunk.source_document or "unknown"
            parts.append(f"[Source {i}: {source}]\n{chunk.content}")
        return "\n\n".join(parts)

    async def retrieve_and_build(
        self,
        db: AsyncSession,
        query: str,
        category: str = "general",
    ) -> str | None:
        chunks = await self.retrieve(db, query, category)
        return self.build_context(chunks)
