import QtQuick
import QtQuick.Layouts
import ".."

// Labelled 8px track with a round knob; emits moved() while dragging.
ColumnLayout {
    id: slider
    property string label
    property real value: 0
    signal moved(real value)
    spacing: 12
    opacity: enabled ? 1 : 0.5
    Layout.fillWidth: true

    RowLayout {
        Layout.fillWidth: true
        UiText { text: slider.label; Layout.fillWidth: true }
        UiText { text: Math.round(slider.value * 100) + "%"; size: 12; color: Theme.textMuted }
    }
    Item {
        Layout.fillWidth: true
        implicitHeight: 20

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 8
            radius: 4
            color: Theme.track
            Rectangle {
                width: Math.max(height, track.width * slider.value)
                height: parent.height
                radius: 4
                color: Theme.accent
            }
        }
        Rectangle {
            width: 20
            height: 20
            radius: 10
            color: Theme.text
            x: (parent.width - width) * slider.value
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
}
