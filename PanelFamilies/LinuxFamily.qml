import QtQuick
import Quickshell

import qs.Common
import qs.Modules.Linux.Bar
import qs.Modules.Linux.Notifications

Scope {
    PanelLoader {
        extraCondition: !Config.options.bar.vertical
        component: Bar {}
    }
    PanelLoader {
        component: NotificationPopup {}
    }
}
