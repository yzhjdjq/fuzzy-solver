from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field, validator

class LogicalOperator(str, Enum):
    AND = "и"
    OR = "или"

class FuzzyVariable(str, Enum):
    TEMPERATURE_LOW = "Температура низкая"
    TEMPERATURE_MEDIUM = "Температура средняя"
    TEMPERATURE_HIGH = "Температура высокая"
    PRESSURE_LOW = "Давление низкое"
    PRESSURE_MEDIUM = "Давление среднее"
    PRESSURE_HIGH = "Давление высокое"
    HUMIDITY_LOW = "Влажность низкая"
    HUMIDITY_MEDIUM = "Влажность средняя"
    HUMIDITY_HIGH = "Влажность высокая"

class Condition(BaseModel):
    variable: FuzzyVariable = FuzzyVariable.TEMPERATURE_LOW
    operator: LogicalOperator = LogicalOperator.AND

class Rule(BaseModel):
    id: int
    conditions: List[Condition] = Field(default=[Condition()])
    conclusions: List[Condition] = Field(default=[Condition()])
    
    @validator('conditions', 'conclusions')
    def check_size(cls, v):
        if not v or len(v) < 1:
            raise ValueError('Должно быть минимум одно условие')
        if len(v) > 3:
            raise ValueError('Максимум три условия')
        return v

class RuleSet(BaseModel):
    rules: List[Rule] = Field(default=[], max_items=10)
    
    @validator('rules')
    def check_rules_size(cls, v):
        if len(v) > 10:
            raise ValueError('Максимум 10 правил')
        return v