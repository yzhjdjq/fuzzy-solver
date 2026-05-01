import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: delegateRoot
    
    property int conditionIndex: 0
    property string groupType: ""
    property var variablesModel: []
    property var termsModel: []
    property int currentVariableId: 0
    property string currentTerm: ""
    property string currentOperator: "и"
    property bool isLast: true
    property bool showRemove: true
    property bool showAddButton: false
    
    signal variableChanged(int ruleId, string group, int index, int variableId, string term)
    signal operatorChanged(int ruleId, string group, int index, string operator)
    signal remove()
    signal addCondition()
    
    implicitHeight: 36
    implicitWidth: 200
    
    RowLayout {
        anchors.fill: parent
        spacing: 8
        
        ComboBox {
            id: variableCombo
            model: variablesModel
            textRole: "name"
            valueRole: "id"
            
            currentIndex: {
                for (var i = 0; i < variablesModel.length; i++) {
                    if (variablesModel[i].id === currentVariableId) return i
                }
                return 0
            }
            
            Layout.fillWidth: true
            Layout.minimumWidth: 120
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
                rightPadding: 12
                elide: Text.ElideRight
                clip: true
            }
            
            onCurrentIndexChanged: {
                if (currentIndex >= 0 && variablesModel[currentIndex]) {
                    var varId = variablesModel[currentIndex].id
                    var term = termsModel.length > 0 ? termsModel[0] : ""
                    delegateRoot.variableChanged(-1, groupType, conditionIndex, varId, term)
                }
            }
        }
        
        ComboBox {
            id: operatorCombo
            model: ["и", "или"]
            currentIndex: currentOperator === "или" ? 1 : 0
            visible: !isLast
            Layout.preferredWidth: 70
            Layout.minimumWidth: 60
            Layout.preferredHeight: 36
            implicitHeight: 36
            
            background: Rectangle {
                radius: 6
                color: parent.hovered ? "#F0EDFF" : "#FFFFFF"
                border.color: "#E0E0E0"
                border.width: 1
            }
            
            contentItem: Text {
                text: parent.displayText
                color: "#6C5CE7"
                font.pixelSize: 14
                font.weight: Font.Medium
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                leftPadding: 8
                rightPadding: 8
            }
            
            onCurrentTextChanged: {
                if (currentText !== currentOperator) {
                    delegateRoot.operatorChanged(-1, groupType, conditionIndex, currentText)
                }
            }
        }
        
        Button {
            text: "✕"
            visible: showRemove
            onClicked: delegateRoot.remove()
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#FFE5E5" : "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            contentItem: Text {
                text: parent.text
                color: parent.hovered ? "#FF7675" : "#B0B0B0"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        Button {
            text: "+"
            visible: showAddButton && isLast
            onClicked: delegateRoot.addCondition()
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            
            background: Rectangle {
                radius: 8
                color: parent.hovered ? "#E8F5E9" : "#F0F0F0"
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            contentItem: Text {
                text: parent.text
                color: parent.hovered ? "#00B894" : "#636E72"
                font.pixelSize: 16
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}