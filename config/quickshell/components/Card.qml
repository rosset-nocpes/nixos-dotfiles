import QtQuick
import QtQuick.Layouts
import ".."

// Popup surface with an optional title and subtitle.
Rectangle {
    id: card
    property string title
    property string subtitle
    property int padding: 24
    property alias spacing: column.spacing
    default property alias content: column.data

    implicitWidth: Theme.popupWidth
    implicitHeight: column.implicitHeight + padding * 2
    radius: 24
    color: Theme.card
    border.color: Theme.cardBorder

    ColumnLayout {
        id: column
        x: card.padding
        y: card.padding
        width: card.width - card.padding * 2
        spacing: 18

        ColumnLayout {
            visible: card.title !== ""
            spacing: 6
            Layout.fillWidth: true
            UiText {
                text: card.title
                size: 21
                weight: Font.DemiBold
                font.letterSpacing: -0.5
                Layout.fillWidth: true
            }
            UiText {
                visible: text !== ""
                text: card.subtitle
                size: 12
                color: Theme.textMuted
                Layout.fillWidth: true
            }
        }
    }
}
