import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 80
    
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6C5CE7" }
            GradientStop { position: 1.0; color: "#A29BFE" }
        }
        
        // Декоративные круги
        Rectangle {
            width: 120; height: 120; radius: 60
            color: "#FFFFFF"; opacity: 0.1
            anchors.right: parent.right
            anchors.rightMargin: -30
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            width: 80; height: 80; radius: 40
            color: "#FFFFFF"; opacity: 0.15
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
            width: 40; height: 40; radius: 12
            color: "#FFFFFF"; opacity: 0.2
            
            Canvas {
                anchors.centerIn: parent
                width: 24; height: 16
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.strokeStyle = "#FFFFFF";
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.moveTo(0, 16); ctx.lineTo(6, 16);
                    ctx.lineTo(12, 0); ctx.lineTo(18, 16);
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
                color: "#FFFFFF"; opacity: 0.8
                font.pixelSize: 11
            }
        }
        
        Item { Layout.fillWidth: true }
        
        Rectangle {
            width: 60; height: 24; radius: 12
            color: "#FFFFFF"; opacity: 0.25
            border.color: "#FFFFFF"; border.width: 1
            
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