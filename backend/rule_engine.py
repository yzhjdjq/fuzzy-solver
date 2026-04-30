from typing import Dict, Any, List
import json
from .fuzzy_models import RuleSet, Rule, LogicalOperator, Condition, FuzzyVariable

class RuleEngine:
    def __init__(self):
        self.rule_set = RuleSet(rules=[])
        self.max_rules = 10
        self.max_conditions = 3
    
    def add_rule(self) -> Rule:
        """Добавить новое правило"""
        if len(self.rule_set.rules) >= self.max_rules:
            raise ValueError("Достигнуто максимальное количество правил")
        
        new_rule = Rule(
            id=len(self.rule_set.rules),
            conditions=[Condition(variable=FuzzyVariable.TEMPERATURE_LOW)],
            conclusions=[Condition(variable=FuzzyVariable.PRESSURE_HIGH)]
        )
        self.rule_set.rules.append(new_rule)
        return new_rule
    
    def remove_rule(self, rule_id: int):
        """Удалить правило по ID"""
        initial_length = len(self.rule_set.rules)
        self.rule_set.rules = [r for r in self.rule_set.rules if r.id != rule_id]
        
        # Переиндексация оставшихся правил
        for i, rule in enumerate(self.rule_set.rules):
            rule.id = i
    
    def update_rule(self, rule_id: int, updated_rule: Dict[str, Any]):
        """Обновить правило"""
        for i, rule in enumerate(self.rule_set.rules):
            if rule.id == rule_id:
                self.rule_set.rules[i] = Rule(**updated_rule)
                break
    
    def to_json(self) -> str:
        """Сериализовать в JSON"""
        return self.rule_set.model_dump_json(indent=2)
    
    def evaluate(self, inputs: Dict[str, float]) -> Dict[str, float]:
        """Выполнить нечеткий вывод (заглушка)"""
        return {}