import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "."

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    title: "Решатель 0.1.0"
    
    property var rulesModel: []
    
    Component.onCompleted: {
        rulesModel = ruleController.rules
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        
        // Заголовок
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "#4a90e2"
            radius: 5
            
            Text {
                anchors.centerIn: parent
                text: "Решатель 0.1.0"
                color: "white"
                font.bold: true
                font.pixelSize: 24
            }
        }
        
        // Секция правил со скроллом
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            
            ColumnLayout {
                id: rulesContainer
                spacing: 10
                width: scrollView.width
                
                Repeater {
                    id: rulesRepeater
                    model: rulesModel
                    
                    delegate: RuleItem {
                        ruleId: modelData.id
                        conditions: modelData.conditions
                        conclusions: modelData.conclusions
                        Layout.fillWidth: true
                        
                        onConditionAdded: (ruleId, group) => {
                            ruleController.addCondition(ruleId, group)
                        }
                        onConditionRemoved: (ruleId, group, index) => {
                            ruleController.removeCondition(ruleId, group, index)
                        }
                        onVariableChanged: (ruleId, group, index, variable) => {
                            ruleController.updateConditionVariable(ruleId, group, index, variable)
                        }
                        onOperatorChanged: (ruleId, group, index, operator) => {
                            ruleController.updateConditionOperator(ruleId, group, index, operator)
                        }
                        onRuleRemoved: (ruleId) => {
                            ruleController.removeRule(ruleId)
                        }
                    }
                }
                
                // Кнопка добавления правила
                Button {
                    text: "Добавить правило"
                    enabled: rulesModel.length < 10
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 5
                    Layout.bottomMargin: 20
                    
                    onClicked: {
                        ruleController.addRule()
                    }
                    
                    background: Rectangle {
                        color: parent.enabled ? "#4caf50" : "#ccc"
                        radius: 5
                    }
                }
            }
        }
        
        // Кнопка расчета внизу
        Button {
            text: "Выполнить расчет"
            onClicked: ruleController.evaluate()
            Layout.alignment: Qt.AlignCenter
            
            background: Rectangle {
                color: "#2196f3"
                radius: 5
            }
        }
        
        Text {
            text: "Правил: " + rulesModel.length + "/10"
            color: "#666"
            Layout.alignment: Qt.AlignCenter
        }
    }
    
    Connections {
        target: ruleController
        
        function onRulesChanged(rules) {
            rulesModel = rules
        }
        
        function onErrorOccurred(message) {
            errorDialog.text = message
            errorDialog.open()
        }
    }
    
    Dialog {
        id: errorDialog
        title: "Ошибка"
        standardButtons: Dialog.Ok
        modal: true
        
        x: (mainWindow.width - width) / 2
        y: (mainWindow.height - height) / 2
        
        property alias text: errorText.text
        
        ColumnLayout {
            spacing: 10
            
            Text {
                id: errorText
                text: ""
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}