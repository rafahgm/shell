import QtQuick
import Quickshell

import qs.Common
import qs.Modules.Linux.Bar
import qs.Modules.Linux.Notifications
import qs.Modules.Linux.MediaControls
import qs.Modules.Linux.OnScreenDisplay
import qs.Modules.Linux.Polkit
import qs.Modules.Linux.RightSidebar

Scope {
    PanelLoader {
        extraCondition: !Config.options.bar.vertical
        component: Bar {}
    }
    PanelLoader {
        component: NotificationPopup {}
    }
    PanelLoader {
        component: MediaControls {}
    }
    PanelLoader {
        component: OnScreenDisplay {}
    }
    PanelLoader {
        component: Polkit {}
    }
    PanelLoader {
        component: RightSidebar {}
    }
}
