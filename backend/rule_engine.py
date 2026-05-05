from typing import Any
import json
import math
from .fuzzy_models import RuleSet, Rule, Condition, LogicalOperator, LinguisticVariable, VariableType, FuzzyTerm

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
            FuzzyTerm(name="низкая", mf_type="triangle", mf_params=[-10.0, -10.0, 13.0]),
            # FuzzyTerm(name="средняя"),
            FuzzyTerm(name="высокая", mf_type="triangle", mf_params=[10.0, 45.0, 45.0])
        ]
        temp_var = LinguisticVariable(id=0, name="Температура", type=VariableType.INPUT, terms=temp_terms)
        
        humidity_terms = [
            FuzzyTerm(name="низкая", mf_type="triangle", mf_params=[0.0, 0.0, 75.0]),
            # FuzzyTerm(name="средняя"),
            FuzzyTerm(name="высокая", mf_type="triangle", mf_params=[50.0, 100.0, 100.0])
        ]
        humidity_var = LinguisticVariable(id=1, name="Влажность", type=VariableType.INPUT, terms=humidity_terms)
        
        # pressure_terms = [
        #     FuzzyTerm(name="низкое"),
        #     FuzzyTerm(name="среднее"),
        #     FuzzyTerm(name="высокое")
        # ]
        # pressure_var = LinguisticVariable(id=2, name="Давление", type=VariableType.INPUT, terms=pressure_terms)
        
        # Выходные переменные
        # power_terms = [
        #     FuzzyTerm(name="малая"),
        #     FuzzyTerm(name="средняя"),
        #     FuzzyTerm(name="большая")
        # ]
        # power_var = LinguisticVariable(id=3, name="Мощность", type=VariableType.OUTPUT, terms=power_terms)
        
        speed_terms = [
            FuzzyTerm(name="низкая", mf_type="triangle", mf_params=[0.0, 0.0, 13.0]),
            # FuzzyTerm(name="средняя"),
            FuzzyTerm(name="высокая", mf_type="triangle", mf_params=[10.0, 25.0, 25.0])
        ]
        speed_var = LinguisticVariable(id=2, name="Скорость", type=VariableType.OUTPUT, terms=speed_terms)
        
        self.rule_set.linguistic_variables = [temp_var, humidity_var, speed_var] #[temp_var, humidity_var, pressure_var, power_var, speed_var]

        rule1 = Rule(
            id=0,
            weight=0.5,
            conditions=[Condition(
                variable_id=temp_var.id,    # температура
                term=temp_var.terms[0].name,    # низкая
                operator=LogicalOperator.AND
            )],
            conclusions=[Condition(
                variable_id=speed_var.id,   # скорость
                term=speed_var.terms[1].name,   # высокая
                operator=LogicalOperator.AND
            )]
        )
        rule2 = Rule(
            id=1,
            weight=0.5,
            conditions=[Condition(
                variable_id=temp_var.id,    # температура
                term=temp_var.terms[1].name,    # высокая
                operator=LogicalOperator.AND
            )],
            conclusions=[Condition(
                variable_id=speed_var.id,   # скорость
                term=speed_var.terms[0].name,   # низкая
                operator=LogicalOperator.AND
            )]
        )
        rule3 = Rule(
            id=2,
            weight=0.5,
            conditions=[
                Condition(
                    variable_id=temp_var.id,    # температура
                    term=temp_var.terms[0].name,    # низкая
                    operator=LogicalOperator.AND    # И
                ),
                Condition(
                    variable_id=humidity_var.id,    # влажность
                    term=humidity_var.terms[0].name,    # низкая
                    operator=LogicalOperator.AND
                )
            ],
            conclusions=[Condition(
                variable_id=speed_var.id,   # скорость
                term=speed_var.terms[0].name,   # низкая
                operator=LogicalOperator.AND
            )]
        )
        self.rule_set.rules = [rule1, rule2, rule3]
    
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
    
    def _aggregate_conditions(self, rule: Rule, fuzzified: dict[int, dict[str, float]]) -> float:
        """
        Агрегирование условий правила.
        Вычисляет результирующую степень истинности условия ЕСЛИ.
        Для AND: min, для OR: max.
        """
        if not rule.conditions:
            return 0.0
        
        memberships = []
        for i, condition in enumerate(rule.conditions):
            var_id = condition.variable_id
            term_name = condition.term
            
            # Получаем степень принадлежности для условия
            if var_id in fuzzified and term_name in fuzzified[var_id]:
                mu = fuzzified[var_id][term_name]
            else:
                mu = 0.0
            
            memberships.append(mu)
        
        # Первое условие задаёт начальное значение
        result = memberships[0]
        
        # Применяем операторы к последующим условиям
        for i in range(1, len(memberships)):
            operator = rule.conditions[i - 1].operator  # Оператор связывает i-1 и i условие
            if operator == LogicalOperator.AND:
                result = min(result, memberships[i])
            elif operator == LogicalOperator.OR:
                result = max(result, memberships[i])
        
        return round(result, 4)

    def _activate_conclusions(self, rule: Rule, weighted_degree: float, method: str) -> list[dict]:
        """Активация заключений правила"""
        activated = []
        for conclusion in rule.conclusions:
            var = self.get_variable_by_id(conclusion.variable_id)
            if not var:
                continue
            
            term = next((t for t in var.terms if t.name == conclusion.term), None)
            if not term:
                continue
            
            activated.append({
                "variable_id": conclusion.variable_id,
                "term": term,
                "weighted_degree": weighted_degree,  # μ правила
                "activation_method": method
            })
        
        return activated

    def _activate_term(self, term: FuzzyTerm, degree: float, method: str) -> dict:
        """
        Активация одного терма.
        Возвращает активированную функцию принадлежности как набор точек для графика
        и математическое представление для дефаззификации.
        """
        params = term.mf_params
        mf_type = term.mf_type
        
        # Генерируем точки для графика (100 точек на диапазон параметров)
        all_params = params
        min_val = min(all_params) - 0.1 * (max(all_params) - min(all_params) or 1)
        max_val = max(all_params) + 0.1 * (max(all_params) - min(all_params) or 1)
        
        points = []
        step = (max_val - min_val) / 100
        x = min_val
        
        while x <= max_val:
            # Исходная функция принадлежности
            match mf_type:
                case "triangle":
                    original_mu = self._triangular_mf(x, params)
                case "trapezoid":
                    original_mu = self._trapezoidal_mf(x, params)
                case "gaussian":
                    original_mu = self._gaussian_mf(x, params)
                case _:
                    original_mu = 0.0
            
            # Активация
            match method:
                case "min":
                    activated_mu = min(degree, original_mu)
                case "prod":
                    activated_mu = degree * original_mu
                case "average":
                    activated_mu = (degree + original_mu) / 2
                case _:
                    activated_mu = min(degree, original_mu)
            
            points.append({"x": round(x, 3), "y": round(activated_mu, 3)})
            x += step
        
        return {
            "term": term,
            "degree": degree,
            "method": method,
            "points": points,
            "mf_type": mf_type,
            "mf_params": params
        }

    def _apply_activation(self, mu: float, degree: float, method: str) -> float:
        match method:
            case "min":
                return min(degree, mu)
            case "prod":
                return degree * mu
            case "average":
                return (degree + mu) / 2
        return mu

    def _accumulate(self, activated_terms: list[dict]) -> dict:
        if not activated_terms:
            return {"points": [], "max_points": []}
        
        # Собираем все X от всех термов
        all_x = set()
        for term_data in activated_terms:
            for point in term_data["points"]:
                all_x.add(point["x"])
        
        sorted_x = sorted(list(all_x))
        
        # Для каждого X вычисляем максимум по всем термам напрямую
        max_points = []
        for x in sorted_x:
            max_y = 0.0
            for term_data in activated_terms:
                # Вычисляем значение функции терма в точке x
                term = term_data.get("term")
                if term:
                    y = self._calculate_membership(x, term)
                    activated_y = self._apply_activation(y, term_data["degree"], term_data["method"])
                    max_y = max(max_y, activated_y)
            max_points.append({"x": x, "y": round(max_y, 4)})
        
        return {
            "activated_terms": activated_terms,
            "max_points": max_points
        }

    def _defuzzify_centroid(self, max_points: list[dict]) -> float:
        """Центр тяжести (Centroid)"""
        if len(max_points) < 2:
            return 0.0
        
        numerator = 0.0
        denominator = 0.0
        
        for i in range(len(max_points) - 1):
            x1, y1 = max_points[i]["x"], max_points[i]["y"]
            x2, y2 = max_points[i + 1]["x"], max_points[i + 1]["y"]
            dx = x2 - x1
            
            # Интегрируем методом трапеций
            numerator += dx * (x1 * y1 + x2 * y2) / 2
            denominator += dx * (y1 + y2) / 2
        
        if denominator == 0:
            return 0.0
        
        return numerator / denominator

    def _defuzzify_lom(self, max_points: list[dict]) -> float:
        """Левая мода (Left of Maximum)"""
        if not max_points:
            return 0.0
        
        max_y = max(p["y"] for p in max_points)
        for p in max_points:
            if p["y"] >= max_y * 0.99:
                return p["x"]
        return max_points[0]["x"]

    def _defuzzify_rom(self, max_points: list[dict]) -> float:
        """Правая мода (Right of Maximum)"""
        if not max_points:
            return 0.0
        
        max_y = max(p["y"] for p in max_points)
        result = max_points[0]["x"]
        for p in max_points:
            if p["y"] >= max_y * 0.99:
                result = p["x"]
        return result

    def _defuzzify_bos(self, max_points: list[dict]) -> float:
        """Биссектриса площади (Bisector of Area)"""
        if len(max_points) < 2:
            return 0.0
        
        # Вычисляем общую площадь
        total_area = 0.0
        for i in range(len(max_points) - 1):
            dx = max_points[i + 1]["x"] - max_points[i]["x"]
            total_area += dx * (max_points[i]["y"] + max_points[i + 1]["y"]) / 2
        
        if total_area == 0:
            return 0.0
        
        half_area = total_area / 2
        accumulated = 0.0
        
        for i in range(len(max_points) - 1):
            x1, y1 = max_points[i]["x"], max_points[i]["y"]
            x2, y2 = max_points[i + 1]["x"], max_points[i + 1]["y"]
            dx = x2 - x1
            segment_area = dx * (y1 + y2) / 2
            
            if accumulated + segment_area >= half_area:
                remaining = half_area - accumulated
                if segment_area > 0:
                    t = remaining / segment_area
                    return x1 + t * dx
                return x1
            
            accumulated += segment_area
        
        return max_points[-1]["x"]

    def _defuzzify(self, max_points: list[dict], method: str) -> float:
        """Дефаззификация результирующей функции"""
        match method:
            case "centroid":
                return self._defuzzify_centroid(max_points)
            case "lom":
                return self._defuzzify_lom(max_points)
            case "rom":
                return self._defuzzify_rom(max_points)
            case "bos":
                return self._defuzzify_bos(max_points)
            case _:
                return self._defuzzify_centroid(max_points)

    def _find_best_term(self, var_id: int, crisp_value: float) -> str:
        """Найти терм с максимальной принадлежностью для чёткого значения"""
        var = self.get_variable_by_id(var_id)
        if not var or not var.terms:
            return ""
        
        best_term = ""
        best_mu = -1.0
        
        for term in var.terms:
            mu = self._calculate_membership(crisp_value, term)
            if mu > best_mu:
                best_mu = mu
                best_term = term.name
        
        return best_term

    def evaluate(
        self,
        inputs: dict[int, float],
        activation_method: str = "min",
        defuzz_method: str = "bos"
    ) -> dict[str, float]:
        """Выполнить нечеткий вывод"""
        print("=" * 60)
        print("ШАГ 1: ФАЗЗИФИКАЦИЯ")
        print("=" * 60)

        fuzzified = self.fuzzify_all(inputs)
        for var_id, memberships in fuzzified.items():
            var = self.get_variable_by_id(var_id)
            var_name = var.name if var else f"Переменная {var_id}"
            print(f"  {var_name} (ID={var_id}):")
            for term, mu in memberships.items():
                print(f"    {term}: μ = {mu}")

        print("\n" + "=" * 60)
        print("ШАГ 2: АГРЕГИРОВАНИЕ УСЛОВИЙ")
        print("=" * 60)

        rule_results = []
        for rule in self.rule_set.rules:
            rule_degree = self._aggregate_conditions(rule, fuzzified)
            # Применяем вес правила
            weighted_degree = round(rule_degree * rule.weight, 4)
            rule_results.append({
                "rule": rule,
                "weighted_degree": weighted_degree
            })

            print(f"  Правило {rule.id + 1}:")
            print(f"    Условия: ", end="")
            cond_strs = []
            for c in rule.conditions:
                var = self.get_variable_by_id(c.variable_id)
                var_name = var.name if var else f"?{c.variable_id}"
                cond_strs.append(f"{var_name} IS {c.term}")
            print(" И ".join(cond_strs) if rule.conditions[0].operator == LogicalOperator.AND else " ИЛИ ".join(cond_strs))
            print(f"    Степень истинности: {rule_degree}")
            print(f"    Вес правила: {rule.weight}")
            print(f"    Взвешенная степень: {weighted_degree}")

        print("\n" + "=" * 60)
        print(f"ШАГ 3: АКТИВАЦИЯ ЗАКЛЮЧЕНИЙ (метод: {activation_method})")
        print("=" * 60)

        all_activated = []
        for result in rule_results:
            activated = self._activate_conclusions(
                result["rule"],
                result["weighted_degree"],
                activation_method
            )
            all_activated.extend(activated)

            print(f"  Правило {result['rule'].id + 1}:")
            for act in activated:
                var = self.get_variable_by_id(act["variable_id"])
                var_name = var.name if var else f"?{act['variable_id']}"
                print(f"    {var_name} IS {act['term'].name}: degree = {act['weighted_degree']}")

        print("\n" + "=" * 60)
        print("ШАГ 4: АККУМУЛЯЦИЯ")
        print("=" * 60)

        accumulated = {}
        for act in all_activated:
            var_id = act["variable_id"]
            if var_id not in accumulated:
                accumulated[var_id] = []

            # Активируем терм
            activated_term = self._activate_term(
                act["term"],
                act["weighted_degree"],
                act["activation_method"]
            )
            accumulated[var_id].append(activated_term)

        result = {}
        for var_id, terms in accumulated.items():
            var = self.get_variable_by_id(var_id)
            var_name = var.name if var else f"Переменная {var_id}"

            acc_result = self._accumulate(terms)
            result[var_id] = {
                "variable_name": var_name,
                "accumulated": acc_result
            }

            print(f"  {var_name}:")
            for term in terms:
                print(f"    {term['term'].name}: degree = {term['degree']}, "
                    f"method = {term['method']}")

        print("\n" + "=" * 60)
        print(f"ШАГ 5: ДЕФАЗЗИФИКАЦИЯ (метод: {defuzz_method})")
        print("=" * 60)
        
        results = {}
        for var_id, terms in accumulated.items():
            var = self.get_variable_by_id(var_id)
            var_name = var.name if var else f"Переменная {var_id}"
            
            acc_result = self._accumulate(terms)
            crisp_value = self._defuzzify(acc_result["max_points"], defuzz_method)
            best_term = self._find_best_term(var_id, crisp_value)

            results[var_id] = {
                "variable_name": var_name,
                "crisp_value": round(crisp_value, 4),
                "best_term": best_term,
                "accumulated": acc_result
            }
            print(f"  {var_name}: {crisp_value:.4f}")

        return results
