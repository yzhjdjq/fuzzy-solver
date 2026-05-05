import sys
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtQml import QmlElement
from typing import List, Dict, Any

sys.path.insert(0, str(Path(__file__).parent.parent))

from backend.rule_engine import RuleEngine
from backend.fuzzy_models import Rule, Condition, LogicalOperator, VariableType, FuzzyTerm, LinguisticVariable

try:
    import pymorphy3
    morph = pymorphy3.MorphAnalyzer()
except ImportError:
    morph = None
    print("Предупреждение: pymorphy3 не установлен. Склонение слов не будет работать.")

QML_IMPORT_NAME = "RuleController"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class RuleController(QObject):
    rulesChanged = Signal(list)
    variablesChanged = Signal(list)
    errorOccurred = Signal(str)
    resultsAccumulated = Signal(list)
    crispResultsReady = Signal(list)
    
    def __init__(self):
        super().__init__()
        self.engine = RuleEngine()
        self._rules = []
        self._variables = []
        self._input_values = {}
        self._activation_method = "min"
        self._defuzz_method = "bos"
        self._update_rules_model()
        self._update_variables_model()
    
    def _update_rules_model(self):
        """Обновить модель правил для QML"""
        rules_dict = []
        for rule in self.engine.rule_set.rules:
            rules_dict.append({
                "id": rule.id,
                "weight": rule.weight,
                "conditions": [{"variable_id": c.variable_id, "term": c.term, "operator": c.operator.value} 
                            for c in rule.conditions],
                "conclusions": [{"variable_id": c.variable_id, "term": c.term, "operator": c.operator.value} 
                            for c in rule.conclusions]
            })
        self._rules = rules_dict
        self.rulesChanged.emit(self._rules)
    
    def _update_variables_model(self):
        """Обновить модель переменных для QML"""
        variables_dict = []
        for var in self.engine.rule_set.linguistic_variables:
            variables_dict.append({
                "id": var.id,
                "name": var.name,
                "type": var.type.value,
                "terms": [{"name": t.name, "mf_type": t.mf_type, "mf_params": t.mf_params} for t in var.terms]
            })
        self._variables = variables_dict
        self.variablesChanged.emit(self._variables)
    
    @Slot(int, result=str)
    def pluralizeRules(self, count: int) -> str:
        """Склоняет слово 'правило' в зависимости от числа"""
        if morph is None:
            if count % 10 == 1 and count % 100 != 11:
                return "правило"
            elif 2 <= count % 10 <= 4 and (count % 100 < 10 or count % 100 >= 20):
                return "правила"
            else:
                return "правил"
        
        word = morph.parse('правило')[0]
        if count % 10 == 1 and count % 100 != 11:
            return word.inflect({'sing', 'nomn'}).word
        else:
            return word.inflect({'plur', 'gent'}).word
    
    @Slot(result=list)
    def getInputVariables(self):
        """Получить входные переменные для QML"""
        result = []
        for var in self.engine.get_input_variables():
            result.append({
                "id": var.id,
                "name": var.name,
                "terms": [{"name": t.name, "mf_type": t.mf_type, "mf_params": t.mf_params} for t in var.terms]
            })
        return result

    @Slot(result=list)
    def getOutputVariables(self):
        """Получить выходные переменные для QML"""
        result = []
        for var in self.engine.get_output_variables():
            result.append({
                "id": var.id,
                "name": var.name,
                "terms": [{"name": t.name, "mf_type": t.mf_type, "mf_params": t.mf_params} for t in var.terms]
            })
        return result
    
    # Методы для работы с правилами
    @Slot()
    def addRule(self):
        """Добавить новое правило"""
        try:
            if len(self.engine.rule_set.rules) >= self.engine.max_rules:
                self.errorOccurred.emit("Достигнуто максимальное количество правил (10)")
                return
                
            self.engine.add_rule()
            self._update_rules_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при создании правила: {str(e)}")
    
    @Slot(int)
    def removeRule(self, rule_id: int):
        """Удалить правило"""
        try:
            self.engine.remove_rule(rule_id)
            self._update_rules_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при удалении правила: {str(e)}")

    @Slot(int, str)
    def addCondition(self, rule_id: int, group_type: str):
        """Добавить условие в правило"""
        rule = next((r for r in self.engine.rule_set.rules if r.id == rule_id), None)
        if not rule:
            return
        
        target_list = rule.conditions if group_type == "condition" else rule.conclusions
        if len(target_list) < 3:
            # Берем первую доступную переменную
            variables = self.engine.get_input_variables() if group_type == "condition" else self.engine.get_output_variables()
            new_condition = Condition()
            if variables:
                new_condition.variable_id = variables[0].id
                new_condition.term = variables[0].terms[0].name if variables[0].terms else ""
            
            target_list.append(new_condition)
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
    
    @Slot(int, str, int, int, str)
    def updateConditionVariable(self, rule_id: int, group_type: str, index: int, variable_id: int, term: str):
        """Обновить переменную и терм условия"""
        try:
            rule = next((r for r in self.engine.rule_set.rules if r.id == rule_id), None)
            if not rule:
                return
            
            target_list = rule.conditions if group_type == "condition" else rule.conclusions
            if 0 <= index < len(target_list):
                target_list[index].variable_id = variable_id
                target_list[index].term = term
                self._update_rules_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении переменной: {str(e)}")
    
    @Slot(int, str, int, str)
    def updateConditionOperator(self, rule_id: int, group_type: str, index: int, operator: str):
        """Обновить оператор условия"""
        try:
            rule = next((r for r in self.engine.rule_set.rules if r.id == rule_id), None)
            if not rule:
                return
            
            target_list = rule.conditions if group_type == "condition" else rule.conclusions
            if 0 <= index < len(target_list):
                target_list[index].operator = LogicalOperator(operator)
                self._update_rules_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении оператора: {str(e)}")
    
    # Методы для работы с лингвистическими переменными
    @Slot(str, str)
    def addLinguisticVariable(self, name: str, var_type: str):
        """Добавить лингвистическую переменную"""
        try:
            self.engine.add_linguistic_variable(name, VariableType(var_type))
            self._update_variables_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при добавлении переменной: {str(e)}")
    
    @Slot(int)
    def removeLinguisticVariable(self, var_id: int):
        """Удалить лингвистическую переменную"""
        try:
            self.engine.remove_linguistic_variable(var_id)
            self._update_variables_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при удалении переменной: {str(e)}")
    
    @Slot(int, str, str)
    def updateLinguisticVariable(self, var_id: int, name: str, var_type: str):
        """Обновить лингвистическую переменную"""
        try:
            var = self.engine.get_variable_by_id(var_id)
            if var:
                var.name = name
                var.type = VariableType(var_type)
                self._update_variables_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении переменной: {str(e)}")
    
    @Property(list, notify=rulesChanged)
    def rules(self):
        return self._rules
    
    @Property(list, notify=variablesChanged)
    def variables(self):
        return self._variables

    def _convert_for_qml(self, data: dict) -> list:
        """Конвертирует результаты аккумуляции в формат, понятный QML"""
        result = []
        for var_id, var_data in data.items():
            acc = var_data["accumulated"]
            
            # Конвертируем activated_terms
            activated_terms = []
            for term in acc["activated_terms"]:
                # Конвертируем points в список словарей
                points = []
                for p in term["points"]:
                    points.append({"x": p["x"], "y": p["y"]})
                
                activated_terms.append({
                    "term_name": term["term"].name,
                    "degree": term["degree"],
                    "method": term["method"],
                    "points": points,
                    "mf_type": term["mf_type"],
                    "mf_params": term["mf_params"]
                })
            
            # Конвертируем max_points
            max_points = []
            for p in acc["max_points"]:
                max_points.append({"x": p["x"], "y": p["y"]})
            
            result.append({
                "variable_id": var_id,
                "variable_name": var_data["variable_name"],
                "accumulated": {
                    "activated_terms": activated_terms,
                    "max_points": max_points
                }
            })
        
        return result

    @Slot()
    def evaluate(self):
        """Выполнить расчет с проверками"""
        # Проверки
        if len(self.engine.get_input_variables()) == 0:
            self.errorOccurred.emit("Добавьте хотя бы одну входную лингвистическую переменную")
            return
        
        if len(self.engine.get_output_variables()) == 0:
            self.errorOccurred.emit("Добавьте хотя бы одну выходную лингвистическую переменную")
            return
        
        if len(self.engine.rule_set.rules) == 0:
            self.errorOccurred.emit("Добавьте хотя бы одно правило")
            return
        
        # Проверка, что все правила используют существующие переменные
        for rule in self.engine.rule_set.rules:
            for condition in rule.conditions:
                var = self.engine.get_variable_by_id(condition.variable_id)
                if not var or var.type != VariableType.INPUT:
                    self.errorOccurred.emit(f"Правило {rule.id + 1}: условие использует несуществующую или не входную переменную")
                    return
            
            for conclusion in rule.conclusions:
                var = self.engine.get_variable_by_id(conclusion.variable_id)
                if not var or var.type != VariableType.OUTPUT:
                    self.errorOccurred.emit(f"Правило {rule.id + 1}: заключение использует несуществующую или не выходную переменную")
                    return

        # Проверка входных значений
        if len(self._input_values) == 0:
            self.errorOccurred.emit("Добавьте хотя бы одно входное значение")
            return
        
        json_data = self.engine.to_json()
        # Выполняем расчёт
        # print("Текущие правила и переменные:", json_data)
        print("=" * 50)
        print("ЗАПУСК НЕЧЁТКОГО ВЫВОДА")
        print("=" * 50)
        print(f"Входные значения: {self._input_values}")
        print(f"Метод активации: {self._activation_method}")
        print(f"Метод дефаззификации: {self._defuzz_method}")
        
        result = self.engine.evaluate(
            self._input_values,
            self._activation_method,
            self._defuzz_method
        )

        qml_data = self._convert_for_qml(result)
        self.resultsAccumulated.emit(qml_data)

        crisp_results = []
        for var_id, data in result.items():
            crisp_results.append({
                "variable_id": var_id,
                "variable_name": data["variable_name"],
                "crisp_value": data["crisp_value"],
                "best_term": data.get("best_term", "")
            })
        self.crispResultsReady.emit(crisp_results)

        print("=" * 50)
        # print("Результат:", result)

    @Slot(int, result=str)
    def pluralizeInput(self, count: int) -> str:
        """Склоняет 'входная переменная' в зависимости от числа"""
        if morph is None:
            if count % 10 == 1 and count % 100 != 11:
                return "входная"
            else:
                return "входных"
        
        word = morph.parse('входной')[0]
        if count % 10 == 1 and count % 100 != 11:
            return word.inflect({'sing', 'nomn', 'femn'}).word  # входная
        else:
            return word.inflect({'plur', 'gent'}).word  # входных

    @Slot(int, result=str)
    def pluralizeOutput(self, count: int) -> str:
        """Склоняет 'выходная переменная' в зависимости от числа"""
        if morph is None:
            if count % 10 == 1 and count % 100 != 11:
                return "выходная"
            else:
                return "выходных"
        
        word = morph.parse('выходной')[0]
        if count % 10 == 1 and count % 100 != 11:
            return word.inflect({'sing', 'nomn', 'femn'}).word  # выходная
        else:
            return word.inflect({'plur', 'gent'}).word  # выходных

    @Slot(int, result=str)
    def pluralizeVariables(self, count: int) -> str:
        """Склоняет 'переменная' в зависимости от числа"""
        if morph is None:
            if count % 10 == 1 and count % 100 != 11:
                return "переменная"
            elif 2 <= count % 10 <= 4 and (count % 100 < 10 or count % 100 >= 20):
                return "переменные"
            else:
                return "переменных"
        
        word = morph.parse('переменная')[0]
        if count % 10 == 1 and count % 100 != 11:
            return word.inflect({'sing', 'nomn'}).word  # переменная
        elif 2 <= count % 10 <= 4 and (count % 100 < 10 or count % 100 >= 20):
            return word.inflect({'plur', 'nomn'}).word  # переменные
        else:
            return word.inflect({'plur', 'gent'}).word  # переменных

    @Slot(int, result=str)
    def pluralizeRules(self, count: int) -> str:
        """Склоняет 'правило' в зависимости от числа"""
        if morph is None:
            if count % 10 == 1 and count % 100 != 11:
                return "правило"
            elif 2 <= count % 10 <= 4 and (count % 100 < 10 or count % 100 >= 20):
                return "правила"
            else:
                return "правил"
        
        word = morph.parse('правило')[0]
        if count % 10 == 1 and count % 100 != 11:
            return word.inflect({'sing', 'nomn'}).word  # правило
        elif 2 <= count % 10 <= 4 and (count % 100 < 10 or count % 100 >= 20):
            return word.inflect({'plur', 'nomn'}).word  # правила
        else:
            return word.inflect({'plur', 'gent'}).word  # правил

    @Slot(int, str)
    def addTerm(self, var_id: int, term_name: str):
        """Добавить терм в лингвистическую переменную"""
        try:
            var = self.engine.get_variable_by_id(var_id)
            if var:
                if len(var.terms) >= 10:
                    self.errorOccurred.emit("Максимум 10 термов")
                    return
                var.terms.append(FuzzyTerm(name=term_name))
                self._update_variables_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при добавлении терма: {str(e)}")

    @Slot(int, int)
    def removeTerm(self, var_id: int, term_index: int):
        """Удалить терм из лингвистической переменной"""
        try:
            var = self.engine.get_variable_by_id(var_id)
            if var:
                if len(var.terms) <= 1:
                    self.errorOccurred.emit("Должен быть минимум один терм")
                    return
                var.terms.pop(term_index)
                self._update_variables_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при удалении терма: {str(e)}")

    @Slot(int, int, str)
    def updateTerm(self, var_id: int, term_index: int, term_name: str):
        """Обновить название терма"""
        try:
            var = self.engine.get_variable_by_id(var_id)
            if var and 0 <= term_index < len(var.terms):
                var.terms[term_index].name = term_name
                self._update_variables_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении терма: {str(e)}")

    @Slot(int, float)
    def updateRuleWeight(self, rule_id: int, weight: float):
        """Обновить весовой коэффициент правила"""
        try:
            rule = next((r for r in self.engine.rule_set.rules if r.id == rule_id), None)
            if rule:
                rule.weight = weight
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении веса правила: {str(e)}")

    @Slot(int, int, str)
    def updateMfType(self, var_id: int, term_index: int, mf_type: str):
        """Обновить тип функции принадлежности"""
        try:
            var = self.engine.get_variable_by_id(var_id)
            if var and 0 <= term_index < len(var.terms):
                var.terms[term_index].mf_type = mf_type
                self._update_variables_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении типа функции: {str(e)}")

    @Slot(int, int, list)
    def updateMfParams(self, var_id: int, term_index: int, params):
        """Обновить параметры функции принадлежности"""
        try:
            var = self.engine.get_variable_by_id(var_id)
            if var and 0 <= term_index < len(var.terms):
                var.terms[term_index].mf_params = [float(p) for p in params]
                self._update_variables_model()
        except Exception as e:
            self.errorOccurred.emit(f"Ошибка при обновлении параметров функции: {str(e)}")

    @Slot(int, float)
    def addInputValue(self, var_id: int, value: float):
        """Добавить входное значение"""
        self._input_values[var_id] = value

    @Slot(int, float)
    def setInputValue(self, var_id: int, value: float):
        """Установить входное значение"""
        self._input_values[var_id] = value

    @Slot(int)
    def removeInputValue(self, var_id: int):
        """Удалить входное значение"""
        if var_id in self._input_values:
            del self._input_values[var_id]

    @Slot(str)
    def setDefuzzMethod(self, method: str):
        """Установить метод дефаззификации"""
        self._defuzz_method = method

    @Slot(str)
    def setActivationMethod(self, method: str):
        """Установить метод активации"""
        self._activation_method = method
