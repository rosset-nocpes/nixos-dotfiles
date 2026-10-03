import QtQuick
import ".."

// Line icons drawn on a 24-unit grid. "S/>" marks stroked shapes, "F/>" filled ones,
// and {c}/{w} insert the colour and stroke width directly.
Image {
    id: icon
    property string name
    property color color: Theme.text
    property real size: 18
    property real stroke: 1.8

    readonly property var shapes: ({
        wifi: '<path d="M3 9q9-8 18 0M6 13q6-5 12 0m-9 4q3-3 6 0" S/><circle cx="12" cy="20.2" r="1.3" F/>',
        wifiOff: '<path d="M3 9q9-8 18 0M6 13q6-5 12 0m-9 4q3-3 6 0M4 3l16 18" S/>',
        bluetooth: '<path d="m7 7 10 10-5 4V3l5 4L7 17" S/>',
        shield: '<path d="M12 3 5 6v5c0 4.5 3 8.3 7 10 4-1.7 7-5.5 7-10V6l-7-3Z" S/>',
        moon: '<path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5Z" S/>',
        sun: '<circle cx="12" cy="12" r="4" S/><path d="M12 2v2m0 16v2M4.9 4.9l1.4 1.4m11.4 11.4 1.4 1.4M2 12h2m16 0h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" S/>',
        sunFilled: '<circle cx="12" cy="12" r="4" F/><path d="M12 2v2m0 16v2M4.9 4.9l1.4 1.4m11.4 11.4 1.4 1.4M2 12h2m16 0h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" S/>',
        speaker: '<path d="M11 5 6 9H3v6h3l5 4V5Zm4 3a6 6 0 0 1 0 8m3-11a10 10 0 0 1 0 14" S/>',
        speakerFilled: '<path d="M4 9h3l5-4v14l-5-4H4V9Z" F/><path d="M16 9a4 4 0 0 1 0 6m2.5-8.5a7.5 7.5 0 0 1 0 11" S/>',
        speakerMuted: '<path d="M11 5 6 9H3v6h3l5 4V5Zm5 4 5 6m0-6-5 6" S/>',
        sliders: '<path d="M4 7h16M4 17h16" S/><rect x="7" y="4" width="5" height="6" rx="2.5" fill="#758088" stroke="{c}" stroke-width="{w}"/><rect x="14" y="14" width="5" height="6" rx="2.5" fill="#758088" stroke="{c}" stroke-width="{w}"/>',
        previous: '<path d="M6 6h2v12H6zM19 6v12l-9-6z" F/>',
        next: '<path d="M16 6h2v12h-2zM5 6v12l9-6z" F/>',
        play: '<path d="M7 5v14l12-7z" F/>',
        pause: '<path d="M7 5h3.5v14H7zM13.5 5H17v14h-3.5z" F/>',
        check: '<path d="m5 12.5 4.5 4.5L19 7.5" S/>',
        chevronLeft: '<path d="m15 6-6 6 6 6" S/>',
        chevronRight: '<path d="m9 6 6 6-6 6" S/>',
        close: '<path d="M7 7l10 10M17 7 7 17" S/>',
        plus: '<path d="M12 5v14M5 12h14" S/>',
        lock: '<rect x="5" y="11" width="14" height="10" rx="2.5" S/><path d="M8 11V8a4 4 0 0 1 8 0v3" S/>',
        power: '<path d="M12 3v9M6.3 7a8 8 0 1 0 11.4 0" S/>'
    })

    function hex(value) { return Math.round(value * 255).toString(16).padStart(2, "0"); }
    readonly property string rgb: "#" + hex(color.r) + hex(color.g) + hex(color.b)

    width: size
    height: size
    sourceSize: Qt.size(size, size)
    opacity: color.a
    smooth: true
    source: !shapes[name] ? "" : "data:image/svg+xml;utf8," + encodeURIComponent(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
        + shapes[name]
            .replace(/S\/>/g, `fill="none" stroke="${rgb}" stroke-width="${stroke}" stroke-linecap="round" stroke-linejoin="round"/>`)
            .replace(/F\/>/g, `fill="${rgb}"/>`)
            .replace(/{c}/g, rgb)
            .replace(/{w}/g, stroke)
        + '</svg>')
}
