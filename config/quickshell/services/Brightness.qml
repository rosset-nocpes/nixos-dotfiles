pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Backlight level through brightnessctl; unavailable on desktops without a backlight.
Singleton {
    id: brightness
    property bool available: false
    property real value: 0

    function refresh() { if (!query.running) query.running = true; }
    function set(level) {
        value = Math.max(0.01, level);
        Quickshell.execDetached(["brightnessctl", "-c", "backlight", "-q", "set", Math.round(value * 100) + "%"]);
    }

    Process {
        id: query
        // Machine format: device,class,current,percent,max
        command: ["brightnessctl", "-c", "backlight", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("\n")[0]?.split(",") ?? [];
                brightness.available = fields.length >= 5 && Number(fields[4]) > 0;
                if (brightness.available) brightness.value = Number(fields[2]) / Number(fields[4]);
            }
        }
    }
    Component.onCompleted: refresh()
}
