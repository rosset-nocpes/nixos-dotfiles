import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Networking
import ".."
import "../components"
import "../services"

Card {
    id: panel
    property var shell
    property bool confirmPower: false

    title: "Quick settings"
    subtitle: "Everything within reach"
    Component.onCompleted: Brightness.refresh()

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 12
        columnSpacing: 12

        Tile {
            icon: Networking.wifiEnabled ? "wifi" : "wifiOff"
            title: "Wi-Fi"
            subtitle: Net.summary
            active: Networking.wifiEnabled
            hasDetail: true
            onClicked: Net.toggleWifi()
            onDetailClicked: panel.shell.openPanel("network")
        }
        Tile {
            icon: "bluetooth"
            title: "Bluetooth"
            subtitle: Bt.summary
            active: Bt.enabled
            hasDetail: true
            onClicked: Bt.toggle()
            onDetailClicked: panel.shell.run(["blueman-manager"])
        }
        Tile {
            icon: "moon"
            title: "Focus"
            subtitle: Notifs.dnd ? "Notifications silenced" : "Off"
            active: Notifs.dnd
            hasDetail: true
            onClicked: Notifs.dnd = !Notifs.dnd
            onDetailClicked: panel.shell.openPanel("clock")
        }
        Tile {
            icon: "sun"
            title: "Night light"
            subtitle: NightLight.enabled ? "On · 4000 K" : "Off"
            active: NightLight.enabled
            onClicked: NightLight.enabled = !NightLight.enabled
        }
    }

    ThinSlider {
        visible: Brightness.available
        label: "Brightness"
        value: Brightness.value
        onMoved: value => Brightness.set(value)
    }
    ThinSlider {
        label: "Volume"
        enabled: Audio.ready
        value: Audio.volume
        onMoved: value => Audio.setVolume(value)
    }

    Rectangle { implicitHeight: 1; color: Theme.divider; Layout.fillWidth: true }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: !panel.confirmPower
        SoftButton { icon: "lock"; text: "Lock"; implicitHeight: 40; onClicked: panel.shell.run(["hyprlock"]) }
        SoftButton { icon: "moon"; text: "Sleep"; implicitHeight: 40; onClicked: panel.shell.run(["systemctl", "suspend"]) }
        SoftButton { icon: "power"; text: "Power…"; implicitHeight: 40; onClicked: panel.confirmPower = true }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: panel.confirmPower
        SoftButton { text: "Cancel"; implicitHeight: 40; onClicked: panel.confirmPower = false }
        SoftButton { text: "Log out"; implicitHeight: 40; onClicked: Hyprland.dispatch("hl.dsp.exit()") }
        SoftButton { text: "Restart"; implicitHeight: 40; onClicked: panel.shell.run(["systemctl", "reboot"]) }
        SoftButton { text: "Shut down"; implicitHeight: 40; onClicked: panel.shell.run(["systemctl", "poweroff"]) }
    }
}
