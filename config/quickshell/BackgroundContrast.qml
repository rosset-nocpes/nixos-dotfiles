import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: contrast
    required property var panel
    property var darkText: []
    property bool captureFailed: false

    function foregroundAt(item) {
        // Mapping follows layout changes, including trays and monitor resizing.
        const position = item.mapToItem(panel.contentItem, item.width / 2, 0);
        const index = Math.max(0, Math.min(darkText.length - 1, Math.floor(position.x / 64)));
        return darkText[index] ? Theme.darkForeground : Theme.lightForeground;
    }

    Process {
        id: capture
        command: ["python3", decodeURIComponent(Qt.resolvedUrl("sample-background.py").toString().replace(/^file:\/\//, "")),
            String(contrast.panel.screen?.x ?? 0), String(contrast.panel.screen?.y ?? 0),
            String(contrast.panel.width), String(contrast.panel.height)]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim()) {
                    if (!contrast.captureFailed)
                        console.warn("Bar background capture unavailable; check grim and screen capture permissions.");
                    contrast.captureFailed = true;
                    return;
                }
                contrast.captureFailed = false;
                try {
                    const values = JSON.parse(text);
                    // Black/white contrast crosses at luminance ~0.179.
                    // A dead band prevents flicker around the crossover.
                    contrast.darkText = values.map((value, index) =>
                        value > (contrast.darkText[index] ? 0.16 : 0.20));
                } catch (error) {
                    console.warn("Unable to read bar contrast sample:", error);
                }
            }
        }
    }
    Timer {
        interval: Theme.sampleInterval
        running: !!contrast.panel.screen && contrast.panel.width > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!capture.running) capture.running = true
    }
}
