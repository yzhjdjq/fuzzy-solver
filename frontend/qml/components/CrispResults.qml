import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import "../theme"

CollapsibleSection {
    id: section
    
    property var crispData: []
    property var displayModel: []
    
    onCrispDataChanged: {
        displayModel = crispData
    }
    
    Layout.fillWidth: true
    
    title: "✅ Ответ"
    collapsed: false
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.radiusSmall
        
        Repeater {
            model: section.displayModel
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: Theme.radiusMedium
                color: Theme.surface
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#000000"
                    shadowOpacity: 0.06
                    shadowBlur: 10
                    shadowVerticalOffset: 2
                }
                
                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 16
                    spacing: 12
                    
                    // Индикатор выходной переменной
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 12
                        color: "#E8FFE8"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "↑"
                            font.pixelSize: 16
                            color: Theme.success
                        }
                    }
                    
                    // Название переменной
                    Text {
                        text: modelData.variable_name
                        font.pixelSize: Theme.fontSizeNormal
                        font.weight: Font.Bold
                        color: Theme.textPrimary
                        Layout.preferredWidth: 120
                        elide: Text.ElideRight
                    }
                    
                    // Стрелка
                    Text {
                        text: "→"
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.textSecondary
                    }
                    
                    // Чёткое значение
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 32
                        radius: 8
                        color: "#F0EDFF"
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.crisp_value.toFixed(3)
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Bold
                            color: Theme.primary
                        }
                    }
                    
                    // Стрелка к терму
                    Text {
                        text: "∈"
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }
                    
                    // Терм
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        radius: 8
                        color: "#FFF3E0"
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.best_term
                            font.pixelSize: Theme.fontSizeNormal
                            font.weight: Font.Bold
                            color: "#E65100"
                        }
                    }
                }
            }
        }
        
        Text {
            text: "Нажмите «Выполнить расчет» для получения результата"
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textSecondary
            Layout.alignment: Qt.AlignHCenter
            visible: section.displayModel.length === 0
            Layout.topMargin: 10
        }
    }
}