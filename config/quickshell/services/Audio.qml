pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default output and the list of hardware outputs.
Singleton {
    id: audio
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: !!sink?.audio
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property string sinkName: sink?.nickname || sink?.description || "No output"
    readonly property var outputs: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)

    function setVolume(value) {
        if (!ready) return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, value));
    }
    function toggleMute() { if (ready) sink.audio.muted = !sink.audio.muted; }
    function use(node) { Pipewire.preferredDefaultAudioSink = node; }
    function kind(node) {
        const name = node.name.toLowerCase();
        return name.includes("hdmi") ? "HDMI / DisplayPort"
            : name.startsWith("bluez") ? "Bluetooth"
            : name.includes("usb") ? "USB audio"
            : name.includes("analog") ? "Analog stereo" : "";
    }

    PwObjectTracker { objects: audio.sink ? [audio.sink] : [] }
}
