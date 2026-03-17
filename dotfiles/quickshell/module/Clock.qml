
import QtQuick

Text {
    id: clockText
    
    // Default fallback styles (can be overridden by whatever file uses this module)
    color: "white"
    font.pixelSize: 16

    // The function that formats the time (hh:mm AP gives 12-hour with AM/PM)
    function updateTime() {
        clockText.text = Qt.formatTime(new Date(), "hh:mm AP")
    }

    // Set the time immediately when the component loads
    Component.onCompleted: updateTime()

    // Update the time every 1000 milliseconds (1 second)
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: updateTime()
    }
}
