import QtQuick
import QtQuick.Controls
import ".."

Button {
    id: control
    property bool selected: false
    implicitHeight: 28
    implicitWidth: Math.max(30, contentItem.implicitWidth + 18)
    hoverEnabled: true
    focusPolicy: Qt.TabFocus
    contentItem: Text {
        text: control.text
        font.family: Theme.mono
        font.pixelSize: 12
        font.bold: control.selected
        color: control.selected ? Theme.background : Theme.foreground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: 6
        color: control.selected ? Theme.accent : control.hovered ? Theme.surface : "transparent"
        border.width: control.visualFocus ? 1 : 0
        border.color: Theme.accent
    }
}
