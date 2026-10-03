import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../components"

Card {
    id: panel
    property var shell
    readonly property int current: Hyprland.focusedWorkspace?.id ?? 1
    readonly property var windows: panel.shell.workspace(current)?.toplevels.values ?? []

    function appName(toplevel) {
        const name = toplevel.lastIpcObject?.class ?? "";
        return name ? name.charAt(0).toUpperCase() + name.slice(1) : toplevel.title;
    }

    title: "Workspace " + current
    subtitle: windows.length === 0 ? "Empty · open an app or pick another workspace"
        : windows.length + (windows.length === 1 ? " window" : " windows") + " · click a window to focus"
    Component.onCompleted: Hyprland.refreshToplevels()

    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        Repeater {
            model: panel.shell.workspaceCount
            Rectangle {
                required property int index
                readonly property int workspaceId: index + 1
                readonly property bool focused: workspaceId === panel.current
                Layout.fillWidth: true
                implicitHeight: 40
                radius: 12
                color: focused ? Theme.accent : mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08)
                Accessible.role: Accessible.Button
                Accessible.name: "Workspace " + workspaceId
                UiText {
                    anchors.centerIn: parent
                    text: parent.workspaceId + (!parent.focused && panel.shell.occupied(parent.workspaceId) ? " ·" : "")
                    weight: parent.focused ? Font.DemiBold : Font.Normal
                    color: parent.focused ? Theme.accentText : Theme.text
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.shell.focusWorkspace(parent.workspaceId)
                }
            }
        }
    }

    Repeater {
        model: panel.windows
        OptionRow {
            required property var modelData
            title: panel.appName(modelData)
            subtitle: modelData.title
            selected: modelData.activated
            onClicked: {
                Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${modelData.address}" })`);
                panel.shell.closePanel();
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Item {
            implicitWidth: newLabel.implicitWidth
            implicitHeight: newLabel.implicitHeight
            Row {
                id: newLabel
                spacing: 6
                Icon { name: "plus"; size: 14; anchors.verticalCenter: parent.verticalCenter }
                UiText { text: "New workspace"; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    let id = 1;
                    while (id < 10 && panel.shell.workspace(id)) id++;
                    panel.shell.focusWorkspace(id);
                }
            }
        }
        Item { Layout.fillWidth: true }
        UiText { text: "Super + 1–0 to switch"; size: 12; color: Theme.textMuted }
    }
}
