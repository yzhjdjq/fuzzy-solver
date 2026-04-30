pragma Singleton
import QtQuick 2.15

QtObject {
    // Основные цвета
    readonly property color primary: "#6C5CE7"
    readonly property color primaryDark: "#5A4BD1"
    readonly property color primaryLight: "#A29BFE"
    readonly property color accent: "#00CEC9"
    readonly property color background: "#F8F9FA"
    readonly property color surface: "#FFFFFF"
    readonly property color error: "#FF7675"
    readonly property color success: "#00B894"
    readonly property color warning: "#FDCB6E"
    readonly property color textPrimary: "#2D3436"
    readonly property color textSecondary: "#636E72"
    readonly property color textOnPrimary: "#FFFFFF"
    readonly property color border: "#E0E0E0"
    
    // Градиенты
    readonly property string headerGradient: "linear-gradient(135deg, #6C5CE7 0%, #A29BFE 100%)"
    
    // Тени
    readonly property int shadowElevation1: 1
    readonly property int shadowElevation2: 3
    readonly property int shadowElevation3: 5
    
    // Размеры
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 16
    
    // Анимации
    readonly property int animationFast: 150
    readonly property int animationNormal: 250
    readonly property int animationSlow: 350
    
    // Шрифты
    readonly property string fontFamily: "Segoe UI, Roboto, sans-serif"
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeNormal: 14
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeTitle: 24
    readonly property int fontSizeHeader: 20
    
    // Функции для создания теней
    function elevationShadow(elevation) {
        switch(elevation) {
            case 1: return "0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.08)"
            case 2: return "0 3px 6px rgba(0,0,0,0.15), 0 2px 4px rgba(0,0,0,0.12)"
            case 3: return "0 10px 20px rgba(0,0,0,0.15), 0 3px 6px rgba(0,0,0,0.10)"
            default: return "none"
        }
    }
}