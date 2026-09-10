pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell.Services.SystemTray

Row {
    id: tray
    required property var panel
    spacing: 3
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items
        BarButton {
            id: button
            required property SystemTrayItem modelData
            implicitWidth: 30
            foreground: tray.panel.foregroundAt(this)
            Accessible.name: modelData.tooltipTitle || modelData.title || modelData.id
            ToolTip.visible: hovered
            ToolTip.text: modelData.tooltipTitle || modelData.title || modelData.id

            function showMenu() {
                if (!modelData.hasMenu) return;
                const position = mapToItem(tray.panel.contentItem, 0, height);
                modelData.display(tray.panel, position.x, position.y);
            }

            onClicked: {
                if (modelData.onlyMenu) showMenu();
                else modelData.activate();
            }
            contentItem: Item {
                Image {
                    id: trayIcon
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    source: button.modelData.icon
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: 18
                    sourceSize.height: 18
                    visible: false
                }
                MultiEffect {
                    anchors.fill: trayIcon
                    source: trayIcon
                    // Clamp RGB to black/white while preserving the icon alpha.
                    brightness: button.foreground.r > 0.5 ? 1 : -1
                }
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) button.showMenu();
                    else button.modelData.secondaryActivate();
                }
                onWheel: wheel => {
                    if (wheel.angleDelta.y !== 0)
                        button.modelData.scroll(wheel.angleDelta.y, false);
                    else if (wheel.angleDelta.x !== 0)
                        button.modelData.scroll(wheel.angleDelta.x, true);
                }
            }
        }
    }
}
