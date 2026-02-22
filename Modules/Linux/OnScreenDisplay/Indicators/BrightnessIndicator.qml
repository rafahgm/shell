import QtQuick
import Quickshell

import qs.Services
import qs.Modules.Linux.OnScreenDisplay

OnScreenDisplayValueIndicator {
    id: root
    property var focusedScreen: Quickshell.screens.find(s => s.name === NiriService.currentOutput)
    property var brightnessMonitor: BrightnessService.getMonitorForScreen(focusedScreen)

    icon: HyprsunsetService.active ? "routine" : "light_mode"
    rotateIcon: true
    scaleIcon: true
    name: TranslationService.tr("Brightness")
    value: root.brightnessMonitor?.brightness ?? 50
}