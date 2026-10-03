pragma Singleton
import QtQuick
import Quickshell

// Values come from the BranchOS design in Paper. Qt hex colours are #AARRGGBB.
Singleton {
    readonly property string font: "Inter"

    readonly property color text: "#ffffff"
    readonly property color textMuted: "#c4cdd2"
    readonly property color textDim: "#d1d8de"
    readonly property color textFaint: "#59ffffff"

    readonly property color pill: "#57404952"
    readonly property color pillBorder: "#47ffffff"
    readonly property color pillActive: "#33ffffff"

    readonly property color card: "#d6252e37"
    readonly property color cardBorder: "#42ffffff"
    readonly property color surface: "#16ffffff"
    readonly property color surfaceBorder: "#26ffffff"
    readonly property color row: "#0affffff"
    readonly property color rowSelected: "#21ffffff"
    readonly property color track: "#22ffffff"
    readonly property color divider: "#22ffffff"
    readonly property color warning: "#ffb4a2"

    // Light "on" state: tiles, toggles, filled sliders.
    readonly property color accent: "#e8edf0"
    readonly property color accentText: "#29343d"
    readonly property color accentTextMuted: "#52606b"

    readonly property int barHeight: 60
    readonly property int pillHeight: 40
    readonly property int popupGap: 12
    readonly property int popupWidth: 432
}
