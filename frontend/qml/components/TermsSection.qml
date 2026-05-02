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
    
    // Сохраняем ID переменной, чьё поле ввода должно получить фокус
    property int focusVarId: -1
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.radiusSmall
        
        Repeater {
            model: root.variablesModel
            delegate: CollapsibleSection {
                Layout.fillWidth: true
                title: modelData.name + " (" + modelData.type + ")"
                collapsed: false
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    // Список термов
                    Repeater {
                        model: modelData.terms
                        delegate: TermItem {
                            termIndex: model.index
                            termName: modelData.name
                            Layout.fillWidth: true
                            
                            onTermChanged: (index, name) => {
                                root.termChanged(modelData.id, index, name)
                            }
                            onTermRemoved: (index) => {
                                root.termRemoved(modelData.id, index)
                            }
                        }
                    }
                    
                    // Добавление нового терма
                    RowLayout {
                        Layout.fillWidth: true
                        visible: modelData.terms.length < 10
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
                            
                            onClicked: {
                                root.termAdded(modelData.id, newTermName.text)
                                newTermName.text = ""
                            }
                            
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