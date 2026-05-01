// frontend/qml/LinguisticVariableItem.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "."

Item {
    id: root
    
    property int varId: 0
    property string varName: ""
    property string varType: "входная"
    property var terms: ([])
    
    signal variableRemoved(int varId)
    signal variableChanged(int varId, string name, string type)
    signal termAdded(int varId)
    signal termRemoved(int varId, int termIndex)
    signal termChanged(int varId, int termIndex, string termName)
    
    implicitHeight: varContent.height + 20
    implicitWidth: parent ? parent.width : 400
    
    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#F8F9FA"
        border.color: varType === "входная" ? "#E8E8FF" : "#E8FFE8"
        border.width: 1
    }
    
    ColumnLayout {
        id: varContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 8
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            // Тип переменной (индикатор)
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: varType === "входная" ? "#E8E8FF" : "#E8FFE8"
                
                Text {
                    anchors.centerIn: parent
                    text: varType === "входная" ? "↓" : "↑"
                    font.pixelSize: 12
                    color: varType === "входная" ? "#6C5CE7" : "#00B894"
                }
            }
            
            // Название переменной
            TextField {
                id: nameField
                text: varName
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                font.pixelSize: 14
                
                background: Rectangle {
                    radius: 6
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"
                    border.width: 1
                }
                
                onTextChanged: {
                    if (text !== varName) {
                        root.variableChanged(varId, text, varType)
                    }
                }
            }
            
            // Тип переменной
            ComboBox {
                id: typeCombo
                model: ["входная", "выходная"]
                currentIndex: varType === "выходная" ? 1 : 0
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
                
                onCurrentTextChanged: {
                    if (currentText !== varType) {
                        root.variableChanged(varId, nameField.text, currentText)
                    }
                }
            }
            
            // Кнопка удаления
            Button {
                text: "✕"
                onClicked: root.variableRemoved(varId)
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                
                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? "#FFE5E5" : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered ? "#FF7675" : "#B0B0B0"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}