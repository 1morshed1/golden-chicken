from datetime import datetime

from pydantic import BaseModel

from app.models.insights import InsightSeverity


class InsightResponse(BaseModel):
    id: str
    user_id: str
    shed_id: str | None
    insight_type: str
    title: str
    description: str
    severity: InsightSeverity
    proposed_action: str | None
    source: str
    is_acknowledged: bool
    is_resolved: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class InsightsSummary(BaseModel):
    critical_count: int
    warning_count: int
    info_count: int


class InsightsListResponse(BaseModel):
    insights: list[InsightResponse]
    summary: InsightsSummary


class InsightAction(BaseModel):
    text: str
    priority: str
    source: str
    insight_id: str
