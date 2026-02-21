import QtQuick
import Quickshell
import QtQuick.Layouts

import qs.Common
import qs.Common.Widgets
import qs.Services

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool verbose
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        StyledText {
            font.pixelSize: Appearance.font.pixelSize.large
            font.family: Appearance.font.family.monospace
            color: Appearance.colors.colOnLayer1
            text: root.verbose ? DateTimeService.time : DateTimeService.shortTime
        }

        StyledText {
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: "•"
        }

        StyledText {
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: root.verbose ? DateTimeService.longDate : DateTimeService.shortDate
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: !Config.options.bar.tooltips.clickToShow

        ClockWidgetPopup {
            hoverTarget: mouseArea
        }
    }
}