import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

Item {
    id: root
    
    property int inputVarsCount: 0
    property int outputVarsCount: 0
    property int totalVarsCount: 0
    property int rulesCount: 0
    
    signal calculateClicked()
    
    Layout.fillWidth: true
    Layout.preferredHeight: 70
    
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#FAFBFC"
        border.color: "#E8E8E8"
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.1
            shadowBlur: 10
            shadowVerticalOffset: 2
        }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 12
        
        // Формула: входные + выходные = всего переменных
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            StatItem {
                value: inputVarsCount
                label: ruleController.pluralizeInput(inputVarsCount)
                valueColor: "#6C5CE7"
            }
            
            OperatorText { text: "+" }
            
            StatItem {
                value: outputVarsCount
                label: ruleController.pluralizeOutput(outputVarsCount)
                valueColor: "#00B894"
            }
            
            OperatorText { text: "=" }
            
            StatItem {
                value: totalVarsCount
                label: ruleController.pluralizeVariables(totalVarsCount)
                valueColor: "#6C5CE7"
            }
        }
        
        Separator {}
        
        StatItem {
            value: rulesCount
            label: ruleController.pluralizeRules(rulesCount)
            valueColor: "#6C5CE7"
        }
        
        Item { Layout.fillWidth: true }
        
        CalculateButton {
            onClicked: root.calculateClicked()
        }
    }
    
    // Вложенные компоненты
    component StatItem: ColumnLayout {
        property int value: 0
        property string label: ""
        property color valueColor: "#6C5CE7"
        
        spacing: 2
        Layout.alignment: Qt.AlignVCenter
        
        Text {
            text: value.toString()
            font.pixelSize: 22; font.weight: Font.Bold
            color: valueColor
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: label
            font.pixelSize: 11; color: "#636E72"
            Layout.alignment: Qt.AlignHCenter
        }
    }
    
    component OperatorText: Text {
        text: parent.text
        font.pixelSize: 20; font.weight: Font.Bold
        color: "#B0B0B0"
        Layout.alignment: Qt.AlignVCenter
    }
    
    component Separator: Rectangle {
        width: 2; height: 45
        color: "#E8E8E8"
        Layout.alignment: Qt.AlignVCenter
    }
    
    component CalculateButton: Button {
        text: "▶ Выполнить расчет"
        
        topPadding: 8; bottomPadding: 8
        leftPadding: 16; rightPadding: 16
        
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
            font.pixelSize: 13; font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}