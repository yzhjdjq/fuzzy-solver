import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"
import "items"

CollapsibleSection {
    id: root
    
    property var rulesModel: []
    property var inputVariablesModel: []
    property var outputVariablesModel: []
    
    signal ruleAdded()
    signal ruleRemoved(int ruleId)
    signal conditionAdded(int ruleId, string group)
    signal conditionRemoved(int ruleId, string group, int index)
    signal variableChanged(int ruleId, string group, int index, int variableId, string term)
    signal operatorChanged(int ruleId, string group, int index, string operator)
    signal weightChanged(int ruleId, double weight)
    
    Layout.fillWidth: true
    
    title: "📝 Правила"
    collapsed: false
    
    Repeater {
        id: rulesRepeater
        model: root.rulesModel
        
        delegate: RuleItem {
            ruleId: modelData.id
            conditions: modelData.conditions
            conclusions: modelData.conclusions
            inputVariables: root.inputVariablesModel
            outputVariables: root.outputVariablesModel
            Layout.fillWidth: true
            
            onConditionAdded: (ruleId, group) => root.conditionAdded(ruleId, group)
            onConditionRemoved: (ruleId, group, index) => root.conditionRemoved(ruleId, group, index)
            onVariableChanged: (ruleId, group, index, variableId, term) => 
                root.variableChanged(ruleId, group, index, variableId, term)
            onOperatorChanged: (ruleId, group, index, operator) => 
                root.operatorChanged(ruleId, group, index, operator)
            onRuleRemoved: (ruleId) => root.ruleRemoved(ruleId)
            onRuleWeightChanged: (ruleId, weight) => root.weightChanged(ruleId, weight)
        }
    }
    
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 56
        
        Button {
            id: addRuleButton
            text: "+ Добавить правило"
            enabled: root.rulesModel.length < 10
            anchors.centerIn: parent
            
            topPadding: 12; bottomPadding: 12
            leftPadding: 24; rightPadding: 24
            
            background: Rectangle {
                radius: Theme.radiusSmall
                color: parent.enabled ? (parent.hovered ? "#E8F5E9" : "#F0F0F0") : "#F5F5F5"
                border.color: {
                    if (addRuleButton.activeFocus) return Theme.accent
                    if (parent.enabled) return Theme.success
                    return Theme.border
                }
                border.width: addRuleButton.activeFocus ? 2 : parent.enabled ? 2 : 1
            }
            
            contentItem: Text {
                text: parent.text
                color: parent.enabled ? Theme.success : "#B0B0B0"
                font.pixelSize: Theme.fontSizeNormal; font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: root.ruleAdded()
            
            Keys.onReturnPressed: {
                if (enabled) root.ruleAdded()
            }
            Keys.onEnterPressed: {
                if (enabled) root.ruleAdded()
            }
        }
    }
}