import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../theme"
import "items"

CollapsibleSection {
    id: section
    
    property var accumulatedData: ({})
    property var displayModel: []
    
    onAccumulatedDataChanged: {
        var data = []
        var keys = Object.keys(accumulatedData)
        for (var i = 0; i < keys.length; i++) {
            data.push({
                "variable_id": keys[i],
                "variable_name": accumulatedData[keys[i]].variable_name,
                "accumulated": accumulatedData[keys[i]].accumulated
            })
        }
        displayModel = data
    }
    
    Layout.fillWidth: true
    
    title: "📊 Аккумулированное заключение по правилам"
    collapsed: true
    
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.radiusMedium
        
        Repeater {
            model: section.displayModel
            delegate: CollapsibleSection {
                Layout.fillWidth: true
                title: modelData.variable_name + " (аккумуляция)"
                collapsed: false
                
                AccumulatedGraph {
                    variableName: modelData.variable_name
                    activatedTerms: modelData.accumulated.activated_terms || []
                    maxPoints: modelData.accumulated.max_points || []
                    graphHeight: 250
                    Layout.fillWidth: true
                }
            }
        }
        
        Text {
            text: "Нажмите «Выполнить расчет» для построения аккумулированных графиков"
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textSecondary
            Layout.alignment: Qt.AlignHCenter
            visible: section.displayModel.length === 0
        }
    }
}