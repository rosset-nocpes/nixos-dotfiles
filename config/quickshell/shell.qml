import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Variants {
        id: bars
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }

    // `quickshell -c branchos ipc call panel toggle control` (or workspaces, clock, sound, quick, network, battery).
    IpcHandler {
        target: "panel"
        function toggle(name: string): void {
            const bar = bars.instances.find(bar => bar.focusedScreen) ?? bars.instances[0];
            bar?.togglePanel(name);
        }
    }
}
