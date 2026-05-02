from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field, validator

class LogicalOperator(str, Enum):
    AND = "и"
    OR = "или"

class VariableType(str, Enum):
    INPUT = "входная"
    OUTPUT = "выходная"

class FuzzyTerm(BaseModel):
    name: str
    # Функция принадлежности может быть добавлена позже
    # type: str  # треугольная, трапециевидная, гауссова и т.д.
    # params: List[float]  # параметры функции

class LinguisticVariable(BaseModel):
    id: int
    name: str
    type: VariableType
    terms: List[FuzzyTerm] = Field(default=[], min_items=1)

    @validator('terms')
    def check_terms(cls, v):
        if not v or len(v) < 1:
            raise ValueError('Должна быть минимум одна терма')
        return v

class Condition(BaseModel):
    variable_id: int = 0
    term: str = ""
    operator: LogicalOperator = LogicalOperator.AND

class Rule(BaseModel):
    id: int
    weight: float = 1.0
    conditions: List[Condition] = Field(default=[Condition()])
    conclusions: List[Condition] = Field(default=[Condition()])
    
    @validator('weight')
    def check_weight(cls, v):
        if v < 0.0 or v > 1.0:
            raise ValueError('Вес должен быть от 0.0 до 1.0')
        return v

    @validator('conditions', 'conclusions')
    def check_size(cls, v):
        if not v or len(v) < 1:
            raise ValueError('Должно быть минимум одно условие')
        if len(v) > 3:
            raise ValueError('Максимум три условия')
        return v

class RuleSet(BaseModel):
    rules: List[Rule] = Field(default=[], max_items=10)
    linguistic_variables: List[LinguisticVariable] = Field(default=[])
    
    @validator('rules')
    def check_rules_size(cls, v):
        if len(v) > 10:
            raise ValueError('Максимум 10 правил')
        return v