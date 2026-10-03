import QtQuick
import QtQuick.Layouts
import ".."

// Divider followed by an uppercase caption.
ColumnLayout {
    property alias text: label.text
    spacing: 18
    Layout.fillWidth: true

    Rectangle { implicitHeight: 1; color: Theme.divider; Layout.fillWidth: true }
    UiText {
        id: label
        size: 11
        weight: Font.DemiBold
        color: Theme.textMuted
        font.letterSpacing: 0.9
        font.capitalization: Font.AllUppercase
    }
}
