pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery state and power profiles (power-profiles-daemon).
Singleton {
    id: battery
    readonly property var device: UPower.displayDevice
    readonly property bool present: device.ready && device.isPresent
    readonly property real level: device.percentage
    readonly property string percent: Math.round(level * 100) + "%"
    readonly property bool charging: device.state === UPowerDeviceState.Charging
    readonly property bool low: UPower.onBattery && level < 0.2
    readonly property string status: charging ? "Charging"
        : device.state === UPowerDeviceState.FullyCharged ? "Fully charged"
        : UPower.onBattery ? "Running on battery" : "Plugged in"
    readonly property real seconds: charging ? device.timeToFull : UPower.onBattery ? device.timeToEmpty : 0
    readonly property string remaining: seconds <= 0 ? status : duration(seconds) + (charging ? " until full" : " left")

    readonly property var modes: [
        { profile: PowerProfile.PowerSaver, title: "Power saver", subtitle: "Extend battery life" },
        { profile: PowerProfile.Balanced, title: "Balanced", subtitle: "Everyday performance and efficiency" },
        { profile: PowerProfile.Performance, title: "Performance", subtitle: "Prioritize speed · uses more power" }
    ].filter(mode => mode.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)
    readonly property int mode: PowerProfiles.profile
    function setMode(profile) { PowerProfiles.profile = profile; }

    function duration(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.round(seconds % 3600 / 60);
        return hours > 0 ? `${hours} hr ${minutes} min` : `${minutes} min`;
    }
}
