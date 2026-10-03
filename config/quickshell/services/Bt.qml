pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property var connected: Bluetooth.devices.values.filter(device => device.connected)
    readonly property string summary: !adapter ? "Unavailable" : !enabled ? "Off"
        : connected.length === 0 ? "On" : connected.length === 1 ? connected[0].name : connected.length + " devices"

    function toggle() { if (adapter) adapter.enabled = !adapter.enabled; }
}
