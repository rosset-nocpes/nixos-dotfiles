pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon: keeps a history for the clock panel and a short-lived toast.
Singleton {
    id: notifs
    property bool dnd: false
    property var toast: null
    property var received: ({})
    readonly property var list: server.trackedNotifications.values.slice().reverse()

    function clearAll() {
        for (const notification of server.trackedNotifications.values.slice())
            notification.dismiss();
    }
    function age(notification, now) {
        const minutes = Math.floor((now - (received[notification.id] ?? now)) / 60000);
        return minutes < 1 ? "now" : minutes < 60 ? minutes + "m ago" : Math.floor(minutes / 60) + "h ago";
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        onNotification: notification => {
            notification.tracked = true;
            notifs.received[notification.id] = Date.now();
            notification.closed.connect(() => {
                delete notifs.received[notification.id];
                if (notifs.toast === notification) notifs.toast = null;
            });
            if (!notifs.dnd || notification.urgency === NotificationUrgency.Critical) {
                notifs.toast = notification;
                toastTimer.interval = notification.expireTimeout > 0 ? notification.expireTimeout : 5000;
                toastTimer.restart();
            }
        }
    }
    Timer {
        id: toastTimer
        onTriggered: notifs.toast = null
    }
}
