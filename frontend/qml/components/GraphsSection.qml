import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import "../theme"
import "items"

CollapsibleSection {
    id: section
    
    property var variablesModel: []
    property bool graphsGenerated: false
    property var displayModel: []
    
    onGraphsGeneratedChanged: {
        if (graphsGenerated) {
            displayModel = variablesModel
            Qt.callLater(function() {
                section.graphsGenerated = false
            })
        }
    }
    
    Layout.fillWidth: true
    
    title: "📈 Графики лингвистических переменных"
    collapsed: true
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.radiusMedium
        
        Repeater {
            model: section.displayModel
            delegate: CollapsibleSection {
                Layout.fillWidth: true
                title: modelData.name + " (" + modelData.type + ")"
                collapsed: true
                
                MembershipGraph {
                    terms: modelData.terms
                    graphHeight: 250
                    Layout.fillWidth: true
                }
            }
        }
        
        Text {
            text: "Нажмите «Выполнить расчет» для построения графиков"
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textSecondary
            Layout.alignment: Qt.AlignHCenter
            visible: section.displayModel.length === 0
        }
    }
}