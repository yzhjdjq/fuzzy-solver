import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

Item {
    id: root
    
    property int varId: 0
    property string varName: ""
    property double value: 0.0
    property double minVal: 0.0
    property double maxVal: 1.0
    
    signal inputValueChanged(int varId, double value)
    signal removeRequested(int varId)
    
    implicitHeight: 60
    implicitWidth: parent ? parent.width : 400
    
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: Theme.background
        border.color: "#E8E8FF"
        border.width: 1
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: "#E8E8FF"
            
            Text {
                anchors.centerIn: parent
                text: "↓"
                font.pixelSize: 12
                color: Theme.primary
            }
        }
        
        Text {
            text: varName
            font.pixelSize: Theme.fontSizeNormal
            font.weight: Font.Bold
            color: Theme.textPrimary
            Layout.preferredWidth: 150
            elide: Text.ElideRight
        }
        
        Slider {
            id: valueSlider
            from: root.minVal
            to: root.maxVal
            stepSize: 0.01
            value: root.value
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            
            background: Rectangle {
                x: valueSlider.leftPadding
                y: valueSlider.topPadding + valueSlider.availableHeight / 2 - height / 2
                implicitWidth: 100
                implicitHeight: 4
                width: valueSlider.availableWidth
                height: implicitHeight
                radius: 2
                color: Theme.border
                
                Rectangle {
                    width: valueSlider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.primary
                    radius: 2
                }
            }
            
            handle: Rectangle {
                x: valueSlider.leftPadding + valueSlider.visualPosition * (valueSlider.availableWidth - width)
                y: valueSlider.topPadding + valueSlider.availableHeight / 2 - height / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: valueSlider.pressed ? Theme.primaryDark : Theme.primary
                border.color: Theme.textOnPrimary
                border.width: 2
            }
            
            onValueChanged: {
                root.value = value
                root.inputValueChanged(varId, value)
            }
        }
        
        TextField {
            id: valueField
            text: root.value.toFixed(2)
            font.pixelSize: 12
            Layout.preferredWidth: 70
            Layout.preferredHeight: 28
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            
            background: Rectangle {
                radius: 4
                color: Theme.surface
                border.color: {
                    if (valueField.activeFocus) return Theme.primary
                    var val = parseFloat(valueField.text.replace(",", "."))
                    if (isNaN(val) || val < root.minVal || val > root.maxVal) return Theme.error
                    return Theme.border
                }
                border.width: valueField.activeFocus ? 2 : 1
            }
            
            validator: RegularExpressionValidator {
                regularExpression: /^-?\d+([.,]\d{1,2})?$/
            }
            
            onEditingFinished: {
                var text = valueField.text.replace(",", ".")
                var newVal = parseFloat(text)
                
                if (isNaN(newVal)) {
                    valueField.text = root.value.toFixed(2)
                    return
                }
                
                if (newVal < root.minVal) {
                    newVal = root.minVal
                    valueField.text = newVal.toFixed(2)
                } else if (newVal > root.maxVal) {
                    newVal = root.maxVal
                    valueField.text = newVal.toFixed(2)
                }
                
                root.value = newVal
                valueSlider.value = newVal
                root.inputValueChanged(varId, newVal)
            }
            
            Connections {
                target: valueSlider
                function onValueChanged() {
                    valueField.text = valueSlider.value.toFixed(2)
                }
            }
        }
        
        Button {
            text: "✕"
            onClicked: root.removeRequested(varId)
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