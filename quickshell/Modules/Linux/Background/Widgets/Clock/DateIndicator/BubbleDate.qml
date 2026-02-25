pragma ComponentBehavior: Bound

import qs.Services
import qs.Common
import qs.Common.Widgets
import QtQuick

Item {
    id: root
    property bool isMonth: false
    property real targetSize: 0
    property alias text: bubbleText.text

    text: Qt.locale().toString(DateTimeService.clock.date, root.isMonth ? "MM" : "d")

    MaterialShape {
        id: bubble
        z: 5
        // sides: root.isMonth ? 1 : 4
        shape: root.isMonth ? MaterialShape.Shape.Pill : MaterialShape.Shape.Pentagon
        anchors.centerIn: parent
        color: root.isMonth ? Appearance.colors.colSecondaryContainer : Appearance.colors.colTertiaryContainer
        implicitSize: targetSize
    }

    StyledText {
        id: bubbleText
        z: 6
        anchors.centerIn: parent
        color: root.isMonth ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnTertiaryContainer
        font {
            family: Appearance.font.family.expressive
            pixelSize: 30
            weight: Font.Black
        }
    }
}