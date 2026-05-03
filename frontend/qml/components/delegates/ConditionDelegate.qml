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
    property bool showOperator: true
    
    property var currentTerms: []

    signal variableChanged(int ruleId, string group, int index, int variableId, string term)
    signal operatorChanged(int ruleId, string group, int index, string operator)
    signal remove()
    signal addCondition()
    
    implicitHeight: 36
    implicitWidth: 200
    
    function updateTerms() {
        var terms = []
        for (var i = 0; i < variablesModel.length; i++) {
            if (variablesModel[i].id === currentVariableId) {
                terms = variablesModel[i].terms || []
                break
            }
        }
        currentTerms = terms
        
        var termIndex = -1
        for (var j = 0; j < terms.length; j++) {
            if (terms[j].name === currentTerm) {
                termIndex = j
                break
            }
        }
        if (termIndex >= 0) {
            termCombo.currentIndex = termIndex
        } else if (terms.length > 0) {
            termCombo.currentIndex = 0
        }
    }
    
    function findVariableIndex() {
        for (var i = 0; i < variablesModel.length; i++) {
            if (variablesModel[i].id === currentVariableId) return i
        }
        return variablesModel.length > 0 ? 0 : -1
    }
    
    onVariablesModelChanged: updateTerms()
    onCurrentVariableIdChanged: updateTerms()
    onCurrentTermChanged: updateTerms()
    
    Component.onCompleted: updateTerms()
    
    RowLayout {
        anchors.fill: parent
        spacing: 8
        
        ComboBox {
            id: variableCombo
            model: variablesModel
            textRole: "name"
            valueRole: "id"
            
            currentIndex: findVariableIndex()
            
            Layout.fillWidth: true
            Layout.minimumWidth: 120
            Layout.preferredHeight: 36
            implicitHeight: 36
            
            background: Rectangle {
                radius: 6
                color: parent.hovered ? "#F5F5F5" : Theme.surface
                border.color: variableCombo.activeFocus ? Theme.primary : Theme.border
                border.width: variableCombo.activeFocus ? 2 : 1
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
            
            onActivated: {
                if (currentIndex >= 0 && variablesModel[currentIndex]) {
                    var varId = variablesModel[currentIndex].id
                    var terms = variablesModel[currentIndex].terms || []
                    var term = terms.length > 0 ? terms[0].name : ""
                    delegateRoot.variableChanged(-1, groupType, conditionIndex, varId, term)
                }
            }
        }
        
        ComboBox {
            id: termCombo
            model: currentTerms
            textRole: "name"
            
            Layout.fillWidth: true
            Layout.minimumWidth: 80
            Layout.preferredHeight: 36
            implicitHeight: 36
            visible: currentTerms.length > 0
            
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
            
            onActivated: {
                var varId = variableCombo.currentIndex >= 0 && variablesModel[variableCombo.currentIndex] 
                    ? variablesModel[variableCombo.currentIndex].id 
                    : currentVariableId
                delegateRoot.variableChanged(-1, groupType, conditionIndex, varId, currentText)
            }
        }
        
        ComboBox {
            id: operatorCombo
            model: ["и", "или"]
            currentIndex: currentOperator === "или" ? 1 : 0
            visible: showOperator && !isLast
            Layout.preferredWidth: 70
            Layout.minimumWidth: 60
            Layout.preferredHeight: 36
            implicitHeight: 36
            
            background: Rectangle {
                radius: 6
                color: parent.hovered ? "#F0EDFF" : Theme.surface
                border.color: operatorCombo.activeFocus ? Theme.primary : Theme.border
                border.width: operatorCombo.activeFocus ? 2 : 1
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
            
            onActivated: {
                delegateRoot.operatorChanged(-1, groupType, conditionIndex, currentText)
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
                border.color: parent.activeFocus ? Theme.primary : "transparent"
                border.width: parent.activeFocus ? 2 : 0
                
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
                border.color: parent.activeFocus ? Theme.primary : "transparent"
                border.width: parent.activeFocus ? 2 : 0
                
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