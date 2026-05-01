import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

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
        radius: Theme.radiusSmall
        color: Theme.background
        border.color: varType === "входная" ? "#E8E8FF" : "#E8FFE8"
        border.width: 1
    }
    
    ColumnLayout {
        id: varContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: Theme.radiusSmall
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: varType === "входная" ? "#E8E8FF" : "#E8FFE8"
                
                Text {
                    anchors.centerIn: parent
                    text: varType === "входная" ? "↓" : "↑"
                    font.pixelSize: Theme.fontSizeSmall
                    color: varType === "входная" ? Theme.primary : Theme.success
                }
            }
            
            TextField {
                id: nameField
                text: varName
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                font.pixelSize: Theme.fontSizeNormal
                
                background: Rectangle {
                    radius: 6
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1
                }
                
                onTextChanged: {
                    if (text !== varName) {
                        root.variableChanged(varId, text, varType)
                    }
                }
            }
            
            ComboBox {
                id: typeCombo
                model: ["входная", "выходная"]
                currentIndex: varType === "выходная" ? 1 : 0
                Layout.preferredWidth: 120
                Layout.preferredHeight: 36
                implicitHeight: 36
                
                background: Rectangle {
                    radius: 6
                    color: parent.hovered ? "#F5F5F5" : Theme.surface
                    border.color: Theme.border
                    border.width: 1
                }
                
                contentItem: Text {
                    text: parent.displayText
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSizeNormal
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                }
                
                onCurrentTextChanged: {
                    if (currentText !== varType) {
                        root.variableChanged(varId, nameField.text, currentText)
                    }
                }
            }
            
            Button {
                text: "✕"
                onClicked: root.variableRemoved(varId)
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: parent.hovered ? "#FFE5E5" : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered ? Theme.error : "#B0B0B0"
                    font.pixelSize: Theme.fontSizeNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}