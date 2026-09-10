import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "components"

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: 42
    color: "transparent"
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var battery: UPower.displayDevice
    PwObjectTracker { objects: bar.sink ? [bar.sink] : [] }
    SystemClock { id: clock; precision: SystemClock.Minutes }

    BackgroundContrast { id: contrast; panel: bar }
    function foregroundAt(item) { return contrast.foregroundAt(item); }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        BarButton {
            foreground: bar.foregroundAt(this)
            text: "N /"
            Accessible.name: "Open launcher"
            onClicked: Quickshell.execDetached(["vicinae", "toggle"])
            ToolTip.visible: hovered
            ToolTip.text: "Launcher · Super R"
        }
        Row {
            spacing: 3
            Repeater {
                model: 10
                BarButton {
                    foreground: bar.foregroundAt(this)
                    required property int index
                    readonly property int workspaceId: index + 1
                    text: workspaceId === 10 ? "0" : workspaceId.toString()
                    selected: Hyprland.focusedWorkspace?.id === workspaceId
                    Accessible.name: "Workspace " + workspaceId
                    // Matches the Lua dispatcher used by the compositor configuration.
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + workspaceId + " })")
                }
            }
        }
        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            text: Hyprland.activeToplevel?.title || "Desktop"
            color: bar.foregroundAt(this)
            font.family: Theme.font
            font.pixelSize: 12
            elide: Text.ElideRight
            maximumLineCount: 1
        }
        Tray { panel: bar }
        BarButton {
            id: volume
            foreground: bar.foregroundAt(this)
            text: !bar.sink?.audio ? "Audio —" : bar.sink.audio.muted
                ? "Muted" : "Vol " + Math.round(bar.sink.audio.volume * 100) + "%"
            enabled: !!bar.sink?.audio
            Accessible.name: "Toggle audio mute"
            onClicked: bar.sink.audio.muted = !bar.sink.audio.muted
            ToolTip.visible: hovered
            ToolTip.text: "Click to mute · Scroll to adjust volume"
            WheelHandler {
                onWheel: event => {
                    if (bar.sink?.audio) {
                        bar.sink.audio.volume = Math.max(0, Math.min(1,
                            bar.sink.audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05)));
                    }
                }
            }
        }
        Text {
            visible: bar.battery.ready && bar.battery.isPresent
            text: (UPower.onBattery ? (bar.battery.percentage < 0.2 ? "! Bat " : "Bat ") : "AC ") + Math.round(bar.battery.percentage * 100) + "%"
            color: bar.foregroundAt(this)
            font.bold: UPower.onBattery && bar.battery.percentage < 0.2
            font.family: Theme.mono
            font.pixelSize: 12
        }
        Text {
            visible: bar.width > 900
            text: Qt.formatDateTime(clock.date, "ddd, dd MMM")
            color: bar.foregroundAt(this)
            font.family: Theme.font
            font.pixelSize: 12
        }
        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: bar.foregroundAt(this)
            font.family: Theme.mono
            font.pixelSize: 14
            font.bold: true
        }
    }
}
