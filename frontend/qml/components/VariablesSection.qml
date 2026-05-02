import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "."
import "items"
import "../theme"

CollapsibleSection {
    id: root
    
    property var variablesModel: []
    
    signal variableAdded(string name, string type)
    signal variableRemoved(int varId)
    signal variableChanged(int varId, string name, string type)
    
    Layout.fillWidth: true
    
    title: "📊 Лингвистические переменные"
    collapsed: false
    
    Repeater {
        model: root.variablesModel
        delegate: LinguisticVariableItem {
            varId: modelData.id
            varName: modelData.name
            varType: modelData.type
            terms: modelData.terms
            Layout.fillWidth: true
            
            onVariableRemoved: (varId) => root.variableRemoved(varId)
            onVariableChanged: (varId, name, type) => root.variableChanged(varId, name, type)
        }
    }
    
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        
        TextField {
            id: newVarName
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            placeholderText: "Название переменной"
            font.pixelSize: Theme.fontSizeNormal
            
            background: Rectangle {
                radius: 6
                color: Theme.surface
                border.color: newVarName.activeFocus ? Theme.primary : Theme.border
                border.width: newVarName.activeFocus ? 2 : 1
            }
            
            Keys.onReturnPressed: {
                if (text.length > 0) {
                    addVariable()
                }
            }
            Keys.onEnterPressed: {
                if (text.length > 0) {
                    addVariable()
                }
            }
        }
        
        ComboBox {
            id: newVarType
            model: ["входная", "выходная"]
            currentIndex: 0
            Layout.preferredWidth: 120
            Layout.preferredHeight: 36
            implicitHeight: 36
            
            background: Rectangle {
                radius: 6
                color: parent.hovered ? "#F5F5F5" : Theme.surface
                border.color: newVarType.activeFocus ? Theme.primary : Theme.border
                border.width: newVarType.activeFocus ? 2 : 1
            }
            
            contentItem: Text {
                text: parent.displayText
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeNormal
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }
        }
        
        Button {
            id: addVarButton
            text: "Добавить"
            enabled: newVarName.text.length > 0
            Layout.preferredHeight: 36
            
            topPadding: 8; bottomPadding: 8
            leftPadding: 16; rightPadding: 16
            
            background: Rectangle {
                radius: Theme.radiusSmall
                color: parent.enabled ? (parent.hovered ? Theme.primaryDark : Theme.primary) : Theme.border
                border.color: addVarButton.activeFocus ? Theme.accent : "transparent"
                border.width: addVarButton.activeFocus ? 2 : 0
            }
            
            contentItem: Text {
                text: parent.text
                color: Theme.textOnPrimary
                font.pixelSize: Theme.fontSizeNormal
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: addVariable()
            
            Keys.onReturnPressed: {
                if (enabled) addVariable()
            }
            Keys.onEnterPressed: {
                if (enabled) addVariable()
            }
        }
    }
    
    function addVariable() {
        if (newVarName.text.length > 0) {
            root.variableAdded(newVarName.text, newVarType.currentText)
            newVarName.text = ""
            newVarName.focus = true
        }
    }
    
    Component.onCompleted: {
        newVarName.focus = true
    }
}