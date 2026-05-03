from typing import Any
import json
import math
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
    
    def get_input_variables(self) -> list[LinguisticVariable]:
        """Получить входные переменные"""
        return [v for v in self.rule_set.linguistic_variables if v.type == VariableType.INPUT]
    
    def get_output_variables(self) -> list[LinguisticVariable]:
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

    def _triangular_mf(self, x: float, params: list[float]) -> float:
        """Треугольная функция принадлежности"""
        if len(params) < 3:
            return 0.0
        a, b, c = params[0], params[1], params[2]
        
        if x <= a or x >= c:
            return 0.0
        elif a < x <= b:
            return (x - a) / (b - a)
        elif b < x < c:
            return (c - x) / (c - b)
        else:
            return 0.0
    
    def _trapezoidal_mf(self, x: float, params: list[float]) -> float:
        """Трапециевидная функция принадлежности"""
        if len(params) < 4:
            return 0.0
        a, b, c, d = params[0], params[1], params[2], params[3]
        
        if x <= a or x >= d:
            return 0.0
        elif a < x < b:
            return (x - a) / (b - a)
        elif b <= x <= c:
            return 1.0
        elif c < x < d:
            return (d - x) / (d - c)
        else:
            return 0.0
    
    def _gaussian_mf(self, x: float, params: list[float]) -> float:
        """Гауссова функция принадлежности"""
        if len(params) < 2:
            return 0.0
        mean, sigma = params[0], params[1]
        
        if sigma == 0:
            return 1.0 if x == mean else 0.0
        
        return math.exp(-0.5 * ((x - mean) / sigma) ** 2)
    
    def _calculate_membership(self, x: float, term: FuzzyTerm) -> float:
        """Вычислить степень принадлежности значения x к терму"""
        mf_type = term.mf_type
        params = term.mf_params
        
        if mf_type == "triangle":
            return self._triangular_mf(x, params)
        elif mf_type == "trapezoid":
            return self._trapezoidal_mf(x, params)
        elif mf_type == "gaussian":
            return self._gaussian_mf(x, params)
        else:
            return 0.0
    
    def fuzzify(self, var_id: int, value: float) -> dict[str, float]:
        """
        Фаззификация входного значения для переменной.
        Возвращает словарь {имя_терма: степень_принадлежности}
        """
        var = self.get_variable_by_id(var_id)
        if not var:
            return {}
        
        result = {}
        for term in var.terms:
            membership = self._calculate_membership(value, term)
            result[term.name] = round(membership, 4)
        
        return result
    
    def fuzzify_all(self, inputs: dict[int, float]) -> dict[int, dict[str, float]]:
        """
        Фаззификация всех входных значений.
        inputs: {var_id: value}
        Возвращает: {var_id: {term_name: membership}}
        """
        result = {}
        for var_id, value in inputs.items():
            result[var_id] = self.fuzzify(var_id, value)
        return result
    
    def evaluate(self, inputs: dict[str, float]) -> dict[str, float]:
        """Выполнить нечеткий вывод с фазификацией"""
        # Конвертируем строковые ключи в int (из QML приходят строки)
        numeric_inputs = {int(k): v for k, v in inputs.items()}
        
        # Шаг 1: Фаззификация
        fuzzified = self.fuzzify_all(numeric_inputs)
        
        print("=== Фаззификация ===")
        for var_id, memberships in fuzzified.items():
            var = self.get_variable_by_id(var_id)
            var_name = var.name if var else f"Переменная {var_id}"
            print(f"{var_name}:")
            for term, mu in memberships.items():
                print(f"  {term}: {mu}")
        
        # Следующие шаги: агрегация, активация, аккумуляция, дефаззификация
        return {}