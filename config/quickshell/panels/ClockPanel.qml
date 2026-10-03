import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."
import "../components"
import "../services"

Card {
    id: panel
    property var shell
    readonly property date today: clock.date
    property date month: new Date(today.getFullYear(), today.getMonth(), 1)
    // Monday-first offset of the 1st, and the number of rows the month needs.
    readonly property int offset: (month.getDay() + 6) % 7
    readonly property int days: new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate()
    readonly property int cells: Math.ceil((offset + days) / 7) * 7

    function shiftMonth(delta) { month = new Date(month.getFullYear(), month.getMonth() + delta, 1); }

    title: Qt.formatDate(today, "dddd, MMMM d")
    subtitle: "Your day, at a glance"
    SystemClock { id: clock; precision: SystemClock.Minutes }

    RowLayout {
        Layout.fillWidth: true
        UiText { text: Qt.formatDate(panel.month, "MMMM yyyy"); size: 15; weight: Font.DemiBold; Layout.fillWidth: true }
        NavButton { icon: "chevronLeft"; onClicked: panel.shiftMonth(-1) }
        UiText {
            text: "Today"
            size: 12
            color: Theme.textDim
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: panel.month = new Date(panel.today.getFullYear(), panel.today.getMonth(), 1)
            }
        }
        NavButton { icon: "chevronRight"; onClicked: panel.shiftMonth(1) }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 7
        rowSpacing: 0
        columnSpacing: 0

        Repeater {
            model: ["M", "T", "W", "T", "F", "S", "S"]
            UiText {
                required property string modelData
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.bottomMargin: 8
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                size: 11
                color: Theme.textMuted
            }
        }
        Repeater {
            model: panel.cells
            Item {
                required property int index
                readonly property date day: new Date(panel.month.getFullYear(), panel.month.getMonth(), index - panel.offset + 1)
                readonly property bool inMonth: day.getMonth() === panel.month.getMonth()
                readonly property bool isToday: day.toDateString() === panel.today.toDateString()
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 48
                Rectangle {
                    anchors.centerIn: parent
                    visible: parent.isToday
                    width: 40
                    height: 30
                    radius: 15
                    color: Theme.accent
                }
                UiText {
                    anchors.centerIn: parent
                    text: parent.day.getDate()
                    weight: parent.isToday ? Font.DemiBold : Font.Normal
                    color: parent.isToday ? Theme.accentText : parent.inMonth ? Theme.text : Theme.textFaint
                }
            }
        }
    }

    Rectangle { implicitHeight: 1; color: Theme.divider; Layout.fillWidth: true }

    RowLayout {
        Layout.fillWidth: true
        UiText {
            text: "Notifications" + (Notifs.list.length ? " · " + Notifs.list.length : "")
            size: 15
            weight: Font.DemiBold
            Layout.fillWidth: true
        }
        UiText {
            visible: Notifs.list.length > 0
            text: "Clear all"
            size: 12
            color: Theme.textDim
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifs.clearAll()
            }
        }
    }

    UiText {
        visible: Notifs.list.length === 0
        text: Notifs.dnd ? "Do not disturb is on" : "You're all caught up"
        size: 12
        color: Theme.textMuted
    }

    Repeater {
        // Keep the panel on screen; older notifications stay in the count.
        model: Notifs.list.slice(0, 4)
        NotificationCard {
            required property var modelData
            notification: modelData
            now: clock.date
        }
    }

    ToggleRow {
        text: "Do not disturb"
        checked: Notifs.dnd
        onToggled: Notifs.dnd = !Notifs.dnd
    }

    component NavButton: Item {
        id: nav
        property string icon
        signal clicked()
        implicitWidth: 28
        implicitHeight: 28
        Accessible.role: Accessible.Button
        Accessible.name: icon === "chevronLeft" ? "Previous month" : "Next month"
        Icon { anchors.centerIn: parent; name: nav.icon; size: 16; stroke: 2 }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: nav.clicked()
        }
    }
}
