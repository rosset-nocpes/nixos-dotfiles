pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// Network state for the duo ring and panels, plus NetworkManager VPN profiles via nmcli.
Singleton {
    id: net

    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(device => device.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var activeWifi: wifiNetworks.find(network => network.connected) ?? null
    readonly property bool wired: devices.some(device => device.type === DeviceType.Wired && device.connected)
    readonly property bool online: wired || activeWifi !== null
    readonly property bool available: Networking.backend !== NetworkBackendType.None
    // 0-3 bars; wired counts as full strength.
    readonly property int strength: wired ? 3 : activeWifi ? Math.max(1, Math.ceil(activeWifi.signalStrength * 3)) : 0
    readonly property string summary: wired ? "Ethernet" : activeWifi ? activeWifi.name
        : !Networking.wifiEnabled ? "Off" : available ? "Not connected" : "Unavailable"

    property string vpnName: ""
    property bool vpnActive: false

    function toggleWifi() { Networking.wifiEnabled = !Networking.wifiEnabled; }
    function refreshVpn() { if (!vpnQuery.running) vpnQuery.running = true; }
    function toggleVpn() {
        if (!vpnName) return;
        vpnToggle.command = ["nmcli", "connection", vpnActive ? "down" : "up", "id", vpnName];
        vpnToggle.running = true;
    }

    Process {
        id: vpnQuery
        command: ["nmcli", "-t", "-f", "NAME,TYPE,ACTIVE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                // nmcli escapes ":" inside names as "\:".
                const rows = text.trim().split("\n").filter(line => line)
                    .map(line => line.split(/(?<!\\):/).map(field => field.replace(/\\:/g, ":")));
                const vpn = rows.find(row => row[1] === "vpn" || row[1] === "wireguard");
                net.vpnName = vpn ? vpn[0] : "";
                net.vpnActive = vpn ? vpn[2] === "yes" : false;
            }
        }
    }
    Process {
        id: vpnToggle
        onExited: net.refreshVpn()
    }
    Component.onCompleted: refreshVpn()
}
