import QtQuick
import QtQuick.Layouts
import ".."

// Quick-settings toggle tile; the chevron opens details when detailClicked is used.
Rectangle {
    id: tile
    property string icon
    property string title
    property string subtitle
    property bool active: false
    property bool hasDetail: false
    signal clicked()
    signal detailClicked()

    readonly property color foreground: active ? Theme.accentText : Theme.text
    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: 102
    radius: 18
    color: active ? Theme.accent : mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Theme.surface
    border.color: active ? "transparent" : Theme.surfaceBorder
    Accessible.role: Accessible.CheckBox
    Accessible.name: title
    Accessible.checked: active

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.clicked()
    }
    ColumnLayout {
        x: 16
        y: 16
        width: parent.width - 32
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Icon { name: tile.icon; size: 22; stroke: 1.7; color: tile.foreground }
            Item { Layout.fillWidth: true }
            Item {
                visible: tile.hasDetail
                implicitWidth: 22
                implicitHeight: 22
                Icon { anchors.centerIn: parent; name: "chevronRight"; size: 16; color: tile.foreground }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: tile.detailClicked()
                }
            }
        }
        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true
            UiText { text: tile.title; size: 14; weight: Font.DemiBold; color: tile.foreground; Layout.fillWidth: true }
            UiText {
                text: tile.subtitle
                size: 11
                color: tile.active ? Theme.accentTextMuted : Theme.textMuted
                Layout.fillWidth: true
            }
        }
    }
}
