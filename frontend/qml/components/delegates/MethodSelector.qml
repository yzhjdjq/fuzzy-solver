import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

Item {
    id: root
    
    property string label: ""
    property var model: []
    property string currentValue: ""
    
    signal methodSelected(string value)
    
    implicitHeight: column.implicitHeight
    Layout.fillWidth: true

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.radiusSmall
        
        Text {
            text: root.label
            font.pixelSize: Theme.fontSizeNormal
            font.weight: Font.Bold
            color: Theme.textPrimary
        }
        
        ComboBox {
            id: methodCombo
            model: root.model
            textRole: "text"
            
            currentIndex: {
                for (var i = 0; i < model.length; i++) {
                    if (model[i].value === root.currentValue) return i
                }
                return 0
            }
            
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            implicitHeight: 36
            
            background: Rectangle {
                radius: 6
                color: parent.hovered ? "#F5F5F5" : Theme.surface
                border.color: methodCombo.activeFocus ? Theme.primary : Theme.border
                border.width: methodCombo.activeFocus ? 2 : 1
            }
            
            contentItem: Text {
                text: parent.displayText
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeNormal
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }
            
            onActivated: {
                root.currentValue = model[currentIndex].value
                root.methodSelected(model[currentIndex].value)
            }
        }
    }
}