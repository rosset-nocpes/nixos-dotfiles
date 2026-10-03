import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: link
    property string text
    signal clicked()
    Layout.fillWidth: true
    implicitHeight: 36
    Accessible.role: Accessible.Link
    Accessible.name: text

    RowLayout {
        anchors.fill: parent
        UiText { text: link.text; Layout.fillWidth: true }
        Icon { name: "chevronRight"; size: 16 }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: link.clicked()
    }
}
