import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import "../theme"

Dialog {
    id: root
    title: "Ошибка"
    standardButtons: Dialog.Ok
    modal: true
    
    property alias errorText: errorTextItem.text
    
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    background: Rectangle {
        radius: Theme.radiusMedium
        color: Theme.surface
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.2
            shadowBlur: 20
            shadowVerticalOffset: 5
        }
    }
    
    ColumnLayout {
        spacing: 15
        
        Rectangle {
            width: 60; height: 60; radius: 30
            color: "#FFE5E5"
            Layout.alignment: Qt.AlignHCenter
            
            Text {
                anchors.centerIn: parent
                text: "⚠"
                font.pixelSize: 24
            }
        }
        
        Text {
            id: errorTextItem
            text: ""
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            color: Theme.error
            font.pixelSize: Theme.fontSizeNormal
            horizontalAlignment: Text.AlignHCenter
        }
    }
}