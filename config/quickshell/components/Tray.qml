pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell.Services.SystemTray
import ".."

// Status-notifier icons, tinted white to match the bar.
Row {
    id: tray
    required property var window
    readonly property int count: SystemTray.items.values.length
    spacing: 2

    Repeater {
        model: SystemTray.items
        Item {
            id: item
            required property SystemTrayItem modelData
            width: 28
            height: 28
            Accessible.role: Accessible.Button
            Accessible.name: modelData.tooltipTitle || modelData.title || modelData.id

            function showMenu() {
                if (!modelData.hasMenu) return;
                const position = mapToItem(tray.window.contentItem, 0, height + 8);
                modelData.display(tray.window, position.x, position.y);
            }

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
            }
            Image {
                id: icon
                anchors.centerIn: parent
                width: 18
                height: 18
                source: item.modelData.icon
                sourceSize: Qt.size(18, 18)
                fillMode: Image.PreserveAspectFit
                visible: false
            }
            MultiEffect {
                anchors.fill: icon
                source: icon
                // Clamp RGB to white while preserving the icon alpha.
                brightness: 1
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: event => {
                    if (event.button === Qt.RightButton || item.modelData.onlyMenu) item.showMenu();
                    else if (event.button === Qt.MiddleButton) item.modelData.secondaryActivate();
                    else item.modelData.activate();
                }
                onWheel: event => {
                    if (event.angleDelta.y !== 0) item.modelData.scroll(event.angleDelta.y, false);
                    else if (event.angleDelta.x !== 0) item.modelData.scroll(event.angleDelta.x, true);
                }
            }
        }
    }
}
