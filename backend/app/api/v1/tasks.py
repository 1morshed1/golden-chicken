from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import MessageResponse, PaginationMeta, SuccessResponse
from app.schemas.task import TaskCreate, TaskResponse, TaskUpdate, TodaySummary
from app.services.task_service import task_service

router = APIRouter(prefix="/tasks", tags=["tasks"])


@router.post("", response_model=SuccessResponse[TaskResponse], status_code=201)
async def create_task(
    data: TaskCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    task = await task_service.create_task(db, user, data)
    return SuccessResponse(data=TaskResponse.model_validate(task))


@router.get("", response_model=SuccessResponse[list[TaskResponse]])
async def list_tasks(
    status: str | None = Query(default=None, pattern="^(pending|completed|overdue)$"),
    target_date: date | None = Query(default=None, alias="date"),
    shed_id: str | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    offset = (page - 1) * page_size
    tasks, total = await task_service.get_tasks(
        db, user,
        status=status, target_date=target_date,
        shed_id=shed_id, offset=offset, limit=page_size,
    )
    return SuccessResponse(
        data=[TaskResponse.model_validate(t) for t in tasks],
        meta=PaginationMeta(
            page=page, page_size=page_size,
            total=total, total_pages=(total + page_size - 1) // page_size,
        ).model_dump(),
    )


@router.get("/today", response_model=SuccessResponse[TodaySummary])
async def today_tasks(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await task_service.get_today_tasks(db, user)
    return SuccessResponse(
        data=TodaySummary(
            tasks=[TaskResponse.model_validate(t) for t in result["tasks"]],
            completed_count=result["completed_count"],
            pending_count=result["pending_count"],
        )
    )


@router.get("/overdue", response_model=SuccessResponse[list[TaskResponse]])
async def overdue_tasks(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    tasks, count = await task_service.get_overdue_tasks(db, user)
    return SuccessResponse(
        data=[TaskResponse.model_validate(t) for t in tasks],
        meta={"count": count},
    )


@router.get("/{task_id}", response_model=SuccessResponse[TaskResponse])
async def get_task(
    task_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    task = await task_service.get_task(db, task_id, user)
    return SuccessResponse(data=TaskResponse.model_validate(task))


@router.put("/{task_id}", response_model=SuccessResponse[TaskResponse])
async def update_task(
    task_id: str,
    data: TaskUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    task = await task_service.update_task(db, task_id, user, data)
    return SuccessResponse(data=TaskResponse.model_validate(task))


@router.post("/{task_id}/complete", response_model=SuccessResponse[TaskResponse])
async def complete_task(
    task_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    task = await task_service.complete_task(db, task_id, user)
    return SuccessResponse(data=TaskResponse.model_validate(task))


@router.delete("/{task_id}", status_code=204)
async def delete_task(
    task_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await task_service.delete_task(db, task_id, user)
