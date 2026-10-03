import QtQuick
import ".."

Rectangle {
    id: toggle
    property bool checked: false
    signal toggled()

    implicitWidth: 36
    implicitHeight: 22
    radius: height / 2
    color: checked ? Theme.accent : Qt.rgba(1, 1, 1, 0.2)
    Accessible.role: Accessible.CheckBox
    Accessible.checked: checked

    Rectangle {
        width: 16
        height: 16
        radius: 8
        y: 3
        x: toggle.checked ? toggle.width - width - 3 : 3
        color: toggle.checked ? Theme.accentText : Theme.text
        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: toggle.toggled()
    }
}
