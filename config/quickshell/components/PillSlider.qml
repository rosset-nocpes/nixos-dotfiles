import QtQuick
import ".."

// Control-centre slider: a thick capsule with the icon inside the fill.
Item {
    id: slider
    property real value: 0
    property string icon
    signal moved(real value)

    implicitHeight: 26
    opacity: enabled ? 1 : 0.5
    Accessible.role: Accessible.Slider

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.track
    }
    Rectangle {
        width: Math.max(height, parent.width * slider.value)
        height: parent.height
        radius: height / 2
        color: Theme.accent
    }
    Icon {
        x: 7
        anchors.verticalCenter: parent.verticalCenter
        name: slider.icon
        size: 16
        stroke: 2
        color: Theme.accentText
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function update(x) { slider.moved(Math.max(0, Math.min(1, x / width))); }
        onPressed: event => update(event.x)
        onPositionChanged: event => update(event.x)
        onWheel: event => slider.moved(Math.max(0, Math.min(1, slider.value + (event.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
