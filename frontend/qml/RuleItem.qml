import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "."

Item {
    id: root
    
    property int ruleId: 0
    property var conditions: ([])
    property var conclusions: ([])
    
    signal conditionAdded(int ruleId, string group)
    signal conditionRemoved(int ruleId, string group, int index)
    signal variableChanged(int ruleId, string group, int index, string variable)
    signal operatorChanged(int ruleId, string group, int index, string operator)
    signal ruleRemoved(int ruleId)
    
    implicitHeight: ruleContent.height + 20
    implicitWidth: parent ? parent.width : 400
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        border.color: "#ddd"
        border.width: 1
        radius: 5
    }
    
    RowLayout {
        id: ruleContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
        spacing: 10
        
        // Заголовок правила
        Text {
            text: "Правило " + (ruleId + 1) + ":"
            font.bold: true
            font.pixelSize: 14
            color: "#333"
            Layout.alignment: Qt.AlignVCenter
            Layout.minimumWidth: 80
        }
        
        // Секция "Если"
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            
            Text {
                text: "Если"
                font.bold: true
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 40
            }
            
            ColumnLayout {
                id: conditionColumn
                Layout.fillWidth: true
                spacing: 5
                
                Repeater {
                    model: conditions
                    delegate: ConditionDelegate {
                        conditionIndex: model.index
                        groupType: "condition"
                        currentVariable: modelData.variable
                        currentOperator: modelData.operator
                        isLast: model.index === conditions.length - 1
                        showRemove: conditions.length > 1
                        showAddButton: conditions.length < 3
                        Layout.fillWidth: true
                        
                        onVariableChanged: (ruleId, group, index, variable) => {
                            root.variableChanged(root.ruleId, group, index, variable)
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
        
        // Секция "То"
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            
            Text {
                text: "То"
                font.bold: true
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 30
            }
            
            ColumnLayout {
                id: conclusionColumn
                Layout.fillWidth: true
                spacing: 5
                
                Repeater {
                    model: conclusions
                    delegate: ConditionDelegate {
                        conditionIndex: model.index
                        groupType: "conclusion"
                        currentVariable: modelData.variable
                        currentOperator: modelData.operator
                        isLast: model.index === conclusions.length - 1
                        showRemove: conclusions.length > 1
                        showAddButton: conclusions.length < 3
                        Layout.fillWidth: true
                        
                        onVariableChanged: (ruleId, group, index, variable) => {
                            root.variableChanged(root.ruleId, group, index, variable)
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
        
        // Кнопка удаления правила
        Button {
            text: "🗑"
            onClicked: root.ruleRemoved(root.ruleId)
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            
            background: Rectangle {
                color: "#ff6b6b"
                radius: 3
            }
            
            ToolTip {
                visible: parent.hovered
                text: "Удалить правило"
            }
        }
    }
}