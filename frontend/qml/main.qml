import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"
import "theme"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 950; height: 600
    minimumWidth: 950; minimumHeight: 450
    title: "Решатель 0.1.0"
    color: Theme.background
    
    property var rulesModel: []
    property var variablesModel: []
    property var inputVariablesModel: []
    property var outputVariablesModel: []
    
    Component.onCompleted: {
        rulesModel = ruleController.rules
        variablesModel = ruleController.variables
        updateVariableModels()
        updateAllModels()
    }
    
    function updateVariableModels() {
        inputVariablesModel = ruleController.getInputVariables()
        outputVariablesModel = ruleController.getOutputVariables()
    }
    
    function updateAllModels() {
        rulesSection.rulesModel = rulesModel
        rulesSection.inputVariablesModel = inputVariablesModel
        rulesSection.outputVariablesModel = outputVariablesModel
        variablesSection.variablesModel = variablesModel
        termsSection.variablesModel = variablesModel
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        AppHeader {}
        
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            
            Flickable {
                anchors.fill: parent
                contentWidth: parent.width
                contentHeight: mainColumn.implicitHeight
                
                ColumnLayout {
                    id: mainColumn
                    width: scrollView.width
                    spacing: Theme.radiusSmall
                    
                    StatsPanel {
                        inputVarsCount: inputVariablesModel.length
                        outputVarsCount: outputVariablesModel.length
                        totalVarsCount: variablesModel.length
                        rulesCount: rulesModel.length
                        Layout.topMargin: parent.spacing
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        
                        onCalculateClicked: {
                            if (inputVariablesModel.length === 0) {
                                errorDialog.errorText = "Добавьте хотя бы одну входную переменную"
                                errorDialog.open()
                                return
                            }
                            if (outputVariablesModel.length === 0) {
                                errorDialog.errorText = "Добавьте хотя бы одну выходную переменную"
                                errorDialog.open()
                                return
                            }
                            if (rulesModel.length === 0) {
                                errorDialog.errorText = "Добавьте хотя бы одно правило"
                                errorDialog.open()
                                return
                            }
                            ruleController.evaluate()
                            graphsSection.graphsGenerated = true
                        }
                    }
                    
                    VariablesSection {
                        id: variablesSection
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        
                        onVariableAdded: (name, type) => {
                            ruleController.addLinguisticVariable(name, type)
                            updateVariableModels()
                        }
                        onVariableRemoved: (varId) => ruleController.removeLinguisticVariable(varId)
                        onVariableChanged: (varId, name, type) => ruleController.updateLinguisticVariable(varId, name, type)
                    }
                    
                    TermsSection {
                        id: termsSection
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        
                        onTermAdded: (varId, termName) => ruleController.addTerm(varId, termName)
                        onTermRemoved: (varId, termIndex) => ruleController.removeTerm(varId, termIndex)
                        onTermChanged: (varId, termIndex, termName) => ruleController.updateTerm(varId, termIndex, termName)
                        onTermMfTypeChanged: (varId, termIndex, mfType) => ruleController.updateMfType(varId, termIndex, mfType)
                        onTermMfParamsChanged: (varId, termIndex, params) => ruleController.updateMfParams(varId, termIndex, params)
                    }
                    
                    RulesSection {
                        id: rulesSection
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        
                        onRuleAdded: ruleController.addRule()
                        onRuleRemoved: (ruleId) => ruleController.removeRule(ruleId)
                        onConditionAdded: (ruleId, group) => ruleController.addCondition(ruleId, group)
                        onConditionRemoved: (ruleId, group, index) => ruleController.removeCondition(ruleId, group, index)
                        onVariableChanged: (ruleId, group, index, variableId, term) => 
                            ruleController.updateConditionVariable(ruleId, group, index, variableId, term)
                        onOperatorChanged: (ruleId, group, index, operator) => 
                            ruleController.updateConditionOperator(ruleId, group, index, operator)
                        onWeightChanged: (ruleId, weight) => ruleController.updateRuleWeight(ruleId, weight)
                    }

                    SolverConditions {
                        id: solverSection
                        inputVariablesModel: mainWindow.inputVariablesModel
                        defuzzMethod: "bos"
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        
                        onInputValueChanged: (varId, value) => {
                            ruleController.setInputValue(varId, value)
                        }
                        onInputVariableRemoved: (varId) => {
                            ruleController.removeInputValue(varId)
                        }
                        onInputVariableAdded: (varId) => {
                            ruleController.addInputValue(varId, 0.0)
                        }
                        onDefuzzMethodSelected: (method) => {
                            ruleController.setDefuzzMethod(method)
                        }
                    }

                    GraphsSection {
                        id: graphsSection
                        variablesModel: mainWindow.variablesModel
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                    }
                    
                    Item { Layout.fillWidth: true; Layout.preferredHeight: 20 }
                }
            }
        }
    }
    
    Connections {
        target: ruleController
        
        function onRulesChanged(rules) { 
            rulesModel = rules
            updateAllModels()
        }
        function onVariablesChanged(variables) {
            variablesModel = variables
            updateVariableModels()
            updateAllModels()
        }
        function onErrorOccurred(message) {
            errorDialog.errorText = message
            errorDialog.open()
        }
    }
    
    ErrorDialog { id: errorDialog }
}