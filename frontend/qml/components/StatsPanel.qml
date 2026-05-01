import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import "../theme"

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
        radius: Theme.radiusMedium
        color: Theme.surface
        border.color: Theme.border
        
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
        spacing: Theme.radiusMedium
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.radiusSmall
            
            StatItem {
                value: inputVarsCount
                label: ruleController.pluralizeInput(inputVarsCount)
                valueColor: Theme.primary
            }
            
            OperatorText { text: "+" }
            
            StatItem {
                value: outputVarsCount
                label: ruleController.pluralizeOutput(outputVarsCount)
                valueColor: Theme.success
            }
            
            OperatorText { text: "=" }
            
            StatItem {
                value: totalVarsCount
                label: ruleController.pluralizeVariables(totalVarsCount)
                valueColor: Theme.primary
            }
        }
        
        Rectangle {
            width: 2; height: 45
            color: Theme.border
            Layout.alignment: Qt.AlignVCenter
        }
        
        StatItem {
            value: rulesCount
            label: ruleController.pluralizeRules(rulesCount)
            valueColor: Theme.primary
        }
        
        Item { Layout.fillWidth: true }
        
        Button {
            text: "▶ Выполнить расчет"
            
            topPadding: 8; bottomPadding: 8
            leftPadding: 16; rightPadding: 16
            
            background: Rectangle {
                radius: Theme.radiusSmall
                color: parent.hovered ? Theme.primaryDark : Theme.primary
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Theme.primary
                    shadowOpacity: 0.3
                    shadowBlur: 8
                    shadowVerticalOffset: 3
                }
            }
            
            contentItem: Text {
                text: parent.text
                color: Theme.textOnPrimary
                font.pixelSize: 13; font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: root.calculateClicked()
        }
    }
    
    component StatItem: ColumnLayout {
        property int value: 0
        property string label: ""
        property color valueColor: Theme.primary
        
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
            font.pixelSize: Theme.fontSizeSmall; color: Theme.textSecondary
            Layout.alignment: Qt.AlignHCenter
        }
    }
    
    component OperatorText: Text {
        text: parent.text
        font.pixelSize: 20; font.weight: Font.Bold
        color: "#B0B0B0"
        Layout.alignment: Qt.AlignVCenter
    }
}