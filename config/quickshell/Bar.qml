import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "components"
import "panels"
import "services"

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    exclusiveZone: 50
    color: "transparent"
    WlrLayershell.namespace: "branchos-bar"

    // "", "workspaces", "clock", "sound", "quick", "control", "network" or "battery".
    property string panel: ""
    readonly property bool focusedScreen: !Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === screen?.name
    readonly property int workspaceCount: Math.max(4, ...Hyprland.workspaces.values.map(ws => ws.id).filter(id => id <= 10))

    function openPanel(name) { panel = name; }
    function closePanel() { panel = ""; }
    function togglePanel(name, family) { panel = (family ?? [name]).includes(panel) ? "" : name; }
    function run(command) {
        Quickshell.execDetached(command);
        closePanel();
    }
    function workspace(id) { return Hyprland.workspaces.values.find(ws => ws.id === id) ?? null; }
    function occupied(id) { return (workspace(id)?.toplevels.values.length ?? 0) > 0; }
    // Matches the Lua dispatcher used by the compositor configuration.
    function focusWorkspace(id) { Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`); }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Pill {
        id: workspacesPill
        x: 12
        y: 10
        padding: 6
        spacing: 4
        open: bar.panel === "workspaces"
        Accessible.name: "Workspaces"
        onClicked: bar.togglePanel("workspaces")
        onScrolled: delta => Hyprland.dispatch(`hl.dsp.focus({ workspace = "e${delta > 0 ? "-" : "+"}1" })`)

        Repeater {
            model: bar.workspaceCount
            Item {
                required property int index
                readonly property int workspaceId: index + 1
                readonly property bool focused: Hyprland.focusedWorkspace?.id === workspaceId
                readonly property bool occupied: bar.occupied(workspaceId)
                width: 32
                height: 28
                Accessible.role: Accessible.Button
                Accessible.name: "Workspace " + workspaceId

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: parent.focused ? Theme.pillActive : workspaceMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                    border.color: parent.focused ? Qt.rgba(1, 1, 1, 0.16) : "transparent"
                }
                UiText {
                    anchors.centerIn: parent
                    text: parent.workspaceId === 10 ? "0" : parent.workspaceId
                    weight: parent.focused ? Font.DemiBold : Font.Normal
                    color: parent.focused || parent.occupied ? Theme.text : Theme.textDim
                }
                // Occupied, unfocused workspaces get a small underline.
                Rectangle {
                    visible: parent.occupied && !parent.focused
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    width: 4
                    height: 2
                    radius: 1
                    color: Theme.text
                }
                MouseArea {
                    id: workspaceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: parent.focused ? bar.togglePanel("workspaces") : bar.focusWorkspace(parent.workspaceId)
                }
            }
        }
    }

    Pill {
        id: clockPill
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        padding: 20
        spacing: 10
        open: bar.panel === "clock"
        Accessible.name: "Calendar and notifications"
        onClicked: bar.togglePanel("clock")

        UiText {
            visible: bar.width > 900
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDate(clock.date, "ddd, MMM d")
            weight: Font.Medium
            color: "#e2e7eb"
        }
        Rectangle {
            visible: bar.width > 900
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: 3
            radius: 1.5
            color: Qt.rgba(1, 1, 1, 0.45)
        }
        UiText {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(clock.date, "H:mm")
            weight: Font.DemiBold
        }
        // Unread notifications.
        Rectangle {
            visible: Notifs.list.length > 0
            anchors.verticalCenter: parent.verticalCenter
            width: 6
            height: 6
            radius: 3
            color: Theme.text
        }
    }

    Row {
        id: status
        anchors.right: parent.right
        anchors.rightMargin: 12
        y: 10
        spacing: 8

        Pill {
            id: trayPill
            visible: tray.count > 0
            padding: 8
            spacing: 2
            Tray { id: tray; window: bar }
        }
        Pill {
            id: volumePill
            open: bar.panel === "sound"
            Accessible.name: "Sound"
            onClicked: bar.togglePanel("sound")
            onScrolled: delta => Audio.setVolume(Audio.volume + (delta > 0 ? 0.05 : -0.05))
            Icon {
                name: !Audio.ready || Audio.muted ? "speakerMuted" : "speaker"
                size: 19
                stroke: 1.7
                opacity: Audio.ready ? 1 : 0.5
            }
        }
        Pill {
            id: quickPill
            open: bar.panel === "quick"
            Accessible.name: "Quick settings"
            onClicked: bar.togglePanel("quick")
            Icon { name: "sliders"; size: 20; stroke: 1.6 }
        }
        Pill {
            id: duoPill
            open: ["control", "network", "battery"].includes(bar.panel)
            Accessible.name: "Control center · " + (Net.online ? "online" : "offline")
                + (Battery.present ? " · battery " + Battery.percent : "")
            onClicked: bar.togglePanel("control", ["control", "network", "battery"])
            DuoRing {
                battery: Battery.level
                hasBattery: Battery.present
                low: Battery.low
                online: Net.online
                strength: Net.strength
            }
        }
    }

    function anchorFor(name) {
        switch (name) {
        case "workspaces": return workspacesPill;
        case "clock": return clockPill;
        case "sound": return volumePill;
        case "quick": return quickPill;
        default: return duoPill;
        }
    }

    // Popups align to their pill: left for workspaces, centred for the clock, right otherwise.
    function popupX(name, width) {
        const pill = anchorFor(name);
        const origin = pill.mapToItem(bar.contentItem, 0, 0).x;
        const x = name === "workspaces" ? origin
            : name === "clock" ? origin + (pill.width - width) / 2
            : origin + pill.width - width;
        return Math.max(12, Math.min(bar.width - width - 12, x));
    }

    PopupWindow {
        id: popup
        readonly property int shadow: 32
        readonly property real cardX: bar.popupX(bar.panel, Theme.popupWidth)
        // Keep the shadow margin inside the screen so the compositor doesn't slide the popup.
        readonly property real windowX: Math.max(0, Math.min(bar.width - implicitWidth, cardX - shadow))
        visible: bar.panel !== ""
        color: "transparent"
        // Fixed size: resizing a mapped popup leaves stale frames, so only the card takes input.
        implicitWidth: Theme.popupWidth + shadow * 2
        implicitHeight: (bar.screen?.height ?? 1080) - Theme.barHeight
        mask: Region { item: content }
        anchor.window: bar
        anchor.rect.x: windowX
        anchor.rect.y: 10 + Theme.pillHeight + Theme.popupGap - shadow
        anchor.edges: Edges.Top | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right

        RectangularShadow {
            anchors.fill: content
            radius: 24
            blur: 40
            offset.y: 16
            color: "#3d000000"
        }
        Loader {
            id: content
            x: popup.cardX - popup.windowX
            y: popup.shadow
            width: Theme.popupWidth
            focus: true
            Keys.onEscapePressed: bar.closePanel()
            sourceComponent: ({
                workspaces: workspacesPanel,
                clock: clockPanel,
                sound: soundPanel,
                quick: quickPanel,
                control: controlPanel,
                network: networkPanel,
                battery: batteryPanel
            })[bar.panel] ?? null
        }
    }

    // Clicking anywhere outside the bar and its popup closes the popup.
    HyprlandFocusGrab {
        active: popup.visible
        windows: [popup, bar]
        onCleared: bar.closePanel()
    }

    Component { id: workspacesPanel; WorkspacesPanel { shell: bar } }
    Component { id: clockPanel; ClockPanel { shell: bar } }
    Component { id: soundPanel; SoundPanel { shell: bar } }
    Component { id: quickPanel; QuickSettingsPanel { shell: bar } }
    Component { id: controlPanel; ControlCenterPanel { shell: bar } }
    Component { id: networkPanel; NetworkPanel { shell: bar } }
    Component { id: batteryPanel; BatteryPanel { shell: bar } }

    // Newest notification, on the focused monitor only, while no popup is open.
    PopupWindow {
        id: toast
        readonly property int shadow: 32
        visible: Notifs.toast !== null && bar.panel === "" && bar.focusedScreen
        color: "transparent"
        implicitWidth: 360 + shadow * 2
        implicitHeight: 320
        mask: Region { item: toastCard }
        anchor.window: bar
        anchor.rect.x: bar.width - implicitWidth
        anchor.rect.y: 10 + Theme.pillHeight + Theme.popupGap - shadow
        anchor.edges: Edges.Top | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right

        RectangularShadow {
            anchors.fill: toastCard
            radius: 18
            blur: 32
            offset.y: 12
            color: "#33000000"
        }
        Loader {
            id: toastCard
            x: toast.width - 360 - 12
            y: toast.shadow
            width: 360
            active: Notifs.toast !== null
            sourceComponent: NotificationCard {
                notification: Notifs.toast
                color: Theme.card
                border.color: Theme.cardBorder
                radius: 18
            }
        }
    }
}
