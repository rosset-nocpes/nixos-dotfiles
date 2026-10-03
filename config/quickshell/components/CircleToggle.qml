import QtQuick
import QtQuick.Layouts
import ".."

// Control-centre row: the circle toggles, the label opens details.
RowLayout {
    id: row
    property string icon
    property string title
    property string subtitle
    property bool active: false
    signal toggled()
    signal detailClicked()
    spacing: 10
    Layout.fillWidth: true

    Rectangle {
        implicitWidth: 32
        implicitHeight: 32
        radius: 16
        color: row.active ? Theme.accent : circleMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.26) : Theme.track
        Accessible.role: Accessible.CheckBox
        Accessible.name: row.title
        Accessible.checked: row.active
        Icon {
            anchors.centerIn: parent
            name: row.icon
            size: 18
            stroke: 2
            color: row.active ? Theme.accentText : Theme.text
        }
        MouseArea {
            id: circleMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.toggled()
        }
    }
    Item {
        Layout.fillWidth: true
        implicitHeight: labels.implicitHeight
        ColumnLayout {
            id: labels
            width: parent.width
            spacing: 2
            UiText { text: row.title; weight: Font.DemiBold; Layout.fillWidth: true }
            UiText { text: row.subtitle; size: 11; color: Theme.textMuted; Layout.fillWidth: true }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: row.detailClicked()
        }
    }
}
