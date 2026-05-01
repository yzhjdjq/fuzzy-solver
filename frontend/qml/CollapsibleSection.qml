// frontend/qml/CollapsibleSection.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    
    property string title: ""
    property bool collapsed: false
    
    default property alias content: contentLayout.data
    
    implicitHeight: mainContainer.height
    implicitWidth: parent ? parent.width : 400
    
    Rectangle {
        id: mainContainer
        width: parent.width
        height: collapsed ? 48 : 48 + divider.height + contentLayout.implicitHeight + 24
        radius: 10
        color: "#FAFBFC"
        border.color: "#E8E8E8"
        border.width: 1
        clip: true
        
        Behavior on height {
            NumberAnimation { 
                duration: 250
                easing.type: Easing.InOutQuad
                onRunningChanged: {
                    // Когда анимация завершилась и раздел свернут - скрываем контент
                    if (!running && root.collapsed) {
                        contentContainer.visible = false
                        divider.visible = false
                    }
                }
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // Заголовок
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                
                RowLayout {
                    anchors.fill: parent
                    
                    Text {
                        text: root.title
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#2D3436"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    Button {
                        id: collapseButton
                        text: root.collapsed ? "▼" : "▲"
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        
                        background: Rectangle {
                            radius: 8
                            color: collapseButton.hovered ? "#F0EDFF" : "transparent"
                            
                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                        
                        contentItem: Text {
                            text: collapseButton.text
                            color: "#6C5CE7"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            if (root.collapsed) {
                                // При раскрытии: сначала показываем контент
                                contentContainer.visible = true
                                divider.visible = true
                            }
                            root.collapsed = !root.collapsed
                        }
                    }
                }
            }
            
            // Разделительная линия
            Rectangle {
                id: divider
                Layout.fillWidth: true
                height: collapsed ? 0 : 1
                visible: !collapsed
                color: "#E8E8E8"
            }
            
            // Содержимое
            Item {
                id: contentContainer
                Layout.fillWidth: true
                Layout.preferredHeight: collapsed ? 0 : contentLayout.implicitHeight + 24
                visible: !collapsed
                clip: true
                
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
                
                ColumnLayout {
                    id: contentLayout
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    anchors.topMargin: 12
                    anchors.bottomMargin: 12
                    spacing: 8
                }
            }
        }
    }
}