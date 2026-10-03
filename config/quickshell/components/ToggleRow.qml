import QtQuick
import QtQuick.Layouts
import ".."

RowLayout {
    id: row
    property string text
    property bool checked: false
    signal toggled()
    Layout.fillWidth: true
    opacity: enabled ? 1 : 0.5

    UiText { text: row.text; Layout.fillWidth: true }
    Toggle { checked: row.checked; onToggled: row.toggled(); Accessible.name: row.text }
}
