
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell
import Quickshell.Io

PanelWindow {
    id: mainWindow
    
    implicitWidth: 1920
    implicitHeight: 35
    
    anchors {
        top: true
        bottom: false
        left: true
        right: true
    }

    // --- State Variables ---
    property int maxWifiLen: 5
    property int maxBtLen: 5
    
    property string wifiIcon: "󰤭"
    property string wifiText: "Loading..."
    
    property string btIcon: "󰂲"
    property string btText: "Loading..."

    // New property for the focused window
    property string focusedWindow: "Desktop"

    // --- 1. Quickshell Process: Wi-Fi ---
    Process {
        id: wifiProc
        command: ["bash", "/home/suvadip/myos/dotfiles/quickshell/bar/wifi.sh", mainWindow.maxWifiLen.toString()]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim().split("__SEP__")
                if (output.length === 2) {
                    mainWindow.wifiIcon = output[0]
                    mainWindow.wifiText = output[1]
                }
            }
        }
    }

    // --- 2. Quickshell Process: Bluetooth ---
    Process {
        id: btProc
        command: ["bash", "/home/suvadip/myos/dotfiles/quickshell/bar/bluetooth.sh", mainWindow.maxBtLen.toString()]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim().split("__SEP__")
                if (output.length === 2) {
                    mainWindow.btIcon = output[0]
                    mainWindow.btText = output[1]
                }
            }
        }
    }





    // --- 4. Timer to loop the updates ---
    
    Timer {
        interval: 2000 // Reduced to 2s for a snappier window title update
        running: true
        repeat: true
        onTriggered: {
            wifiProc.running = true
            btProc.running = true
        }
    }

    // --- Top Bar Background & Layout ---
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e" 

        // ==========================================
        // LEFT SIDE: Clock & Focused Window
        // ==========================================
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            spacing: 20

            Clock {
                format: "hh:mm AP  |  d ddd"
                color: "#cdd6f4"
                font.pixelSize: 16
                font.bold: true
            }


        }

        // ==========================================
        // RIGHT SIDE: Wi-Fi & Bluetooth Modules
        // ==========================================
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            spacing: 25

            // --- UI: Wi-Fi Module ---
            RowLayout {
                spacing: 8
                Text {
                    text: mainWindow.wifiIcon 
                    color: "#89b4fa" 
                    font.pixelSize: 18 
                }
                Text {
                    text: mainWindow.wifiText 
                    color: "#cdd6f4"
                    font.pixelSize: 14
                }
            }

            // --- UI: Bluetooth Module ---
            RowLayout {
                spacing: 8
                Text {
                    text: mainWindow.btIcon 
                    color: "#f38ba8" 
                    font.pixelSize: 18
                }
                Text {
                    text: mainWindow.btText 
                    color: "#cdd6f4"
                    font.pixelSize: 14
                }
            }
        }
    }
}
