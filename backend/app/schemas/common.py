from typing import Any, Generic, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class ErrorDetail(BaseModel):
    code: str
    message: str
    details: list[Any] = []


class ErrorResponse(BaseModel):
    status: str = "error"
    error: ErrorDetail


class SuccessResponse(BaseModel, Generic[T]):
    status: str = "success"
    data: T
    meta: dict[str, Any] | None = None


class MessageResponse(BaseModel):
    status: str = "success"
    data: dict[str, str]


class PaginationMeta(BaseModel):
    page: int
    page_size: int
    total: int
    total_pages: int
