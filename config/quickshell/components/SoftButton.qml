import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: button
    property string text
    property string icon
    signal clicked()

    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: 36
    implicitWidth: label.implicitWidth + 32
    radius: 12
    color: mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08)
    Accessible.role: Accessible.Button
    Accessible.name: text

    Row {
        anchors.centerIn: parent
        spacing: 6
        Icon { visible: button.icon !== ""; name: button.icon; size: 14; anchors.verticalCenter: parent.verticalCenter }
        UiText { id: label; text: button.text; size: 12; anchors.verticalCenter: parent.verticalCenter }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
