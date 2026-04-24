from pydantic import BaseModel, Field


class HealthTabResponse(BaseModel):
    id: str
    disease_name_en: str
    disease_name_bn: str
    severity: str
    symptom_count: int
    symptoms: dict
    prefilled_prompt_en: str
    prefilled_prompt_bn: str
    category: str
    icon: str
    sort_order: int

    model_config = {"from_attributes": True}


class AskHealthTabRequest(BaseModel):
    health_tab_id: str
    language: str = Field("en", pattern=r"^(en|bn)$")
    additional_context: str | None = None
