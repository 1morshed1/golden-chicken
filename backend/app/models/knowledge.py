from pgvector.sqlalchemy import Vector
from sqlalchemy import Index, String, Text
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class KnowledgeChunk(BaseModel):
    __tablename__ = "knowledge_chunks"

    content: Mapped[str] = mapped_column(Text, nullable=False)
    source_document: Mapped[str] = mapped_column(String(255))
    category: Mapped[str] = mapped_column(String(100), index=True)
    embedding: Mapped[list] = mapped_column(Vector(1024))
    chunk_metadata: Mapped[dict | None] = mapped_column("metadata", JSON)

    __table_args__ = (
        Index(
            "ix_knowledge_embedding_hnsw",
            embedding,
            postgresql_using="hnsw",
            postgresql_with={"m": 16, "ef_construction": 64},
            postgresql_ops={"embedding": "vector_cosine_ops"},
        ),
    )
