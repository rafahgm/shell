pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland

import qs.Services
import qs.Common
import qs.Common.Widgets
import qs.Common.Functions

Scope {
    id: root
    property bool visible: false
    readonly property MprisPlayer activePlayer: MprisService.activePlayer
    readonly property var realPlayers: MprisService.players
    readonly property var meaningfulPlayers: filterDuplicatePlayers(realPlayers)
    readonly property real widgetWidth: Appearance.sizes.mediaControlsWidth
    readonly property real widgetHeight: Appearance.sizes.mediaControlsHeight
    property real popupRounding: Appearance.rounding.screenRounding
    property list<real> visualizerPoints: []

    function filterDuplicatePlayers(players) {
        let filtered = [];
        let used = new Set();

        for (let i = 0; i < players.length; ++i) {
            if (used.has(i))
                continue;
            let p1 = players[i];
            let group = [i];

            // Find duplicates by trackTitle prefix
            for (let j = i + 1; j < players.length; ++j) {
                let p2 = players[j];
                if (p1.trackTitle && p2.trackTitle && (p1.trackTitle.includes(p2.trackTitle) || p2.trackTitle.includes(p1.trackTitle)) || (p1.position - p2.position <= 2 && p1.length - p2.length <= 2)) {
                    group.push(j);
                }
            }

            // Pick the one with non-empty trackArtUrl, or fallback to the first
            let chosenIdx = group.find(idx => players[idx].trackArtUrl && players[idx].trackArtUrl.length > 0);
            if (chosenIdx === undefined)
                chosenIdx = group[0];

            filtered.push(players[chosenIdx]);
            group.forEach(idx => used.add(idx));
        }
        return filtered;
    }

    Process {
        id: cavaProc
        running: mediaControlsLoader.active
        onRunningChanged: {
            if (!cavaProc.running) {
                root.visualizerPoints = [];
            }
        }
        command: ["cava", "-p", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/cava/raw_output_config.txt`]
        stdout: SplitParser {
            onRead: data => {
                // Parse `;`-separated values into the visualizerPoints array
                let points = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p));
                root.visualizerPoints = points;
            }
        }
    }

    Loader {
        id: mediaControlsLoader
        active: GlobalStates.mediaControlsOpen

        Timer {
            id: closingTimer
            interval: 350
            repeat: false
            onTriggered: {
                if (!GlobalStates.mediaControlsOpen)
                    mediaControlsLoader.active = false;
            }
        }

        Connections {
            target: GlobalStates
            function onMediaControlsOpenChanged() {
                if (GlobalStates.mediaControlsOpen) {
                    mediaControlsLoader.active = true;
                    closingTimer.stop();
                } else {
                    closingTimer.restart();
                }
            }
        }

        sourceComponent: PanelWindow {
            id: panelWindow
            visible: true

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            color: "transparent"
            WlrLayershell.namespace: "quickshell:mediaControls"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: GlobalStates.mediaControlsOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            FocusScope {
                id: inputScope
                anchors.fill: parent
                focus: true

                Component.onCompleted: focusTimer.start()

                Timer {
                    id: focusTimer
                    interval: 100
                    repeat: false
                    onTriggered: {
                        inputScope.forceActiveFocus();
                    }
                }

                Keys.onSpacePressed: {
                    if (root.activePlayer?.canTogglePlaying) {
                        root.activePlayer.togglePlaying();
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: GlobalStates.mediaControlsOpen = false
                }
                Item {
                    id: cardArea

                    readonly property real screenH: panelWindow.screen?.height ?? 1080

                    width: root.widgetWidth
                    height: playerColumnLayout.implicitHeight

                    anchors.horizontalCenter: parent.horizontalCenter

                    y: 0
                    opacity: 0
                    scale: 0.9
                    transformOrigin: Item.Bottom

                    states: State {
                        name: "visible"
                        when: GlobalStates.mediaControlsOpen
                        PropertyChanges {
                            target: cardArea
                            y: Appearance.sizes.barHeight
                            opacity: 1
                            scale: 1
                        }
                    }

                    transitions: [
                        Transition {
                            to: "visible"
                            NumberAnimation {
                                properties: "y"
                                duration: 350
                                easing.type: Easing.OutQuint
                            }
                            NumberAnimation {
                                properties: "opacity"
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                properties: "scale"
                                duration: 350
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.2
                            }
                        },
                        Transition {
                            from: "visible"
                            NumberAnimation {
                                properties: "y"
                                duration: 250
                                easing.type: Easing.InQuint
                            }
                            NumberAnimation {
                                properties: "opacity"
                                duration: 200
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                properties: "scale"
                                duration: 250
                                easing.type: Easing.InBack
                                easing.overshoot: 1.0
                            }
                        }
                    ]

                    ColumnLayout {
                        id: playerColumnLayout
                        spacing: -Appearance.sizes.elevationMargin // Shadow overlap okay

                        Repeater {
                            model: ScriptModel {
                                values: root.meaningfulPlayers
                            }
                            delegate: PlayerControl {
                                required property MprisPlayer modelData
                                player: modelData
                                visualizerPoints: root.visualizerPoints
                                implicitWidth: root.widgetWidth
                                implicitHeight: root.widgetHeight
                                radius: root.popupRounding
                            }
                        }

                        Item {
                            // No player placeholder
                            Layout.alignment: {
                                if (panelWindow.anchors.left)
                                    return Qt.AlignLeft;
                                if (panelWindow.anchors.right)
                                    return Qt.AlignRight;
                                return Qt.AlignHCenter;
                            }
                            Layout.leftMargin: Appearance.sizes.gaps
                            Layout.rightMargin: Appearance.sizes.gaps
                            visible: root.meaningfulPlayers.length === 0
                            implicitWidth: placeholderBackground.implicitWidth + Appearance.sizes.elevationMargin
                            implicitHeight: placeholderBackground.implicitHeight + Appearance.sizes.elevationMargin

                            StyledRectangularShadow {
                                target: placeholderBackground
                            }

                            Rectangle {
                                id: placeholderBackground
                                anchors.centerIn: parent
                                color: Appearance.colors.colLayer0
                                radius: root.popupRounding
                                property real padding: 20
                                implicitWidth: placeholderLayout.implicitWidth + padding * 2
                                implicitHeight: placeholderLayout.implicitHeight + padding * 2

                                ColumnLayout {
                                    id: placeholderLayout
                                    anchors.centerIn: parent

                                    StyledText {
                                        text: TranslationService.tr("No active player")
                                        font.pixelSize: Appearance.font.pixelSize.large
                                    }
                                    StyledText {
                                        color: Appearance.colors.colSubtext
                                        text: TranslationService.tr("Make sure your player has MPRIS support\nor try turning off duplicate player filtering")
                                        font.pixelSize: Appearance.font.pixelSize.small
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "mediaControls"

        function toggle(): void {
            GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen;
            if (GlobalStates.mediaControlsOpen)
                NotificationsService.timeoutAll();
        }

        function close(): void {
            GlobalStates.mediaControlsOpen = false;
        }

        function open(): void {
            GlobalStates.mediaControlsOpen = true;
            NotificationsService.timeoutAll();
        }
    }
}
