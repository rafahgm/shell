import QtQuick
import Quickshell

import qs.Common
import qs.Modules.Linux.Bar
import qs.Modules.Linux.Notifications
import qs.Modules.Linux.OnScreenDisplay

Scope {
    PanelLoader {
        extraCondition: !Config.options.bar.vertical
        component: Bar {}
    }
    PanelLoader {
        component: NotificationPopup {}
    }
        PanelLoader { component: OnScreenDisplay {} }
}
