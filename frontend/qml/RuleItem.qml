import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
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
    
    implicitHeight: ruleContent.height + 30
    implicitWidth: parent ? parent.width : 400
    
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#FFFFFF"
        
        // Тень
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.08
            shadowBlur: 15
            shadowVerticalOffset: 3
        }
        
        // Цветная полоса слева
        Rectangle {
            width: 4
            height: parent.height - 20
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            radius: 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6C5CE7" }
                GradientStop { position: 1.0; color: "#A29BFE" }
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
        
        // Заголовок правила с номером
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 18
            color: "#F0EDFF"
            
            Text {
                anchors.centerIn: parent
                text: (ruleId + 1).toString()
                font.pixelSize: 14
                font.weight: Font.Bold
                color: "#6C5CE7"
            }
        }
        
        // Секция "Если"
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: conditionContent.implicitHeight + 24
                radius: 10
                color: "#F8F9FA"
                border.color: "#E8E8E8"
                border.width: 1
                
                ColumnLayout {
                    id: conditionContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: "ЕСЛИ"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#6C5CE7"
                        Layout.leftMargin: 5
                        Layout.bottomMargin: 4
                    }
                    
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
                            Layout.topMargin: 2
                            Layout.bottomMargin: 2
                            
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
        }
        
        // Стрелка
        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: "#F0EDFF"
            
            Text {
                anchors.centerIn: parent
                text: "→"
                font.pixelSize: 16
                color: "#6C5CE7"
                font.weight: Font.Bold
            }
        }
        
        // Секция "То"
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
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
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: "ТО"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#00B894"
                        Layout.leftMargin: 5
                        Layout.bottomMargin: 4
                    }
                    
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
                            Layout.topMargin: 2
                            Layout.bottomMargin: 2
                            
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
        }
        
        // Кнопка удаления правила
        Button {
            id: deleteButton
            text: "✕"
            onClicked: root.ruleRemoved(root.ruleId)
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            
            topPadding: 6
            bottomPadding: 6
            leftPadding: 10
            rightPadding: 10
            
            background: Rectangle {
                radius: 8
                color: deleteButton.hovered ? "#FFE5E5" : "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            contentItem: Text {
                text: deleteButton.text
                color: deleteButton.hovered ? "#FF7675" : "#B0B0B0"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            ToolTip {
                visible: deleteButton.hovered
                text: "Удалить правило"
                delay: 500
                
                background: Rectangle {
                    color: "#FF7675"
                    radius: 6
                }
                
                contentItem: Text {
                    text: "Удалить правило"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                }
            }
        }
    }
}