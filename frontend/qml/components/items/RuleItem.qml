import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import "../delegates"
import "../../theme"

Item {
    id: root
    
    property int ruleId: 0
    property var conditions: ([])
    property var conclusions: ([])
    property var inputVariables: ([])
    property var outputVariables: ([])
    
    signal conditionAdded(int ruleId, string group)
    signal conditionRemoved(int ruleId, string group, int index)
    signal variableChanged(int ruleId, string group, int index, int variableId, string term)
    signal operatorChanged(int ruleId, string group, int index, string operator)
    signal ruleRemoved(int ruleId)
    
    implicitHeight: ruleContent.height + 30
    implicitWidth: parent ? parent.width : 400
    
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusMedium
        color: Theme.surface
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.08
            shadowBlur: 15
            shadowVerticalOffset: 3
        }
        
        Rectangle {
            width: 4
            height: parent.height - 20
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            radius: 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.primary }
                GradientStop { position: 1.0; color: Theme.primaryLight }
            }
        }
    }
    
    RowLayout {
        id: ruleContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 25
        spacing: 15
        
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 18
            color: "#F0EDFF"
            
            Text {
                anchors.centerIn: parent
                text: (ruleId + 1).toString()
                font.pixelSize: Theme.fontSizeNormal
                font.weight: Font.Bold
                color: Theme.primary
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.radiusSmall
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: conditionContent.implicitHeight + 24
                radius: 10
                color: Theme.background
                border.color: Theme.border
                border.width: 1
                
                ColumnLayout {
                    id: conditionContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.radiusMedium
                    spacing: Theme.radiusSmall
                    
                    Text {
                        text: "ЕСЛИ"
                        font.pixelSize: Theme.fontSizeNormal
                        font.weight: Font.Bold
                        color: Theme.primary
                        Layout.leftMargin: 5
                        Layout.bottomMargin: 4
                    }
                    
                    Repeater {
                        model: conditions
                        delegate: ConditionDelegate {
                            conditionIndex: model.index
                            groupType: "condition"
                            variablesModel: root.inputVariables
                            currentVariableId: modelData.variable_id
                            currentTerm: modelData.term
                            currentOperator: modelData.operator
                            isLast: model.index === conditions.length - 1
                            showRemove: conditions.length > 1
                            showAddButton: conditions.length < 3
                            Layout.fillWidth: true
                            Layout.topMargin: 2
                            Layout.bottomMargin: 2
                            
                            onVariableChanged: (ruleId, group, index, variableId, term) => {
                                root.variableChanged(root.ruleId, group, index, variableId, term)
                            }
                            onOperatorChanged: (ruleId, group, index, operator) => {
                                root.operatorChanged(root.ruleId, group, index, operator)
                            }
                            onRemove: {
                                root.conditionRemoved(root.ruleId, "condition", model.index)
                            }
                            onAddCondition: {
                                root.conditionAdded(root.ruleId, "condition")
                            }
                        }
                    }
                }
            }
        }
        
        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: "#F0EDFF"
            
            Text {
                anchors.centerIn: parent
                text: "→"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primary
                font.weight: Font.Bold
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.radiusSmall
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: conclusionContent.implicitHeight + 24
                radius: 10
                color: "#F0FFF4"
                border.color: "#E0F0E0"
                border.width: 1
                
                ColumnLayout {
                    id: conclusionContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.radiusMedium
                    spacing: Theme.radiusSmall
                    
                    Text {
                        text: "ТО"
                        font.pixelSize: Theme.fontSizeNormal
                        font.weight: Font.Bold
                        color: Theme.success
                        Layout.leftMargin: 5
                        Layout.bottomMargin: 4
                    }
                    
                    Repeater {
                        model: conclusions
                        delegate: ConditionDelegate {
                            conditionIndex: model.index
                            groupType: "conclusion"
                            variablesModel: root.outputVariables
                            currentVariableId: modelData.variable_id
                            currentTerm: modelData.term
                            currentOperator: modelData.operator
                            isLast: model.index === conclusions.length - 1
                            showRemove: conclusions.length > 1
                            showAddButton: conclusions.length < 3
                            Layout.fillWidth: true
                            Layout.topMargin: 2
                            Layout.bottomMargin: 2
                            
                            onVariableChanged: (ruleId, group, index, variableId, term) => {
                                root.variableChanged(root.ruleId, group, index, variableId, term)
                            }
                            onOperatorChanged: (ruleId, group, index, operator) => {
                                root.operatorChanged(root.ruleId, group, index, operator)
                            }
                            onRemove: {
                                root.conditionRemoved(root.ruleId, "conclusion", model.index)
                            }
                            onAddCondition: {
                                root.conditionAdded(root.ruleId, "conclusion")
                            }
                        }
                    }
                }
            }
        }
        
        Button {
            id: deleteButton
            text: "✕"
            onClicked: root.ruleRemoved(root.ruleId)
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            
            background: Rectangle {
                radius: Theme.radiusSmall
                color: deleteButton.hovered ? "#FFE5E5" : "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast }
                }
            }
            
            contentItem: Text {
                text: deleteButton.text
                color: deleteButton.hovered ? Theme.error : "#B0B0B0"
                font.pixelSize: Theme.fontSizeNormal
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                
                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast }
                }
            }
            
            ToolTip {
                visible: deleteButton.hovered
                text: "Удалить правило"
                delay: 500
                
                background: Rectangle {
                    color: Theme.error
                    radius: 6
                }
                
                contentItem: Text {
                    text: "Удалить правило"
                    color: Theme.textOnPrimary
                    font.pixelSize: Theme.fontSizeNormal
                }
            }
        }
    }
}