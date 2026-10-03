import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

// One notification: app and age, summary, body, and a dismiss button.
// Clicking it runs the notification's default action.
Surface {
    id: card
    required property var notification
    property date now: new Date()
    readonly property var action: notification.actions.find(action => action.identifier === "default") ?? notification.actions[0] ?? null

    radius: 14
    spacing: 6
    border.color: "transparent"
    clickable: action !== null
    onClicked: action.invoke()

    RowLayout {
        Layout.fillWidth: true
        UiText {
            text: [card.notification.appName, Notifs.age(card.notification, card.now)].filter(part => part).join(" · ")
            size: 11
            color: Theme.textMuted
            Layout.fillWidth: true
        }
        Item {
            implicitWidth: 16
            implicitHeight: 16
            Accessible.role: Accessible.Button
            Accessible.name: "Dismiss"
            Icon { anchors.centerIn: parent; name: "close"; size: 14; stroke: 2 }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: card.notification.dismiss()
            }
        }
    }
    UiText {
        text: card.notification.summary
        size: 15
        weight: Font.DemiBold
        Layout.fillWidth: true
        Layout.topMargin: 4
    }
    UiText {
        visible: text !== ""
        text: card.notification.body
        textFormat: Text.PlainText
        size: 12
        color: Theme.textMuted
        wrapMode: Text.Wrap
        maximumLineCount: 3
        Layout.fillWidth: true
    }
}
