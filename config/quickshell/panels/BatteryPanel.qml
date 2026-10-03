import QtQuick
import QtQuick.Layouts
import ".."
import "../components"
import "../services"

Card {
    id: panel
    property var shell

    title: Battery.present ? "Battery" : "Power"
    subtitle: Battery.present ? Battery.status : "Choose how your computer balances speed and power"

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.bottomMargin: 10
        visible: Battery.present

        ColumnLayout {
            spacing: 6
            Layout.fillWidth: true
            UiText {
                Layout.fillWidth: true
                text: Battery.percent
                size: 48
                weight: Font.Medium
                font.letterSpacing: -2.4
            }
            UiText {
                visible: Battery.seconds > 0
                text: "About " + Battery.duration(Battery.seconds) + (Battery.charging ? " until full" : " remaining")
                size: 12
                color: Theme.textMuted
            }
        }
        // Battery glyph whose fill follows the charge.
        Item {
            implicitWidth: 90
            implicitHeight: 44
            Rectangle {
                width: 78
                height: 42
                y: 1
                radius: 11
                color: "transparent"
                border.width: 2
                border.color: "#88ffffff"
                Rectangle {
                    x: 5
                    y: 5
                    width: Math.max(4, 66 * Battery.level)
                    height: 32
                    radius: 7
                    color: Battery.low ? Theme.warning : Theme.accent
                }
            }
            Rectangle { x: 82.5; y: 16; width: 5; height: 12; radius: 2.5; color: "#88ffffff" }
        }
    }

    SectionLabel { text: "Power mode" }

    Repeater {
        model: Battery.modes
        OptionRow {
            required property var modelData
            title: modelData.title
            subtitle: modelData.subtitle
            selected: Battery.mode === modelData.profile
            onClicked: Battery.setMode(modelData.profile)
        }
    }
}
