import QtQuick
import QtQuick.Layouts
import ".."

// Tinted module inside a card. Children stack in a padded column; set clickable for a
// whole-module click target.
Rectangle {
    id: surface
    property int padding: 14
    property bool clickable: false
    property alias spacing: column.spacing
    default property alias content: column.data
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + padding * 2
    radius: 18
    color: Theme.surface
    border.color: Theme.surfaceBorder

    MouseArea {
        anchors.fill: parent
        enabled: surface.clickable
        cursorShape: Qt.PointingHandCursor
        onClicked: surface.clicked()
    }
    ColumnLayout {
        id: column
        x: surface.padding
        y: surface.padding
        width: surface.width - surface.padding * 2
        spacing: 10
    }
}
