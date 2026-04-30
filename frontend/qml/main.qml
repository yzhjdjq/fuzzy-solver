import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import "."

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 800
    height: 600
    minimumWidth: 620
    minimumHeight: 380
    title: "Решатель 0.1.0"
    color: "#F8F9FA"
    
    property var rulesModel: []
    
    Component.onCompleted: {
        rulesModel = ruleController.rules
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Современный заголовок
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#6C5CE7" }
                GradientStop { position: 1.0; color: "#A29BFE" }
            }
            
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                
                // Декоративные круги
                Rectangle {
                    width: 120
                    height: 120
                    radius: 60
                    color: "#FFFFFF"
                    opacity: 0.1
                    anchors.right: parent.right
                    anchors.rightMargin: -30
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Rectangle {
                    width: 80
                    height: 80
                    radius: 40
                    color: "#FFFFFF"
                    opacity: 0.15
                    anchors.left: parent.left
                    anchors.leftMargin: -20
                    anchors.top: parent.top
                    anchors.topMargin: -20
                }
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // Логотип - график функции принадлежности
                Rectangle {
                    width: 40
                    height: 40
                    radius: 12
                    color: "#FFFFFF"
                    opacity: 0.2
                    
                    Canvas {
                        anchors.centerIn: parent
                        width: 24
                        height: 16
                        
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.strokeStyle = "#FFFFFF";
                            ctx.lineWidth = 2;
                            ctx.beginPath();
                            ctx.moveTo(0, 16);
                            ctx.lineTo(6, 16);
                            ctx.lineTo(12, 0);
                            ctx.lineTo(18, 16);
                            ctx.lineTo(24, 16);
                            ctx.stroke();
                        }
                    }
                }
                
                ColumnLayout {
                    spacing: 2
                    
                    Text {
                        text: "Решатель"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                    
                    Text {
                        text: "Система нечеткого вывода"
                        color: "#FFFFFF"
                        opacity: 0.8
                        font.pixelSize: 11
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Версия приложения с улучшенной видимостью
                Rectangle {
                    width: 60
                    height: 24
                    radius: 12
                    color: "#FFFFFF"
                    opacity: 0.25
                    border.color: "#FFFFFF"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "v0.1.0"
                        color: "#FFFFFF"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                }
            }
        }
        
        // Основной контент
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                
                // Статистика
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    radius: 12
                    color: "#FFFFFF"
                    
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#000000"
                        shadowOpacity: 0.1
                        shadowBlur: 10
                        shadowVerticalOffset: 2
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        
                        // Счетчик правил
                        Item {
                            Layout.fillWidth: true
                            
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                Text {
                                    text: rulesModel.length.toString()
                                    font.pixelSize: 24
                                    font.weight: Font.Bold
                                    color: "#6C5CE7"
                                }
                                
                                Text {
                                    text: ruleController.pluralizeRules(rulesModel.length)
                                    font.pixelSize: 14
                                    color: "#636E72"
                                }
                            }
                        }
                        
                        Rectangle {
                            width: 1
                            height: 30
                            color: "#E0E0E0"
                        }
                        
                        // Кнопка расчета
                        Button {
                            text: "▶ Выполнить расчет"
                            Layout.rightMargin: 15
                            
                            topPadding: 10
                            bottomPadding: 10
                            leftPadding: 20
                            rightPadding: 20
                            
                            background: Rectangle {
                                radius: 8
                                color: parent.hovered ? "#5A4BD1" : "#6C5CE7"
                                
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: "#6C5CE7"
                                    shadowOpacity: 0.3
                                    shadowBlur: 8
                                    shadowVerticalOffset: 3
                                }
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#FFFFFF"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: ruleController.evaluate()
                        }
                    }
                }
                
                // Секция правил
                ScrollView {
                    id: scrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    
                    ColumnLayout {
                        id: rulesContainer
                        spacing: 12
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
                            text: "+ Добавить правило"
                            enabled: rulesModel.length < 10
                            Layout.alignment: Qt.AlignCenter
                            Layout.topMargin: 5
                            Layout.bottomMargin: 20
                            
                            topPadding: 12
                            bottomPadding: 12
                            leftPadding: 24
                            rightPadding: 24
                            
                            background: Rectangle {
                                radius: 8
                                color: parent.enabled ? (parent.hovered ? "#E8F5E9" : "#F0F0F0") : "#F5F5F5"
                                border.color: parent.enabled ? "#00B894" : "#E0E0E0"
                                border.width: 2
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "#00B894" : "#B0B0B0"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: ruleController.addRule()
                        }
                    }
                }
            }
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
        
        background: Rectangle {
            radius: 12
            color: "#FFFFFF"
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#000000"
                shadowOpacity: 0.2
                shadowBlur: 20
                shadowVerticalOffset: 5
            }
        }
        
        property alias text: errorText.text
        
        ColumnLayout {
            spacing: 15
            
            Rectangle {
                width: 60
                height: 60
                radius: 30
                color: "#FFE5E5"
                Layout.alignment: Qt.AlignHCenter
                
                Text {
                    anchors.centerIn: parent
                    text: "⚠"
                    font.pixelSize: 24
                }
            }
            
            Text {
                id: errorText
                text: ""
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                color: "#FF7675"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}