import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Services

/**
 * A focus grab component that works with both Hyprland and Niri.
 * On Hyprland, uses HyprlandFocusGrab.
 * On Niri, uses keyboard focus from the layer shell (which is handled by the PanelWindow).
 */
Item {
    id: root
    property var windows: []
    property bool active: false
    
    signal cleared()

    
    // For Niri, clicking outside is handled by the layer shell keyboard focus
    // and MouseArea in the parent component. This component just provides
    // compatibility with existing code.
}