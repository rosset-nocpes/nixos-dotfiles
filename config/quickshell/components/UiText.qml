import QtQuick
import ".."

Text {
    property int size: 13
    property int weight: Font.Normal
    color: Theme.text
    font.family: Theme.font
    font.pixelSize: size
    font.weight: weight
    elide: Text.ElideRight
    maximumLineCount: 1
}
