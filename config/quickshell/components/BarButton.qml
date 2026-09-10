import QtQuick
import QtQuick.Controls
import ".."

Button {
    id: control
    property bool selected: false
    property color foreground: Theme.lightForeground
    implicitHeight: 28
    implicitWidth: Math.max(30, contentItem.implicitWidth + 18)
    hoverEnabled: true
    focusPolicy: Qt.TabFocus
    contentItem: Text {
        text: control.text
        font.family: Theme.mono
        font.pixelSize: 12
        font.bold: control.selected
        color: control.foreground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: 6
        color: Qt.alpha(control.foreground, control.selected ? 0.22 : control.hovered ? 0.12 : 0)
        border.width: control.visualFocus ? 1 : 0
        border.color: control.foreground
    }
}
