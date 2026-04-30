import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: delegateRoot
    
    property int conditionIndex: 0
    property string groupType: ""
    property string currentVariable: "Температура низкая"
    property string currentOperator: "и"
    property bool isLast: true
    property bool showRemove: true
    property bool showAddButton: false
    
    signal variableChanged(int ruleId, string group, int index, string variable)
    signal operatorChanged(int ruleId, string group, int index, string operator)
    signal remove()
    signal addCondition()
    
    implicitHeight: 40
    implicitWidth: 200
    
    RowLayout {
        anchors.fill: parent
        spacing: 5
        
        ComboBox {
            id: variableCombo
            model: [
                "Температура низкая",
                "Температура средняя",
                "Температура высокая",
                "Давление низкое",
                "Давление среднее",
                "Давление высокое",
                "Влажность низкая",
                "Влажность средняя",
                "Влажность высокая"
            ]
            currentIndex: {
                var idx = model.indexOf(currentVariable)
                return idx >= 0 ? idx : 0
            }
            Layout.fillWidth: true
            
            onCurrentTextChanged: {
                // Не отправляем сигнал при инициализации
                if (currentText !== currentVariable) {
                    delegateRoot.variableChanged(-1, groupType, conditionIndex, currentText)
                }
            }
        }
        
        ComboBox {
            id: operatorCombo
            model: ["и", "или"]
            currentIndex: currentOperator === "или" ? 1 : 0
            visible: !isLast
            Layout.preferredWidth: 60
            
            onCurrentTextChanged: {
                // Не отправляем сигнал при инициализации
                if (currentText !== currentOperator) {
                    delegateRoot.operatorChanged(-1, groupType, conditionIndex, currentText)
                }
            }
        }
        
        Button {
            text: "×"
            visible: showRemove
            onClicked: delegateRoot.remove()
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            
            background: Rectangle {
                color: "#ff6b6b"
                radius: 3
            }
        }
        
        Button {
            text: "+"
            visible: showAddButton && isLast
            onClicked: delegateRoot.addCondition()
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            
            background: Rectangle {
                color: "#4caf50"
                radius: 3
            }
        }
    }
}