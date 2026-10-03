import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Networking
import Quickshell.Services.Mpris
import ".."
import "../components"
import "../services"

// Opened from the duo ring: network and battery first, then everyday controls.
Card {
    id: panel
    property var shell
    readonly property var player: Mpris.players.values.find(player => player.isPlaying) ?? Mpris.players.values[0] ?? null

    padding: 14
    spacing: 10
    Component.onCompleted: { Net.refreshVpn(); Brightness.refresh(); }

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: 6
        Layout.bottomMargin: 4
        UiText { text: "Control center"; size: 21; weight: Font.DemiBold; font.letterSpacing: -0.5 }
        Item { Layout.fillWidth: true }
        UiText {
            text: (Net.online ? "Online" : "Offline") + (Battery.present ? ` · ${Battery.percent} battery` : "")
            size: 12
            color: Theme.textMuted
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Surface {
            Layout.fillWidth: false
            Layout.preferredWidth: 196
            Layout.fillHeight: true
            spacing: 14

            CircleToggle {
                icon: Networking.wifiEnabled ? "wifi" : "wifiOff"
                title: "Wi-Fi"
                subtitle: Net.wired && !Net.activeWifi ? "Using Ethernet" : Net.summary
                active: Networking.wifiEnabled
                onToggled: Net.toggleWifi()
                onDetailClicked: panel.shell.openPanel("network")
            }
            CircleToggle {
                icon: "bluetooth"
                title: "Bluetooth"
                subtitle: Bt.summary
                active: Bt.enabled
                onToggled: Bt.toggle()
                onDetailClicked: panel.shell.run(["blueman-manager"])
            }
            CircleToggle {
                icon: "shield"
                title: "VPN"
                subtitle: !Net.vpnName ? "Not set up" : Net.vpnActive ? Net.vpnName : "Off"
                active: Net.vpnActive
                onToggled: Net.toggleVpn()
                onDetailClicked: panel.shell.run(["nm-connection-editor"])
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Surface {
                visible: Battery.present
                clickable: true
                onClicked: panel.shell.openPanel("battery")

                RowLayout {
                    spacing: 12
                    Layout.fillWidth: true
                    BatteryRing {}
                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        UiText { text: Battery.percent; size: 20; weight: Font.DemiBold; font.letterSpacing: -0.4 }
                        UiText { text: Battery.remaining; size: 11; color: Theme.textMuted; Layout.fillWidth: true }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10
                SmallTile {
                    icon: "moon"
                    title: "Focus"
                    active: Notifs.dnd
                    onClicked: Notifs.dnd = !Notifs.dnd
                }
                SmallTile {
                    icon: "sun"
                    title: "Night light"
                    active: NightLight.enabled
                    onClicked: NightLight.enabled = !NightLight.enabled
                }
            }
        }
    }

    Surface {
        visible: Brightness.available
        UiText { text: "Display"; weight: Font.DemiBold }
        PillSlider {
            Layout.fillWidth: true
            icon: "sunFilled"
            value: Brightness.value
            onMoved: value => Brightness.set(value)
        }
    }

    Surface {
        RowLayout {
            Layout.fillWidth: true
            UiText { text: "Sound"; weight: Font.DemiBold; Layout.fillWidth: true }
            UiText {
                text: Audio.sinkName + " ›"
                size: 11
                color: Theme.textMuted
                Layout.maximumWidth: 220
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.shell.openPanel("sound")
                }
            }
        }
        PillSlider {
            Layout.fillWidth: true
            enabled: Audio.ready
            icon: Audio.muted ? "speakerMuted" : "speakerFilled"
            value: Audio.muted ? 0 : Audio.volume
            onMoved: value => Audio.setVolume(value)
        }
    }

    Surface {
        visible: panel.player !== null
        padding: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.rightMargin: 4
            spacing: 12

            Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 10
                clip: true
                gradient: Gradient {
                    GradientStop { position: 0; color: "#e9a23b" }
                    GradientStop { position: 1; color: "#8a4b1c" }
                }
                Image {
                    anchors.fill: parent
                    source: panel.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(80, 80)
                }
            }
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true
                UiText { text: panel.player?.trackTitle || "Nothing playing"; weight: Font.DemiBold; Layout.fillWidth: true }
                UiText {
                    text: [panel.player?.trackArtist, panel.player?.identity].filter(part => part).join(" · ")
                    size: 11
                    color: Theme.textMuted
                    Layout.fillWidth: true
                }
            }
            IconButton { icon: "previous"; enabled: panel.player?.canGoPrevious ?? false; onClicked: panel.player.previous() }
            IconButton {
                icon: panel.player?.isPlaying ? "pause" : "play"
                size: 20
                enabled: panel.player?.canTogglePlaying ?? false
                onClicked: panel.player.togglePlaying()
            }
            IconButton { icon: "next"; enabled: panel.player?.canGoNext ?? false; onClicked: panel.player.next() }
        }
    }

    Surface {
        padding: 4
        radius: 14
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: Battery.modes
                Rectangle {
                    required property var modelData
                    readonly property bool selected: Battery.mode === modelData.profile
                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 10
                    color: selected ? Theme.accent : "transparent"
                    Accessible.role: Accessible.RadioButton
                    Accessible.name: modelData.title
                    Accessible.checked: selected
                    UiText {
                        anchors.centerIn: parent
                        text: parent.modelData.title
                        size: 12
                        weight: parent.selected ? Font.DemiBold : Font.Normal
                        color: parent.selected ? Theme.accentText : Theme.textMuted
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Battery.setMode(parent.modelData.profile)
                    }
                }
            }
        }
    }

    component SmallTile: Rectangle {
        id: small
        property string icon
        property string title
        property bool active: false
        signal clicked()
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        implicitHeight: 72
        radius: 18
        color: active ? Theme.accent : smallMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Theme.surface
        border.color: active ? "transparent" : Theme.surfaceBorder
        Accessible.role: Accessible.CheckBox
        Accessible.name: title
        Accessible.checked: active

        Icon {
            x: 12
            y: 12
            name: small.icon
            size: 20
            color: small.active ? Theme.accentText : Theme.text
        }
        UiText {
            x: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            text: small.title
            size: 12
            weight: Font.DemiBold
            color: small.active ? Theme.accentText : Theme.text
        }
        MouseArea {
            id: smallMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: small.clicked()
        }
    }

    component IconButton: Item {
        id: iconButton
        property string icon
        property real size: 18
        signal clicked()
        implicitWidth: 24
        implicitHeight: 24
        opacity: enabled ? 1 : 0.4
        Accessible.role: Accessible.Button
        Accessible.name: icon
        Icon { anchors.centerIn: parent; name: iconButton.icon; size: iconButton.size }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: iconButton.clicked()
        }
    }

    component BatteryRing: Shape {
        implicitWidth: 36
        implicitHeight: 36
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: "transparent"
            strokeColor: Qt.rgba(1, 1, 1, 0.18)
            strokeWidth: 3.5
            PathAngleArc { centerX: 18; centerY: 18; radiusX: 14; radiusY: 14; sweepAngle: 360 }
        }
        ShapePath {
            fillColor: "transparent"
            strokeColor: Battery.low ? Theme.warning : Theme.accent
            strokeWidth: 3.5
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: 18; centerY: 18; radiusX: 14; radiusY: 14; startAngle: -90; sweepAngle: 360 * Battery.level }
        }
    }
}
