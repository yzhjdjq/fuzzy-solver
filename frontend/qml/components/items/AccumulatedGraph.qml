import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../theme"

Item {
    id: root
    
    property string variableName: ""
    property var activatedTerms: []
    property var maxPoints: []
    property int graphHeight: 200
    
    implicitHeight: graphHeight + 60
    implicitWidth: parent ? parent.width : 400
    
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
    }
    
    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.margins: 10
        
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
            var ctx = getContext("2d");
            var margin = { top: 10, right: 10, bottom: 30, left: 130 };
            var w = width - margin.left - margin.right;
            var h = height - margin.top - margin.bottom;
            var ox = margin.left;
            var oy = margin.top;
            
            ctx.clearRect(0, 0, width, height);
            
            // Находим диапазон X
            var allX = [];
            for (var i = 0; i < root.maxPoints.length; i++) {
                allX.push(root.maxPoints[i].x);
            }
            
            if (allX.length === 0) return;
            
            var minX = Math.min.apply(null, allX);
            var maxX = Math.max.apply(null, allX);
            var rangeX = maxX - minX || 1;
            
            function toX(val) { return ox + ((val - minX) / rangeX) * w; }
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
                var val = minX + (rangeX / gridSteps) * gx;
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
            
            // Рисуем активированные термы
            for (var t = 0; t < root.activatedTerms.length; t++) {
                var term = root.activatedTerms[t];
                var points = term.points || [];
                
                if (points.length < 2) continue;
                
                ctx.fillStyle = getColor(t, 0.15);
                ctx.strokeStyle = getColor(t, 0.5);
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.moveTo(toX(points[0].x), toY(points[0].y));
                
                for (var p = 1; p < points.length; p++) {
                    ctx.lineTo(toX(points[p].x), toY(points[p].y));
                }
                
                ctx.stroke();
                ctx.fill();
            }
            
            // Рисуем результирующую функцию (max)
            if (root.maxPoints.length > 1) {
                ctx.strokeStyle = "#FF0000";
                ctx.lineWidth = 2.5;
                ctx.beginPath();
                ctx.moveTo(toX(root.maxPoints[0].x), toY(root.maxPoints[0].y));
                
                for (var mp = 1; mp < root.maxPoints.length; mp++) {
                    ctx.lineTo(toX(root.maxPoints[mp].x), toY(root.maxPoints[mp].y));
                }
                
                ctx.stroke();
            }
            
            // Легенда
            var legendX = -4;
            var legendY = oy + 5;
            
            for (var lt = 0; lt < root.activatedTerms.length; lt++) {
                var ly = legendY + 9 + lt * 36;
                
                ctx.fillStyle = getColor(lt, 1.0);
                ctx.fillRect(legendX + 4, ly - 4, 12, 12);
                
                ctx.fillStyle = Theme.textPrimary;
                ctx.font = "14px sans-serif";
                var legendText = root.activatedTerms[lt].term_name || "t" + (lt + 1);
                ctx.textBaseline="bottom";
                ctx.fillText(legendText, legendX + 20, ly + 5);
                ctx.textBaseline="top"
                ctx.fillText("(μ=" + root.activatedTerms[lt].degree.toFixed(2) + ")", legendX + 20, ly + 5)
            }

            var redY = legendY + 9 + root.activatedTerms.length * 36;
            ctx.strokeStyle = "#FF0000";
            ctx.lineWidth = 2.5;
            ctx.beginPath();
            ctx.moveTo(legendX + 4, redY);
            ctx.lineTo(legendX + 16, redY);
            ctx.stroke();
            
            ctx.fillStyle = Theme.textPrimary;
            ctx.textBaseline="alphabetic";
            ctx.fillText("Результ.", legendX + 20, redY + 5);
        }
    }
}