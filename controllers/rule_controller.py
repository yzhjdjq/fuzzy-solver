import sys
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtQml import QmlElement
from typing import List, Dict, Any

# Добавляем корневой путь в sys.path для корректного импорта
sys.path.insert(0, str(Path(__file__).parent.parent))

from backend.rule_engine import RuleEngine
from backend.fuzzy_models import Rule, Condition, LogicalOperator, FuzzyVariable

QML_IMPORT_NAME = "RuleController"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class RuleController(QObject):
    rulesChanged = Signal(list)
    errorOccurred = Signal(str)
    
    def __init__(self):
        super().__init__()
        self.engine = RuleEngine()
        self._rules = []
        self._initialize_default_data()
    
    def _initialize_default_data(self):
        """Инициализация тестовыми данными"""
        test_rule = Rule(
            id=0,
            conditions=[Condition(variable=FuzzyVariable.TEMPERATURE_LOW, operator=LogicalOperator.AND)],
            conclusions=[Condition(variable=FuzzyVariable.PRESSURE_HIGH, operator=LogicalOperator.AND)]
        )
        self.engine.rule_set.rules.append(test_rule)
        self._update_rules_model()
    
    def _update_rules_model(self):
        """Обновить модель правил для QML"""
        rules_dict = []
        for rule in self.engine.rule_set.rules:
            rules_dict.append({
                "id": rule.id,
                "conditions": [{"variable": c.variable.value, "operator": c.operator.value} 
                             for c in rule.conditions],
                "conclusions": [{"variable": c.variable.value, "operator": c.operator.value} 
                              for c in rule.conclusions]
            })
        self._rules = rules_dict
        self.rulesChanged.emit(self._rules)
    
    @Slot(int, result=str)
    def pluralizeRules(self, count: int) -> str:
        """Склоняет слово `правило` в зависимости от числа"""
        if count % 10 == 1 and count % 100 != 11:
            return "правило"
        elif 2 <= count % 10 <= 4 and (count % 100 < 10 or count % 100 >= 20):
            return "правила"
        else:
            return "правил"

    @Slot()
    def addRule(self):
        """Добавить новое правило"""
        try:
            if len(self.engine.rule_set.rules) >= self.engine.max_rules:
                self.errorOccurred.emit("Достигнуто максимальное количество правил (10)")
                return
                
            new_rule = Rule(
                id=len(self.engine.rule_set.rules),
                conditions=[Condition(variable=FuzzyVariable.TEMPERATURE_LOW, operator=LogicalOperator.AND)],
                conclusions=[Condition(variable=FuzzyVariable.PRESSURE_HIGH, operator=LogicalOperator.AND)]
            )
            self.engine.rule_set.rules.append(new_rule)
            self._update_rules_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при создании правила: {str(e)}")
    
    @Slot(int)
    def removeRule(self, rule_id: int):
        """Удалить правило"""
        try:
            if len(self.engine.rule_set.rules) <= 1:
                self.errorOccurred.emit("Нельзя удалить последнее правило")
                return
                
            self.engine.remove_rule(rule_id)
            self._update_rules_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при удалении правила: {str(e)}")
    
    @Slot(int, str)
    def addCondition(self, rule_id: int, group_type: str):
        """Добавить условие в правило"""
        from backend.fuzzy_models import Condition, FuzzyVariable
        
        rule = next((r for r in self.engine.rule_set.rules if r.id == rule_id), None)
        if not rule:
            return
        
        target_list = rule.conditions if group_type == "condition" else rule.conclusions
        if len(target_list) < 3:
            target_list.append(Condition(variable=FuzzyVariable.TEMPERATURE_LOW, operator=LogicalOperator.AND))
            self._update_rules_model()
        else:
            self.errorOccurred.emit("Максимум 3 условия")
    
    @Slot(int, str, int)
    def removeCondition(self, rule_id: int, group_type: str, index: int):
        """Удалить условие из правила"""
        rule = next((r for r in self.engine.rule_set.rules if r.id == rule_id), None)
        if not rule:
            return
        
        target_list = rule.conditions if group_type == "condition" else rule.conclusions
        if len(target_list) > 1:
            target_list.pop(index)
            self._update_rules_model()
        else:
            self.errorOccurred.emit("Должно быть минимум одно условие")
    
    @Slot(int, str, int, str)
    def updateConditionVariable(self, rule_id: int, group_type: str, index: int, variable: str):
        """Обновить только переменную условия, сохраняя оператор"""
        try:
            from backend.fuzzy_models import FuzzyVariable
            
            rule = next((r for r in self.engine.rule_set.rules if r.id == rule_id), None)
            if not rule:
                return
            
            target_list = rule.conditions if group_type == "condition" else rule.conclusions
            if 0 <= index < len(target_list):
                target_list[index].variable = FuzzyVariable(variable)
                self._update_rules_model()
        except ValueError as e:
            print(f"Предупреждение при обновлении переменной: {e}")
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении переменной: {str(e)}")
    
    @Slot(int, str, int, str)
    def updateConditionOperator(self, rule_id: int, group_type: str, index: int, operator: str):
        """Обновить только оператор условия, сохраняя переменную"""
        try:
            from backend.fuzzy_models import LogicalOperator
            
            rule = next((r for r in self.engine.rule_set.rules if r.id == rule_id), None)
            if not rule:
                return
            
            target_list = rule.conditions if group_type == "condition" else rule.conclusions
            if 0 <= index < len(target_list):
                target_list[index].operator = LogicalOperator(operator)
                self._update_rules_model()
        except ValueError as e:
            print(f"Предупреждение при обновлении оператора: {e}")
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении оператора: {str(e)}")
    
    @Slot()
    def evaluate(self):
        """Выполнить расчет"""
        json_data = self.engine.to_json()
        print("Текущие правила:", json_data)
    
    @Property(list, notify=rulesChanged)
    def rules(self):
        return self._rules