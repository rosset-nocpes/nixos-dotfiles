import QtQuick
import QtQuick.Layouts
import ".."
import "../components"
import "../services"

Card {
    id: panel
    property var shell

    title: "Sound"
    subtitle: "Choose where your audio plays"

    ThinSlider {
        label: "Output volume"
        enabled: Audio.ready
        value: Audio.volume
        onMoved: value => Audio.setVolume(value)
    }
    ToggleRow {
        text: "Mute audio"
        enabled: Audio.ready
        checked: Audio.muted
        onToggled: Audio.toggleMute()
    }

    SectionLabel { text: "Output device" }

    Repeater {
        model: Audio.outputs
        OptionRow {
            required property var modelData
            title: modelData.description || modelData.nickname || modelData.name
            subtitle: Audio.kind(modelData)
            selected: modelData === Audio.sink
            onClicked: Audio.use(modelData)
        }
    }
    UiText {
        visible: Audio.outputs.length === 0
        text: "No audio outputs found"
        color: Theme.textMuted
    }

    LinkRow {
        text: "Sound settings"
        onClicked: panel.shell.run(["pavucontrol"])
    }
}
