import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

Item {
    id: root
    
    property var terms: []
    property int graphHeight: 200
    property bool forceRedraw: false

    signal graphDrawn()
    
    implicitHeight: graphHeight + 20
    implicitWidth: parent ? parent.width : 400
    
    Canvas {
        id: graphCanvas
        anchors.fill: parent
        
        property var colors: [
            { r: 108, g: 92, b: 231 },
            { r: 0, g: 184, b: 148 },
            { r: 255, g: 118, b: 117 },
            { r: 253, g: 203, b: 110 },
            { r: 9, g: 132, b: 227 },
            { r: 225, g: 112, b: 85 },
            { r: 162, g: 155, b: 254 },
            { r: 85, g: 239, b: 196 },
            { r: 214, g: 48, b: 49 },
            { r: 116, g: 185, b: 255 }
        ]
        
        function getColor(index, alpha) {
            var c = colors[index % colors.length];
            return "rgba(" + c.r + "," + c.g + "," + c.b + "," + alpha + ")";
        }
        
        onPaint: {
            if (root.terms.length === 0) return;
            
            var ctx = getContext("2d");
            var margin = { top: 10, right: 10, bottom: 30, left: 130 };
            var w = width - margin.left - margin.right;
            var h = height - margin.top - margin.bottom;
            var ox = margin.left;
            var oy = margin.top;
            
            ctx.clearRect(0, 0, width, height);
            
            var allParams = [];
            for (var i = 0; i < root.terms.length; i++) {
                var params = root.terms[i].mf_params || [];
                allParams = allParams.concat(params);
            }
            
            if (allParams.length === 0) return;
            
            var minVal = Math.min.apply(null, allParams);
            var maxVal = Math.max.apply(null, allParams);
            var range = maxVal - minVal;
            if (range === 0) range = 1;
            
            function toX(val) { return ox + ((val - minVal) / range) * w; }
            function toY(val) { return oy + h - val * h; }
            
            // Сетка
            ctx.strokeStyle = "#E8E8E8";
            ctx.lineWidth = 0.5;
            
            for (var gy = 0; gy <= 1; gy += 0.25) {
                ctx.beginPath();
                ctx.moveTo(ox, toY(gy));
                ctx.lineTo(ox + w, toY(gy));
                ctx.stroke();
                
                ctx.fillStyle = Theme.textSecondary;
                ctx.font = "10px sans-serif";
                ctx.fillText(gy.toFixed(2), ox - 30, toY(gy) + 4);
            }
            
            var gridSteps = 5;
            for (var gx = 0; gx <= gridSteps; gx++) {
                var val = minVal + (range / gridSteps) * gx;
                ctx.beginPath();
                ctx.moveTo(toX(val), oy);
                ctx.lineTo(toX(val), oy + h);
                ctx.stroke();
                
                ctx.fillText(val.toFixed(1), toX(val) - 15, oy + h + 18);
            }
            
            // Оси
            ctx.strokeStyle = "#B0B0B0";
            ctx.lineWidth = 1.5;
            
            ctx.beginPath();
            ctx.moveTo(ox, oy);
            ctx.lineTo(ox, oy + h);
            ctx.stroke();
            
            ctx.beginPath();
            ctx.moveTo(ox, oy + h);
            ctx.lineTo(ox + w, oy + h);
            ctx.stroke();
            
            // Функции принадлежности
            for (var t = 0; t < root.terms.length; t++) {
                var term = root.terms[t];
                var params = term.mf_params || [];
                var mfType = term.mf_type || "trapezoid";
                
                if (params.length < 2) continue;
                
                ctx.fillStyle = getColor(t, 0.15);
                ctx.strokeStyle = getColor(t, 1.0);
                ctx.lineWidth = 2;
                ctx.beginPath();
                
                if (mfType === "triangle" && params.length >= 3) {
                    ctx.moveTo(toX(params[0]), oy + h);
                    ctx.lineTo(toX(params[1]), oy);
                    ctx.lineTo(toX(params[2]), oy + h);
                } else if (mfType === "trapezoid" && params.length >= 4) {
                    ctx.moveTo(toX(params[0]), oy + h);
                    ctx.lineTo(toX(params[1]), oy);
                    ctx.lineTo(toX(params[2]), oy);
                    ctx.lineTo(toX(params[3]), oy + h);
                } else if (mfType === "gaussian") {
                    var mean = params[0];
                    var sigma = params[1] * range / 3;
                    
                    ctx.moveTo(toX(minVal), oy + h);
                    for (var x = 0; x <= w; x++) {
                        var val = minVal + (x / w) * range;
                        var y = oy + h - Math.exp(-Math.pow((val - mean) / sigma, 2) / 2) * h;
                        ctx.lineTo(ox + x, y);
                    }
                    ctx.lineTo(toX(maxVal), oy + h);
                }
                
                ctx.closePath();
                ctx.fill();
                ctx.stroke();
            }
            
            // Легенда
            var legendX = -4;
            var legendY = oy + 5;
            
            for (var lt = 0; lt < root.terms.length; lt++) {
                var ly = legendY + 9 + lt * 18;
                
                ctx.fillStyle = getColor(lt, 1.0);
                ctx.fillRect(legendX + 4, ly - 4, 12, 12);
                
                ctx.fillStyle = Theme.textPrimary;
                ctx.font = "14px sans-serif";
                var legendText = root.terms[lt].name || "t" + (lt + 1);
                if (legendText.length > 10) legendText = legendText.substring(0, 10) + ".";
                ctx.fillText(legendText, legendX + 20, ly + 5);
            }
            
            Qt.callLater(function() {
                root.graphDrawn()
            })
        }
        
        Connections {
            target: root
            function onForceRedrawChanged() {
                if (root.forceRedraw) {
                    graphCanvas.requestPaint()
                }
            }
        }
    }
}