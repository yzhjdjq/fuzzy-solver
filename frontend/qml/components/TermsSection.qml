import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"
import "items"

CollapsibleSection {
    id: root
    
    property var variablesModel: []
    
    signal termAdded(int varId, string termName)
    signal termRemoved(int varId, int termIndex)
    signal termChanged(int varId, int termIndex, string termName)
    
    Layout.fillWidth: true
    
    title: "📋 Термы лингвистических переменных"
    collapsed: false
    
    property int focusVarId: -1
    property var collapsedStates: ({})
    
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
                
                CollapsibleSection {
                    id: varSection
                    anchors.fill: parent
                    title: modelData.name + " (" + modelData.type + ")"
                    
                    // Восстанавливаем состояние из хранилища или используем false по умолчанию
                    collapsed: {
                        if (root.collapsedStates[delegateRoot.varId] !== undefined) {
                            return root.collapsedStates[delegateRoot.varId]
                        }
                        return false
                    }
                    
                    // Сохраняем состояние при изменении
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
                                Layout.fillWidth: true
                                
                                onTermChanged: (index, name) => {
                                    root.termChanged(delegateRoot.varId, index, name)
                                }
                                onTermRemoved: (index) => {
                                    root.termRemoved(delegateRoot.varId, index)
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