
pragma ComponentBehavior: Bound
import QtQuick

Text {
    id: timeText
    
    // By exposing this property, the Bar can tell the Clock how to look
    property string format: "hh:mm AP" 

    color: "white"
    font.pixelSize: 16

    function updateTime() {
        // Qt.formatDateTime can handle both clock times and calendar dates
        timeText.text = Qt.formatDateTime(new Date(), format)
    }

    Component.onCompleted: updateTime()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: timeText.updateTime()
    }
}
