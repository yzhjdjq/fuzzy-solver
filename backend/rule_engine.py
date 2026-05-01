from typing import Dict, Any, List
import json
from .fuzzy_models import RuleSet, Rule, Condition, LinguisticVariable, VariableType, FuzzyTerm

class RuleEngine:
    def __init__(self):
        self.rule_set = RuleSet(rules=[], linguistic_variables=[])
        self.max_rules = 10
        self.max_conditions = 3
        self._initialize_default_variables()
    
    def _initialize_default_variables(self):
        """Инициализация тестовыми лингвистическими переменными"""
        # Входные переменные
        temp_terms = [
            FuzzyTerm(name="низкая"),
            FuzzyTerm(name="средняя"),
            FuzzyTerm(name="высокая")
        ]
        temp_var = LinguisticVariable(id=0, name="Температура", type=VariableType.INPUT, terms=temp_terms)
        
        humidity_terms = [
            FuzzyTerm(name="низкая"),
            FuzzyTerm(name="средняя"),
            FuzzyTerm(name="высокая")
        ]
        humidity_var = LinguisticVariable(id=1, name="Влажность", type=VariableType.INPUT, terms=humidity_terms)
        
        pressure_terms = [
            FuzzyTerm(name="низкое"),
            FuzzyTerm(name="среднее"),
            FuzzyTerm(name="высокое")
        ]
        pressure_var = LinguisticVariable(id=2, name="Давление", type=VariableType.INPUT, terms=pressure_terms)
        
        # Выходные переменные
        power_terms = [
            FuzzyTerm(name="малая"),
            FuzzyTerm(name="средняя"),
            FuzzyTerm(name="большая")
        ]
        power_var = LinguisticVariable(id=3, name="Мощность", type=VariableType.OUTPUT, terms=power_terms)
        
        speed_terms = [
            FuzzyTerm(name="низкая"),
            FuzzyTerm(name="средняя"),
            FuzzyTerm(name="высокая")
        ]
        speed_var = LinguisticVariable(id=4, name="Скорость", type=VariableType.OUTPUT, terms=speed_terms)
        
        self.rule_set.linguistic_variables = [temp_var, humidity_var, pressure_var, power_var, speed_var]
    
    def get_input_variables(self) -> List[LinguisticVariable]:
        """Получить входные переменные"""
        return [v for v in self.rule_set.linguistic_variables if v.type == VariableType.INPUT]
    
    def get_output_variables(self) -> List[LinguisticVariable]:
        """Получить выходные переменные"""
        return [v for v in self.rule_set.linguistic_variables if v.type == VariableType.OUTPUT]
    
    def get_variable_by_id(self, var_id: int) -> LinguisticVariable:
        """Получить переменную по ID"""
        for var in self.rule_set.linguistic_variables:
            if var.id == var_id:
                return var
        return None
    
    def add_linguistic_variable(self, name: str, type: VariableType) -> LinguisticVariable:
        """Добавить лингвистическую переменную"""
        var_id = len(self.rule_set.linguistic_variables)
        var = LinguisticVariable(id=var_id, name=name, type=type, terms=[FuzzyTerm(name="новый терм")])
        self.rule_set.linguistic_variables.append(var)
        return var
    
    def remove_linguistic_variable(self, var_id: int):
        """Удалить лингвистическую переменную"""
        self.rule_set.linguistic_variables = [v for v in self.rule_set.linguistic_variables if v.id != var_id]
        # Переиндексация
        for i, var in enumerate(self.rule_set.linguistic_variables):
            var.id = i
    
    def add_rule(self) -> Rule:
        """Добавить новое правило"""
        if len(self.rule_set.rules) >= self.max_rules:
            raise ValueError("Достигнуто максимальное количество правил")
        
        # Используем первые доступные переменные
        input_vars = self.get_input_variables()
        output_vars = self.get_output_variables()
        
        default_condition = Condition()
        default_conclusion = Condition()
        
        if input_vars:
            default_condition.variable_id = input_vars[0].id
            default_condition.term = input_vars[0].terms[0].name if input_vars[0].terms else ""
        
        if output_vars:
            default_conclusion.variable_id = output_vars[0].id
            default_conclusion.term = output_vars[0].terms[0].name if output_vars[0].terms else ""
        
        new_rule = Rule(
            id=len(self.rule_set.rules),
            conditions=[default_condition],
            conclusions=[default_conclusion]
        )
        self.rule_set.rules.append(new_rule)
        return new_rule
    
    def remove_rule(self, rule_id: int):
        """Удалить правило по ID"""
        self.rule_set.rules = [r for r in self.rule_set.rules if r.id != rule_id]
        for i, rule in enumerate(self.rule_set.rules):
            rule.id = i
    
    def to_json(self) -> str:
        """Сериализовать в JSON"""
        return self.rule_set.model_dump_json(indent=2)
    
    def evaluate(self, inputs: Dict[str, float]) -> Dict[str, float]:
        """Выполнить нечеткий вывод (заглушка)"""
        return {}