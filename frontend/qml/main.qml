import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"
import "theme"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 800; height: 600
    title: "Решатель 0.1.0"
    color: "#F8F9FA"
    
    minimumWidth: 620; minimumHeight: 450
    
    property var rulesModel: []
    property var variablesModel: []
    property var inputVariablesModel: []
    property var outputVariablesModel: []
    
    Component.onCompleted: {
        rulesModel = ruleController.rules
        variablesModel = ruleController.variables
        updateVariableModels()
    }
    
    function updateVariableModels() {
        inputVariablesModel = ruleController.getInputVariables()
        outputVariablesModel = ruleController.getOutputVariables()
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
                    spacing: 8
                    
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
                        }
                    }
                    
                    VariablesSection {
                        id: variablesSection
                        variablesModel: mainWindow.variablesModel
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        
                        onVariableAdded: (name, type) => {
                            ruleController.addLinguisticVariable(name, type)
                            updateVariableModels()
                        }
                        onVariableRemoved: (varId) => ruleController.removeLinguisticVariable(varId)
                        onVariableChanged: (varId, name, type) => ruleController.updateLinguisticVariable(varId, name, type)
                    }
                    
                    RulesSection {
                        id: rulesSection
                        rulesModel: mainWindow.rulesModel
                        inputVariablesModel: mainWindow.inputVariablesModel
                        outputVariablesModel: mainWindow.outputVariablesModel
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
                    }
                    
                    Item { Layout.fillWidth: true; Layout.preferredHeight: 20 }
                }
            }
        }
    }
    
    Connections {
        target: ruleController
        
        function onRulesChanged(rules) { rulesModel = rules }
        function onVariablesChanged(variables) {
            variablesModel = variables
            updateVariableModels()
        }
        function onErrorOccurred(message) {
            errorDialog.errorText = message
            errorDialog.open()
        }
    }
    
    ErrorDialog { id: errorDialog }
}