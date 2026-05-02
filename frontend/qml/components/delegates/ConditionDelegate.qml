import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

Item {
    id: delegateRoot
    
    property int conditionIndex: 0
    property string groupType: ""
    property var variablesModel: []
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
    
    // Получаем список термов для выбранной переменной
    property var currentTerms: {
        for (var i = 0; i < variablesModel.length; i++) {
            if (variablesModel[i].id === currentVariableId) {
                return variablesModel[i].terms || []
            }
        }
        return []
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 8
        
        // Комбобокс переменной
        ComboBox {
            id: variableCombo
            model: variablesModel
            textRole: "name"
            valueRole: "id"
            
            currentIndex: {
                for (var i = 0; i < variablesModel.length; i++) {
                    if (variablesModel[i].id === currentVariableId) return i
                }
                return variablesModel.length > 0 ? 0 : -1
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
                    // При смене переменной выбираем первый терм
                    var terms = variablesModel[currentIndex].terms || []
                    var term = terms.length > 0 ? terms[0] : ""
                    delegateRoot.variableChanged(-1, groupType, conditionIndex, varId, term)
                }
            }
        }
        
        // Комбобокс терма
        ComboBox {
            id: termCombo
            model: delegateRoot.currentTerms
            textRole: "name"
            
            currentIndex: {
                var terms = delegateRoot.currentTerms
                for (var i = 0; i < terms.length; i++) {
                    if (terms[i].name === currentTerm) return i
                }
                return terms.length > 0 ? 0 : -1
            }
            
            Layout.fillWidth: true
            Layout.minimumWidth: 80
            Layout.preferredHeight: 36
            implicitHeight: 36
            visible: delegateRoot.currentTerms.length > 0
            
            background: Rectangle {
                radius: 6
                color: parent.hovered ? "#F5F5F5" : Theme.surface
                border.color: termCombo.activeFocus ? Theme.primary : Theme.border
                border.width: termCombo.activeFocus ? 2 : 1
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
            
            onCurrentTextChanged: {
                if (currentText !== currentTerm && currentText !== "") {
                    // При смене терма обновляем условие
                    var varId = variableCombo.currentIndex >= 0 && variablesModel[variableCombo.currentIndex] 
                        ? variablesModel[variableCombo.currentIndex].id 
                        : currentVariableId
                    delegateRoot.variableChanged(-1, groupType, conditionIndex, varId, currentText)
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