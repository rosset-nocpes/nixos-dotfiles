import QtQuick
import ".."

// Frosted top-bar capsule. Content goes in a centered row.
Item {
    id: pill
    property bool open: false
    property int padding: 0
    property alias spacing: row.spacing
    default property alias content: row.data
    signal clicked()
    signal scrolled(int delta)

    implicitHeight: Theme.pillHeight
    implicitWidth: Math.max(implicitHeight, row.implicitWidth + padding * 2)
    Accessible.role: Accessible.Button
    Accessible.onPressAction: clicked()

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: pill.open ? Qt.rgba(0.2, 0.24, 0.27, 0.62) : mouse.containsMouse ? Qt.rgba(0.35, 0.39, 0.43, 0.5) : Theme.pill
        border.color: pill.open ? Qt.rgba(1, 1, 1, 0.45) : Theme.pillBorder
        Behavior on color { ColorAnimation { duration: 120 } }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: pill.clicked()
        onWheel: event => pill.scrolled(event.angleDelta.y)
    }
    Row {
        id: row
        anchors.centerIn: parent
    }
}
