import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

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
        spacing: Theme.radiusSmall
        
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
                color: parent.hovered ? "#F5F5F5" : Theme.surface
                border.color: Theme.border
                border.width: 1
            }
            
            contentItem: Text {
                text: parent.displayText
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeNormal
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
                color: parent.hovered ? "#F0EDFF" : Theme.surface
                border.color: Theme.border
                border.width: 1
            }
            
            contentItem: Text {
                text: parent.displayText
                color: Theme.primary
                font.pixelSize: Theme.fontSizeNormal
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
        
        Button {
            text: "+"
            visible: showAddButton && isLast
            onClicked: delegateRoot.addCondition()
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            
            background: Rectangle {
                radius: Theme.radiusSmall
                color: parent.hovered ? "#E8F5E9" : "#F0F0F0"
                
                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast }
                }
            }
            
            contentItem: Text {
                text: parent.text
                color: parent.hovered ? Theme.success : Theme.textSecondary
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}