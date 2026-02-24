
import qs.Services
import qs.Common
import qs.Common.Widgets
import QtQuick

Rectangle {
    id: rect
    readonly property string dialStyle: Config.options.background.widgets.clock.cookie.dialNumberStyle

    StyledText {
        anchors.centerIn: parent
        color: Appearance.colors.colSecondaryHover
        text: Qt.locale().toString(DateTimeService.clock.date, "dd")
        font {
            family: Appearance.font.family.expressive
            pixelSize: 20
            weight: 1000
        }
    }
}