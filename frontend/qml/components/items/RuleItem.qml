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
    property double weight: 1.0
    
    signal conditionAdded(int ruleId, string group)
    signal conditionRemoved(int ruleId, string group, int index)
    signal variableChanged(int ruleId, string group, int index, int variableId, string term)
    signal operatorChanged(int ruleId, string group, int index, string operator)
    signal ruleRemoved(int ruleId)
    signal ruleWeightChanged(int ruleId, double weight)
    
    implicitHeight: ruleContent.height
    implicitWidth: parent ? parent.width : 900
    
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
            height: parent.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            radius: 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.primary }
                GradientStop { position: 1.0; color: Theme.primaryLight }
            }
        }
    }
    
    ColumnLayout {
        id: ruleContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Theme.radiusLarge
        spacing: Theme.radiusMedium
        
        // Заголовок правила с весом
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
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
            
            Text {
                text: "Правило " + (ruleId + 1)
                font.pixelSize: Theme.fontSizeNormal
                font.weight: Font.Bold
                color: Theme.textPrimary
                Layout.fillWidth: true
            }
            
            // Весовой коэффициент
            RowLayout {
                spacing: 8
                
                Text {
                    text: "Вес:"
                    font.pixelSize: 12
                    color: Theme.textSecondary
                    Layout.alignment: Qt.AlignVCenter
                }
                
                Slider {
                    id: weightSlider
                    from: 0.0
                    to: 1.0
                    stepSize: 0.1
                    value: root.weight
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignVCenter
                    
                    background: Rectangle {
                        x: weightSlider.leftPadding
                        y: weightSlider.topPadding + weightSlider.availableHeight / 2 - height / 2
                        implicitWidth: 100
                        implicitHeight: 4
                        width: weightSlider.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: Theme.border
                        
                        Rectangle {
                            width: weightSlider.visualPosition * parent.width
                            height: parent.height
                            color: Theme.primary
                            radius: 2
                        }
                    }
                    
                    handle: Rectangle {
                        x: weightSlider.leftPadding + weightSlider.visualPosition * (weightSlider.availableWidth - width)
                        y: weightSlider.topPadding + weightSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: weightSlider.pressed ? Theme.primaryDark : Theme.primary
                        border.color: Theme.textOnPrimary
                        border.width: 2
                    }
                    
                    onValueChanged: {
                        root.weight = value
                        root.ruleWeightChanged(ruleId, value)
                    }
                }
                
                // Числовое отображение веса
                TextField {
                    id: weightField
                    text: root.weight.toFixed(2)
                    font.pixelSize: 12
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 28
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    background: Rectangle {
                        radius: 4
                        color: Theme.background
                        border.color: weightField.activeFocus ? Theme.primary : Theme.border
                        border.width: weightField.activeFocus ? 2 : 1
                    }
                    
                    validator: RegularExpressionValidator {
                        regularExpression: /^(0(\.\d{1,2})?|1(\.0{1,2})?)$/
                    }
                    
                    onEditingFinished: {
                        var newWeight = parseFloat(weightField.text)
                        if (!isNaN(newWeight) && newWeight >= 0.0 && newWeight <= 1.0) {
                            root.weight = newWeight
                            weightSlider.value = newWeight
                            root.ruleWeightChanged(ruleId, newWeight)
                        }
                    }
                }
            }
            
            // Кнопка удаления правила
            Button {
                id: deleteButton
                text: "✕"
                onClicked: root.ruleRemoved(root.ruleId)
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: deleteButton.hovered ? "#FFE5E5" : "transparent"
                    border.color: deleteButton.activeFocus ? Theme.primary : "transparent"
                    border.width: deleteButton.activeFocus ? 2 : 0
                    
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
        
        // Основное содержимое правила
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.radiusMedium
            
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
                                isLast: model.index === conclusions.length - 1
                                showRemove: conclusions.length > 1
                                showAddButton: conclusions.length < 3
                                showOperator: false
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
        }
    }
}