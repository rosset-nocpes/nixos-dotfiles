import QtQuick
import QtQuick.Shapes
import ".."

// Battery as the outer arc, connection as the Wi-Fi glyph, signal strength as the three dots.
Item {
    id: ring
    property real battery: 1
    property bool hasBattery: true
    property bool low: false
    property bool online: true
    property int strength: 3

    implicitWidth: 24
    implicitHeight: 24

    Shape {
        // Drawn on the design's 34-unit grid.
        width: 34
        height: 34
        scale: ring.width / 34
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        // The open arc spans 238°, leaving the bottom free for the dots.
        ShapePath {
            fillColor: "transparent"
            strokeColor: Qt.rgba(1, 1, 1, ring.hasBattery ? 0.3 : 1)
            strokeWidth: 2.3
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: 17; centerY: 17; radiusX: 14.7; radiusY: 14.7; startAngle: 151; sweepAngle: 238 }
        }
        ShapePath {
            fillColor: "transparent"
            strokeColor: ring.low ? Theme.warning : Theme.text
            strokeWidth: ring.hasBattery && ring.battery > 0 ? 2.3 : 0
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 17; centerY: 17; radiusX: 14.7; radiusY: 14.7; startAngle: 151
                sweepAngle: 238 * Math.max(0.01, Math.min(1, ring.battery))
            }
        }
        ShapePath {
            fillColor: "transparent"
            strokeColor: Qt.rgba(1, 1, 1, ring.online ? 1 : 0.4)
            strokeWidth: 2.3
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M10.6 14.9 Q17 9.7 23.4 14.9 M13.5 18 Q17 15.2 20.5 18" }
        }
        ShapePath {
            fillColor: Qt.rgba(1, 1, 1, ring.online ? 1 : 0.4)
            strokeColor: "transparent"
            PathSvg { path: "M15.5 21.2a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0 -3 0" }
        }
        Repeater {
            model: [[8.8, 28.5], [17, 30.5], [25.2, 28.5]]
            Rectangle {
                required property var modelData
                required property int index
                x: modelData[0] - 1.45
                y: modelData[1] - 1.45
                width: 2.9
                height: 2.9
                radius: 1.45
                color: Qt.rgba(1, 1, 1, index < ring.strength ? 1 : 0.3)
            }
        }
    }
}
