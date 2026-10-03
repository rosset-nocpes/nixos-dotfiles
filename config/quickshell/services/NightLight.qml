pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Warm screen tint; hyprsunset runs only while enabled.
Singleton {
    id: nightLight
    property bool enabled: false
    Process {
        command: ["hyprsunset", "--temperature", "4000"]
        running: nightLight.enabled
    }
}
