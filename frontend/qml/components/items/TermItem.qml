import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

Item {
    id: root
    
    property int termIndex: 0
    property string termName: ""
    property string mfType: "trapezoid"
    property var mfParams: [0.0, 0.25, 0.75, 1.0]
    property string localMfType: mfType
    property var localMfParams: mfParams.slice()
    
    signal termChanged(int index, string name)
    signal termRemoved(int index)
    signal termMfTypeChanged(int index, string mfType)
    signal termMfParamsChanged(int index, var params)
    
    implicitHeight: 86
    implicitWidth: parent ? parent.width : 200
    
    onMfTypeChanged: localMfType = mfType
    onMfParamsChanged: {
        localMfParams = mfParams.slice()
        updateParamFields()
    }
    
    function updateParamFields() {
        param1.text = localMfParams[0] !== undefined ? localMfParams[0].toFixed(2) : "0.00"
        param2.text = localMfParams[1] !== undefined ? localMfParams[1].toFixed(2) : "0.25"
        param3.text = localMfParams[2] !== undefined ? localMfParams[2].toFixed(2) : "0.75"
        param4.text = localMfParams[3] !== undefined ? localMfParams[3].toFixed(2) : "1.00"
    }
    
    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Theme.background
        border.color: Theme.border
        border.width: 1
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            
            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: "#F0EDFF"
                
                Text {
                    anchors.centerIn: parent
                    text: (termIndex + 1).toString()
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: Theme.primary
                }
            }
            
            TextField {
                id: termField
                text: termName
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                font.pixelSize: Theme.fontSizeNormal
                
                background: Rectangle {
                    radius: 4
                    color: Theme.surface
                    border.color: termField.activeFocus ? Theme.primary : Theme.border
                    border.width: termField.activeFocus ? 2 : 1
                }
                
                onEditingFinished: {
                    if (text !== termName) {
                        root.termChanged(termIndex, text)
                    }
                }
                
                Keys.onReturnPressed: focus = false
                Keys.onEnterPressed: focus = false
            }
            
            ComboBox {
                id: mfTypeCombo
                model: ["Трапециевидная", "Треугольная", "Гауссова"]
                currentIndex: {
                    switch(root.localMfType) {
                        case "triangle": return 1
                        case "gaussian": return 2
                        default: return 0
                    }
                }
                Layout.preferredWidth: 130
                Layout.preferredHeight: 32
                implicitHeight: 32
                
                background: Rectangle {
                    radius: 4
                    color: parent.hovered ? "#F5F5F5" : Theme.surface
                    border.color: mfTypeCombo.activeFocus ? Theme.primary : Theme.border
                    border.width: mfTypeCombo.activeFocus ? 2 : 1
                }
                
                contentItem: Text {
                    text: parent.displayText
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSizeNormal
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                    elide: Text.ElideRight
                    clip: true
                }
                
                onActivated: {
                    var types = ["trapezoid", "triangle", "gaussian"]
                    var newType = types[currentIndex]
                    root.localMfType = newType
                    root.termMfTypeChanged(termIndex, newType)
                    mfCanvas.requestPaint()
                }
            }
            
            Button {
                text: "✕"
                onClicked: root.termRemoved(termIndex)
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                
                background: Rectangle {
                    radius: 4
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
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Параметры:"
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.textSecondary
                    Layout.alignment: Qt.AlignVCenter
                }
                
                TextField {
                    id: param1
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    font.pixelSize: Theme.fontSizeNormal
                    horizontalAlignment: Text.AlignHCenter
                    
                    background: Rectangle {
                        radius: 3
                        color: Theme.surface
                        border.color: param1.activeFocus ? Theme.primary : Theme.border
                        border.width: param1.activeFocus ? 2 : 1
                    }
                    
                    onEditingFinished: root.saveParams()
                    Component.onCompleted: text = root.localMfParams[0]?.toFixed(2) || "0.00"
                }
                
                TextField {
                    id: param2
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    font.pixelSize: Theme.fontSizeNormal
                    horizontalAlignment: Text.AlignHCenter
                    
                    background: Rectangle {
                        radius: 3
                        color: Theme.surface
                        border.color: param2.activeFocus ? Theme.primary : Theme.border
                        border.width: param2.activeFocus ? 2 : 1
                    }
                    
                    onEditingFinished: root.saveParams()
                    Component.onCompleted: text = root.localMfParams[1]?.toFixed(2) || "0.25"
                }
                
                TextField {
                    id: param3
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    font.pixelSize: Theme.fontSizeNormal
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.localMfType !== "gaussian"
                    
                    background: Rectangle {
                        radius: 3
                        color: Theme.surface
                        border.color: param3.activeFocus ? Theme.primary : Theme.border
                        border.width: param3.activeFocus ? 2 : 1
                    }
                    
                    onEditingFinished: root.saveParams()
                    Component.onCompleted: text = root.localMfParams[2]?.toFixed(2) || "0.75"
                }
                
                TextField {
                    id: param4
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    font.pixelSize: Theme.fontSizeNormal
                    horizontalAlignment: Text.AlignHCenter
                    visible: root.localMfType === "trapezoid"
                    
                    background: Rectangle {
                        radius: 3
                        color: Theme.surface
                        border.color: param4.activeFocus ? Theme.primary : Theme.border
                        border.width: param4.activeFocus ? 2 : 1
                    }
                    
                    onEditingFinished: root.saveParams()
                    Component.onCompleted: text = root.localMfParams[3]?.toFixed(2) || "1.00"
                }
            }
            
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 32
                radius: 4
                color: Theme.surface
                border.color: Theme.border
                border.width: 1
                
                Canvas {
                    id: mfCanvas
                    anchors.fill: parent
                    anchors.margins: 4
                    
                    function getBounds() {
                        var params = root.localMfParams;
                        var min = Math.min.apply(null, params);
                        var max = Math.max.apply(null, params);
                        
                        var range = max - min;
                        if (range === 0) range = 0.1;
                        return {
                            min: min - range * 0.1,
                            max: max + range * 0.1,
                            range: range * 1.2
                        }
                    }
                    
                    function toX(val) {
                        var bounds = getBounds();
                        return ((val - bounds.min) / bounds.range) * width;
                    }
                    
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        
                        var params = root.localMfParams;
                        if (params.length < 2) return;
                        
                        ctx.strokeStyle = Theme.primary;
                        ctx.lineWidth = 2;
                        ctx.beginPath();
                        
                        if (root.localMfType === "triangle") {
                            var ax = toX(params[0]);
                            var bx = toX(params[1]);
                            var cx = toX(params[2]);
                            
                            ctx.moveTo(ax, height);
                            ctx.lineTo(bx, 0);
                            ctx.lineTo(cx, height);
                        } else if (root.localMfType === "trapezoid") {
                            var ax = toX(params[0]);
                            var bx = toX(params[1]);
                            var cx = toX(params[2]);
                            var dx = toX(params[3]);
                            
                            ctx.moveTo(ax, height);
                            ctx.lineTo(bx, 0);
                            ctx.lineTo(cx, 0);
                            ctx.lineTo(dx, height);
                        } else {
                            // Gaussian
                            var mean = params[0];
                            var sigma = params[1];
                            var bounds = getBounds();
                            
                            ctx.moveTo(0, height);
                            for (var x = 0; x <= width; x++) {
                                var val = bounds.min + (x / width) * bounds.range;
                                var y = height - Math.exp(-Math.pow((val - mean) / (sigma * 0.5), 2) / 2) * height;
                                ctx.lineTo(x, y);
                            }
                            ctx.lineTo(width, height);
                        }
                        
                        ctx.closePath();
                        ctx.fillStyle = Theme.primaryLight + "40";
                        ctx.fill();
                        ctx.stroke();
                    }
                    
                    onVisibleChanged: if (visible) requestPaint()
                    Component.onCompleted: requestPaint()
                }
            }
        }
    }
    
    function saveParams() {
        var params = [];
        params.push(parseFloat(param1.text) || 0.0);
        params.push(parseFloat(param2.text) || 0.0);
        
        if (root.localMfType !== "gaussian") {
            params.push(parseFloat(param3.text) || 0.0);
        }
        
        if (root.localMfType === "trapezoid") {
            params.push(parseFloat(param4.text) || 0.0);
        }
        
        root.localMfParams = params;
        root.termMfParamsChanged(termIndex, params);
        mfCanvas.requestPaint();
    }
    
    Component.onCompleted: updateParamFields()
}