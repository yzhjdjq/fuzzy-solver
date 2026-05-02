import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

Item {
    id: root
    
    property int termIndex: 0
    property string termName: ""
    
    signal termChanged(int index, string name)
    signal termRemoved(int index)
    
    implicitHeight: 32
    implicitWidth: parent ? parent.width : 200
    
    RowLayout {
        anchors.fill: parent
        spacing: 6
        
        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 10
            color: "#F0EDFF"
            
            Text {
                anchors.centerIn: parent
                text: (termIndex + 1).toString()
                font.pixelSize: 10
                font.weight: Font.Bold
                color: Theme.primary
            }
        }
        
        TextField {
            id: termField
            text: termName
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            font.pixelSize: 13
            
            background: Rectangle {
                radius: 4
                color: Theme.background
                border.color: termField.activeFocus ? Theme.primary : Theme.border
                border.width: termField.activeFocus ? 2 : 1
            }
            
            onTextChanged: {
                if (text !== termName) {
                    root.termChanged(termIndex, text)
                }
            }
            
            Keys.onReturnPressed: {
                focus = false
            }
            Keys.onEnterPressed: {
                focus = false
            }
        }
        
        Button {
            text: "✕"
            onClicked: root.termRemoved(termIndex)
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            
            background: Rectangle {
                radius: 4
                color: parent.hovered ? "#FFE5E5" : "transparent"
                border.color: parent.activeFocus ? Theme.primary : "transparent"
                border.width: parent.activeFocus ? 2 : 0
                
                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast }
                }
            }
            
            contentItem: Text {
                text: parent.text
                color: parent.hovered ? Theme.error : "#B0B0B0"
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}