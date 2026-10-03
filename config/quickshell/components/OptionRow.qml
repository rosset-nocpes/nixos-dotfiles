import QtQuick
import QtQuick.Layouts
import ".."

// Selectable two-line row (power modes, audio outputs, networks).
Rectangle {
    id: option
    property string title
    property string subtitle
    property bool selected: false
    property alias trailing: trailingSlot.data
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28
    radius: 14
    color: selected ? Theme.rowSelected : mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Theme.row
    Accessible.role: Accessible.RadioButton
    Accessible.name: title
    Accessible.checked: selected

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: option.clicked()
    }
    RowLayout {
        id: content
        x: 14
        width: parent.width - 28
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true
            UiText { text: option.title; size: 14; weight: Font.Medium; Layout.fillWidth: true }
            UiText {
                visible: text !== ""
                text: option.subtitle
                size: 12
                color: Theme.textMuted
                Layout.fillWidth: true
            }
        }
        Item {
            id: trailingSlot
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
        Icon { visible: option.selected; name: "check"; size: 16; stroke: 2 }
    }
}
