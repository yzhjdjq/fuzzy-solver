import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "items"

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
            font.pixelSize: 14
            
            background: Rectangle {
                radius: 6
                color: "#FFFFFF"
                border.color: "#E0E0E0"
                border.width: 1
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
        }
        
        Button {
            text: "Добавить"
            enabled: newVarName.text.length > 0
            Layout.preferredHeight: 36
            
            topPadding: 8; bottomPadding: 8
            leftPadding: 16; rightPadding: 16
            
            background: Rectangle {
                radius: 8
                color: parent.enabled ? (parent.hovered ? "#5A4BD1" : "#6C5CE7") : "#E0E0E0"
            }
            
            contentItem: Text {
                text: parent.text
                color: "#FFFFFF"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                root.variableAdded(newVarName.text, newVarType.currentText)
                newVarName.text = ""
            }
        }
    }
}