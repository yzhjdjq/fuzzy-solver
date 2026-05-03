import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"
import "items"

CollapsibleSection {
    id: root
    
    property var inputVariablesModel: []
    property string defuzzMethod: "bos"
    
    property var pendingValues: ({})
    property var selectedInputValues: ({})
    property var selectedVarIds: []
    
    signal inputValueChanged(int varId, double value)
    signal inputVariableRemoved(int varId)
    signal inputVariableAdded(int varId)
    signal defuzzMethodSelected(string method)
    
    Layout.fillWidth: true
    
    title: "⚙ Условия решения"
    collapsed: false

    function getParamsExtremum(varId, extremumFunc, defaultValue) {
        for (var i = 0; i < root.inputVariablesModel.length; i++) {
            if (root.inputVariablesModel[i].id === varId) {
                var terms = root.inputVariablesModel[i].terms || []
                var allParams = []
                for (var j = 0; j < terms.length; j++) {
                    var params = terms[j].mf_params || []
                    allParams = allParams.concat(params)
                }
                if (allParams.length > 0) {
                    return extremumFunc.apply(null, allParams)
                }
            }
        }
        return defaultValue
    }
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.radiusSmall
        
        Text {
            text: "Входные значения:"
            font.pixelSize: Theme.fontSizeNormal
            font.weight: Font.Bold
            color: Theme.textPrimary
        }
        
        Repeater {
            model: root.selectedVarIds
            delegate: InputValueItem {
                varId: modelData
                varName: {
                    for (var i = 0; i < root.inputVariablesModel.length; i++) {
                        if (root.inputVariablesModel[i].id === modelData) {
                            return root.inputVariablesModel[i].name
                        }
                    }
                    return "Переменная " + modelData
                }
                value: {
                    if (root.pendingValues[modelData] !== undefined) {
                        return root.pendingValues[modelData]
                    }
                    return root.selectedInputValues[modelData] !== undefined ? root.selectedInputValues[modelData] : 0.0
                }
                minVal: root.getParamsExtremum(modelData, Math.min, 0.0)
                maxVal: root.getParamsExtremum(modelData, Math.max, 1.0)
                Layout.fillWidth: true
                
                onInputValueChanged: (varId, value) => {
                    root.selectedInputValues[varId] = value
                    root.pendingValues[varId] = value
                    root.inputValueChanged(varId, value)
                }
                onRemoveRequested: (varId) => {
                    var removedId = varId
                    
                    var newIds = []
                    for (var j = 0; j < root.selectedVarIds.length; j++) {
                        if (root.selectedVarIds[j] !== removedId) {
                            newIds.push(root.selectedVarIds[j])
                        }
                    }
                    
                    delete root.selectedInputValues[removedId]
                    delete root.pendingValues[removedId]

                    root.inputVariableRemoved(removedId)
                    root.selectedVarIds = newIds
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            ComboBox {
                id: inputVarCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                implicitHeight: 36
                
                textRole: "name"
                
                model: {
                    var availableVars = []
                    for (var i = 0; i < root.inputVariablesModel.length; i++) {
                        var v = root.inputVariablesModel[i]
                        if (root.selectedVarIds.indexOf(v.id) === -1) {
                            availableVars.push(v)
                        }
                    }
                    return availableVars
                }
                
                background: Rectangle {
                    radius: 6
                    color: parent.hovered ? "#F5F5F5" : Theme.surface
                    border.color: inputVarCombo.activeFocus ? Theme.primary : Theme.border
                    border.width: inputVarCombo.activeFocus ? 2 : 1
                }
                
                contentItem: Text {
                    text: parent.displayText || "Выберите переменную..."
                    color: parent.displayText ? Theme.textPrimary : Theme.textSecondary
                    font.pixelSize: Theme.fontSizeNormal
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                }
            }
            
            Button {
                text: "Добавить"
                enabled: inputVarCombo.currentIndex >= 0 && inputVarCombo.model.length > 0
                Layout.preferredHeight: 36
                
                topPadding: 8; bottomPadding: 8
                leftPadding: 16; rightPadding: 16
                
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: parent.enabled ? (parent.hovered ? Theme.primaryDark : Theme.primary) : Theme.border
                }
                
                contentItem: Text {
                    text: parent.text
                    color: Theme.textOnPrimary
                    font.pixelSize: Theme.fontSizeNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    if (inputVarCombo.currentIndex >= 0 && inputVarCombo.model.length > 0) {
                        var selectedVar = inputVarCombo.model[inputVarCombo.currentIndex]
                        var varId = selectedVar.id
                        
                        root.selectedInputValues[varId] = 0.0
                        root.pendingValues[varId] = 0.0
                        
                        var newIds = root.selectedVarIds.slice()
                        newIds.push(varId)
                        root.selectedVarIds = newIds
                        
                        root.inputVariableAdded(varId)
                        root.inputValueChanged(varId, 0.0)
                        
                        inputVarCombo.currentIndex = -1
                    }
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
            Layout.topMargin: 5
            Layout.bottomMargin: 5
        }
        
        Text {
            text: "Метод дефаззификации:"
            font.pixelSize: Theme.fontSizeNormal
            font.weight: Font.Bold
            color: Theme.textPrimary
        }
        
        ComboBox {
            id: defuzzCombo
            model: [
                { text: "Биссектриса площади (BoS)", value: "bos" },
                { text: "Центр тяжести (Centroid)", value: "centroid" },
                { text: "Левая мода (LoM)", value: "lom" },
                { text: "Правая мода (RoM)", value: "rom" }
            ]
            textRole: "text"
            
            currentIndex: {
                for (var i = 0; i < model.length; i++) {
                    if (model[i].value === root.defuzzMethod) return i
                }
                return 0
            }
            
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            implicitHeight: 36
            
            background: Rectangle {
                radius: 6
                color: parent.hovered ? "#F5F5F5" : Theme.surface
                border.color: defuzzCombo.activeFocus ? Theme.primary : Theme.border
                border.width: defuzzCombo.activeFocus ? 2 : 1
            }
            
            contentItem: Text {
                text: parent.displayText
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeNormal
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
            }
            
            onActivated: {
                root.defuzzMethod = model[currentIndex].value
                root.defuzzMethodSelected(model[currentIndex].value)
            }
        }
    }
}