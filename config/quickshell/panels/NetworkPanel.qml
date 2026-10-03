import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Networking
import ".."
import "../components"
import "../services"

Card {
    id: panel
    property var shell
    property var passwordFor: null
    readonly property var active: Net.activeWifi
    readonly property var others: Net.wifiNetworks
        .filter(network => !network.connected && network.name)
        .sort((a, b) => b.signalStrength - a.signalStrength)
        .slice(0, 4)

    function strengthText(network) {
        return network.signalStrength > 0.66 ? "strong signal" : network.signalStrength > 0.33 ? "good signal" : "weak signal";
    }
    function join(network) {
        if (network.known || network.security === WifiSecurityType.Open) network.connect();
        else panel.passwordFor = network;
    }

    title: "Wi-Fi"
    subtitle: !Net.available ? "NetworkManager is not running"
        : !Networking.wifiEnabled ? "Off"
        : active ? "Connected" + (active.security === WifiSecurityType.Open ? " · open" : " · secured")
        : "Not connected"

    // Scan only while the panel is visible.
    Component.onCompleted: if (Net.wifiDevice) Net.wifiDevice.scannerEnabled = true
    Component.onDestruction: if (Net.wifiDevice) Net.wifiDevice.scannerEnabled = false

    ToggleRow {
        text: "Wi-Fi"
        checked: Networking.wifiEnabled
        onToggled: Net.toggleWifi()
    }

    Surface {
        visible: panel.active !== null
        padding: 16
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 6
                Layout.fillWidth: true
                UiText { text: panel.active?.name ?? ""; size: 16; weight: Font.DemiBold; Layout.fillWidth: true }
                UiText {
                    text: panel.active ? "Connected · " + panel.strengthText(panel.active) : ""
                    size: 12
                    color: Theme.textMuted
                }
            }
            Icon { name: "check"; size: 16; stroke: 2 }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            SoftButton { text: "Details"; onClicked: panel.shell.run(["nm-connection-editor"]) }
            SoftButton { text: "Disconnect"; onClicked: panel.active.disconnect() }
        }
    }

    SectionLabel {
        visible: Networking.wifiEnabled && panel.others.length > 0
        text: "Other networks"
    }

    Repeater {
        model: Networking.wifiEnabled ? panel.others : []
        OptionRow {
            required property var modelData
            title: modelData.name
            subtitle: (modelData.stateChanging ? "Connecting…"
                : modelData.known ? "Saved"
                : modelData.security === WifiSecurityType.Open ? "Open" : "Secured")
                + " · " + panel.strengthText(modelData)
            onClicked: panel.join(modelData)
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: panel.passwordFor !== null
        spacing: 8

        TextField {
            id: password
            Layout.fillWidth: true
            implicitHeight: 36
            focus: visible
            echoMode: TextInput.Password
            placeholderText: "Password for " + (panel.passwordFor?.name ?? "")
            placeholderTextColor: Theme.textMuted
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 13
            leftPadding: 12
            background: Rectangle { radius: 12; color: Qt.rgba(1, 1, 1, 0.08); border.color: Theme.surfaceBorder }
            onAccepted: connectButton.clicked()
            Keys.onEscapePressed: panel.passwordFor = null
        }
        SoftButton {
            id: connectButton
            Layout.fillWidth: false
            text: "Join"
            onClicked: {
                panel.passwordFor.connectWithPsk(password.text);
                password.text = "";
                panel.passwordFor = null;
            }
        }
    }
}
