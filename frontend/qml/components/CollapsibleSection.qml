import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"

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
        radius: Theme.radiusMedium
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        clip: true
        
        Behavior on height {
            NumberAnimation { 
                duration: Theme.animationNormal
                easing.type: Easing.InOutQuad
                onRunningChanged: {
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
            
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Layout.leftMargin: Theme.radiusMedium
                Layout.rightMargin: Theme.radiusMedium
                
                RowLayout {
                    anchors.fill: parent
                    
                    Text {
                        text: root.title
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Bold
                        color: Theme.textPrimary
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    Button {
                        id: collapseButton
                        text: root.collapsed ? "▼" : "▲"
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        
                        background: Rectangle {
                            radius: Theme.radiusSmall
                            color: collapseButton.hovered ? "#F0EDFF" : "transparent"
                            
                            Behavior on color {
                                ColorAnimation { duration: Theme.animationFast }
                            }
                        }
                        
                        contentItem: Text {
                            text: collapseButton.text
                            color: Theme.primary
                            font.pixelSize: Theme.fontSizeNormal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            if (root.collapsed) {
                                contentContainer.visible = true
                                divider.visible = true
                            }
                            root.collapsed = !root.collapsed
                        }
                    }
                }
            }
            
            Rectangle {
                id: divider
                Layout.fillWidth: true
                height: collapsed ? 0 : 1
                visible: !collapsed
                color: Theme.border
            }
            
            Item {
                id: contentContainer
                Layout.fillWidth: true
                Layout.preferredHeight: collapsed ? 0 : contentLayout.implicitHeight + 24
                visible: !collapsed
                clip: true
                
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.InOutQuad }
                }
                
                ColumnLayout {
                    id: contentLayout
                    anchors.fill: parent
                    anchors.leftMargin: Theme.radiusMedium
                    anchors.rightMargin: Theme.radiusMedium
                    anchors.topMargin: Theme.radiusMedium
                    anchors.bottomMargin: Theme.radiusMedium
                    spacing: Theme.radiusSmall
                }
            }
        }
    }
}