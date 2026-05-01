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
    title: "Решатель 0.1.0"
    color: "#F8F9FA"
    
    minimumWidth: 620
    minimumHeight: 450
    
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
    
    // Вычисляемые свойства для статистики
    property int inputVarsCount: inputVariablesModel.length
    property int outputVarsCount: outputVariablesModel.length
    property int totalVarsCount: variablesModel.length
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Заголовок
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
        
        // Основной контент со скроллом
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
                    spacing: 12
                    
                    // Статистика
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.topMargin: 8
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
                            spacing: 12
                            
                            // Формула: входные + выходные = всего переменных
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                // Входные
                                ColumnLayout {
                                    spacing: 2
                                    Layout.alignment: Qt.AlignVCenter
                                    
                                    Text {
                                        text: inputVarsCount.toString()
                                        font.pixelSize: 22
                                        font.weight: Font.Bold
                                        color: "#6C5CE7"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: ruleController.pluralizeInput(inputVarsCount)
                                        font.pixelSize: 11
                                        color: "#636E72"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                                
                                Text {
                                    text: "+"
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                    color: "#B0B0B0"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                
                                // Выходные
                                ColumnLayout {
                                    spacing: 2
                                    Layout.alignment: Qt.AlignVCenter
                                    
                                    Text {
                                        text: outputVarsCount.toString()
                                        font.pixelSize: 22
                                        font.weight: Font.Bold
                                        color: "#00B894"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: ruleController.pluralizeOutput(outputVarsCount)
                                        font.pixelSize: 11
                                        color: "#636E72"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                                
                                Text {
                                    text: "="
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                    color: "#B0B0B0"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                
                                // Всего переменных
                                ColumnLayout {
                                    spacing: 2
                                    Layout.alignment: Qt.AlignVCenter
                                    
                                    Text {
                                        text: totalVarsCount.toString()
                                        font.pixelSize: 22
                                        font.weight: Font.Bold
                                        color: "#6C5CE7"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: ruleController.pluralizeVariables(totalVarsCount)
                                        font.pixelSize: 11
                                        color: "#636E72"
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                            
                            // Разделитель
                            Rectangle {
                                width: 2
                                height: 45
                                color: "#E8E8E8"
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            // Правила
                            ColumnLayout {
                                spacing: 2
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 8
                                
                                Text {
                                    text: rulesModel.length.toString()
                                    font.pixelSize: 22
                                    font.weight: Font.Bold
                                    color: "#6C5CE7"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                
                                Text {
                                    text: ruleController.pluralizeRules(rulesModel.length)
                                    font.pixelSize: 11
                                    color: "#636E72"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // Кнопка расчета
                            Button {
                                text: "▶ Выполнить расчет"
                                
                                topPadding: 8
                                bottomPadding: 8
                                leftPadding: 16
                                rightPadding: 16
                                
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
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    if (inputVarsCount === 0) {
                                        ruleController.errorOccurred("Добавьте хотя бы одну входную переменную")
                                        return
                                    }
                                    if (outputVarsCount === 0) {
                                        ruleController.errorOccurred("Добавьте хотя бы одну выходную переменную")
                                        return
                                    }
                                    if (rulesModel.length === 0) {
                                        ruleController.errorOccurred("Добавьте хотя бы одно правило")
                                        return
                                    }
                                    ruleController.evaluate()
                                }
                            }
                        }
                    }
                               
                    // Секция "Лингвистические переменные"
                    CollapsibleSection {
                        id: variablesSection
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.topMargin: 8
                        title: "📊 Лингвистические переменные"
                        collapsed: false
                        
                        Repeater {
                            model: variablesModel
                            delegate: LinguisticVariableItem {
                                varId: modelData.id
                                varName: modelData.name
                                varType: modelData.type
                                terms: modelData.terms
                                Layout.fillWidth: true
                                
                                onVariableRemoved: (varId) => {
                                    ruleController.removeLinguisticVariable(varId)
                                }
                                onVariableChanged: (varId, name, type) => {
                                    ruleController.updateLinguisticVariable(varId, name, type)
                                }
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            TextField {
                                id: newVarName
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                placeholderText: "Название переменной"
                                font.pixelSize: 14
                                
                                background: Rectangle {
                                    radius: 6
                                    color: "#FFFFFF"
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                }
                            }
                            
                            ComboBox {
                                id: newVarType
                                model: ["входная", "выходная"]
                                currentIndex: 0
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 36
                                implicitHeight: 36
                                
                                background: Rectangle {
                                    radius: 6
                                    color: parent.hovered ? "#F5F5F5" : "#FFFFFF"
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                }
                                
                                contentItem: Text {
                                    text: parent.displayText
                                    color: "#2D3436"
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                }
                            }
                            
                            Button {
                                text: "Добавить"
                                enabled: newVarName.text.length > 0
                                Layout.preferredHeight: 36
                                
                                topPadding: 8
                                bottomPadding: 8
                                leftPadding: 16
                                rightPadding: 16
                                
                                background: Rectangle {
                                    radius: 8
                                    color: parent.enabled ? (parent.hovered ? "#5A4BD1" : "#6C5CE7") : "#E0E0E0"
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: "#FFFFFF"
                                    font.pixelSize: 14
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    ruleController.addLinguisticVariable(newVarName.text, newVarType.currentText)
                                    newVarName.text = ""
                                    updateVariableModels()
                                }
                            }
                        }
                    }
                    
                    // Секция "Правила"
                    CollapsibleSection {
                        id: rulesSection
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.topMargin: 8
                        title: "📝 Правила"
                        collapsed: true
                        
                        // Правила
                        Repeater {
                            id: rulesRepeater
                            model: rulesModel
                            
                            delegate: RuleItem {
                                ruleId: modelData.id
                                conditions: modelData.conditions
                                conclusions: modelData.conclusions
                                inputVariables: inputVariablesModel
                                outputVariables: outputVariablesModel
                                Layout.fillWidth: true
                                
                                onConditionAdded: (ruleId, group) => {
                                    ruleController.addCondition(ruleId, group)
                                }
                                onConditionRemoved: (ruleId, group, index) => {
                                    ruleController.removeCondition(ruleId, group, index)
                                }
                                onVariableChanged: (ruleId, group, index, variableId, term) => {
                                    ruleController.updateConditionVariable(ruleId, group, index, variableId, term)
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
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 56  // Высота кнопки + отступы
                            
                            Button {
                                text: "+ Добавить правило"
                                enabled: rulesModel.length < 10
                                anchors.centerIn: parent
                                
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
                    
                    // Отступ снизу
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
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
        
        function onVariablesChanged(variables) {
            variablesModel = variables
            updateVariableModels()
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