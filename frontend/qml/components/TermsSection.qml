import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"
import "items"

CollapsibleSection {
    id: root
    
    property var variablesModel: []
    property int focusVarId: -1
    property var collapsedStates: ({})
    property var mfTypeStates: ({})
    property var mfParamsStates: ({})
    
    signal termAdded(int varId, string termName)
    signal termRemoved(int varId, int termIndex)
    signal termChanged(int varId, int termIndex, string termName)
    signal termMfTypeChanged(int varId, int termIndex, string mfType)
    signal termMfParamsChanged(int varId, int termIndex, var params)
    
    Layout.fillWidth: true
    
    title: "📋 Термы лингвистических переменных"
    collapsed: false
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.radiusSmall
        
        Repeater {
            model: root.variablesModel
            delegate: Item {
                id: delegateRoot
                Layout.fillWidth: true
                implicitHeight: varSection.implicitHeight
                
                property int varId: modelData.id
                property var terms: modelData.terms
                
                function addTerm() {
                    if (newTermName.text.length > 0) {
                        root.focusVarId = varId
                        root.termAdded(varId, newTermName.text)
                    }
                }
                
                function getSavedMfType(termIndex, defaultType) {
                    if (root.mfTypeStates[varId] && root.mfTypeStates[varId][termIndex] !== undefined) {
                        return root.mfTypeStates[varId][termIndex]
                    }
                    return defaultType
                }
                
                function getSavedMfParams(termIndex, defaultParams) {
                    if (root.mfParamsStates[varId] && root.mfParamsStates[varId][termIndex] !== undefined) {
                        return root.mfParamsStates[varId][termIndex]
                    }
                    return defaultParams
                }
                
                CollapsibleSection {
                    id: varSection
                    anchors.fill: parent
                    title: modelData.name + " (" + modelData.type + ")"
                    
                    collapsed: {
                        if (root.collapsedStates[delegateRoot.varId] !== undefined) {
                            return root.collapsedStates[delegateRoot.varId]
                        }
                        return false
                    }
                    
                    onCollapsedChanged: {
                        root.collapsedStates[delegateRoot.varId] = collapsed
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        
                        Repeater {
                            model: delegateRoot.terms
                            delegate: TermItem {
                                termIndex: model.index
                                termName: modelData.name
                                mfType: delegateRoot.getSavedMfType(model.index, modelData.mf_type || "trapezoid")
                                mfParams: delegateRoot.getSavedMfParams(model.index, modelData.mf_params || [0.0, 0.25, 0.75, 1.0])
                                Layout.fillWidth: true
                                
                                onTermChanged: (index, name) => {
                                    root.termChanged(delegateRoot.varId, index, name)
                                }
                                onTermRemoved: (index) => {
                                    root.termRemoved(delegateRoot.varId, index)
                                }
                                onTermMfTypeChanged: (index, mfType) => {
                                    if (!root.mfTypeStates[delegateRoot.varId]) {
                                        root.mfTypeStates[delegateRoot.varId] = {}
                                    }
                                    root.mfTypeStates[delegateRoot.varId][index] = mfType
                                    root.termMfTypeChanged(delegateRoot.varId, index, mfType)
                                }
                                onTermMfParamsChanged: (index, params) => {
                                    if (!root.mfParamsStates[delegateRoot.varId]) {
                                        root.mfParamsStates[delegateRoot.varId] = {}
                                    }
                                    root.mfParamsStates[delegateRoot.varId][index] = params.slice()
                                    root.termMfParamsChanged(delegateRoot.varId, index, params)
                                }
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            visible: delegateRoot.terms.length < 10
                            spacing: 6
                            
                            TextField {
                                id: newTermName
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                placeholderText: "Новый терм"
                                font.pixelSize: 13
                                
                                background: Rectangle {
                                    radius: 4
                                    color: Theme.background
                                    border.color: newTermName.activeFocus ? Theme.primary : Theme.border
                                    border.width: newTermName.activeFocus ? 2 : 1
                                }
                                
                                Component.onCompleted: {
                                    if (root.focusVarId === delegateRoot.varId) {
                                        newTermName.focus = true
                                        root.focusVarId = -1
                                    }
                                }
                                
                                Keys.onReturnPressed: {
                                    if (text.length > 0) {
                                        delegateRoot.addTerm()
                                    }
                                }
                                Keys.onEnterPressed: {
                                    if (text.length > 0) {
                                        delegateRoot.addTerm()
                                    }
                                }
                            }
                            
                            Button {
                                id: addTermButton
                                text: "+"
                                enabled: newTermName.text.length > 0
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                
                                background: Rectangle {
                                    radius: 4
                                    color: parent.enabled ? (parent.hovered ? Theme.primaryDark : Theme.primary) : Theme.border
                                    border.color: addTermButton.activeFocus ? Theme.accent : "transparent"
                                    border.width: addTermButton.activeFocus ? 2 : 0
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: Theme.textOnPrimary
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: delegateRoot.addTerm()
                                
                                Keys.onReturnPressed: {
                                    if (enabled) delegateRoot.addTerm()
                                }
                                Keys.onEnterPressed: {
                                    if (enabled) delegateRoot.addTerm()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}