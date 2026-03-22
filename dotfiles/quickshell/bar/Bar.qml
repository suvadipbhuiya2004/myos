
pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell
import Quickshell.Io

import "../module"

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

    property string focusedWindow: "Desktop"

    // [NEW] State variables for Niri workspaces
    property string activeWorkspace: ""
    property var workspacesData: []

    // --- 1. Quickshell Process: Wi-Fi ---
    Process {
        id: wifiProc
        command: ["bash", Quickshell.env("HOME") + "/myos/dotfiles/quickshell/bar/wifi.sh", mainWindow.maxWifiLen.toString()]
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
        command: ["bash", Quickshell.env("HOME") + "/myos/dotfiles/quickshell/bar/bluetooth.sh", mainWindow.maxBtLen.toString()]
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

    // --- 3. [NEW] Quickshell Process: Niri Workspaces ---
    Process {
        id: niriProc
        // REPLACE THIS WITH YOUR ACTUAL SCRIPT PATH
        command: ["bash", Quickshell.env("HOME") + "/myos/dotfiles/quickshell/bar/niri_window_and_workspace.sh"]
        running: true
        
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() === "") return;
                
                try {
                    let data = JSON.parse(line);
                    mainWindow.activeWorkspace = data.active_workspace.toString();
                    mainWindow.workspacesData = data.windows_per_workspace;
                } catch (e) {
                    console.log("JSON Parse Error:", e, "Line:", line);
                }
            }
        }
    }

    // --- 4. Timer to loop the updates ---
    // Note: Niri process is not here because it uses an event stream and never stops
    Timer {
        interval: 2000 
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
        // [NEW] CENTER: Niri Workspaces
        // ==========================================
        RowLayout {
            // This anchors the entire RowLayout to the exact center of the bar
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: mainWindow.workspacesData

                delegate: Rectangle {

                    required property var modelData
                    readonly property bool isActive: modelData.workspace_id.toString() === mainWindow.activeWorkspace

                    width: wsText.implicitWidth + 16
                    height: 24
                    radius: 4
                    color: isActive ? "#89b4fa" : "#313244"

                    Text {
                        id: wsText
                        anchors.centerIn: parent
                        text: modelData.workspace_id + " | " + modelData.count
                        color: isActive ? "#11111b" : "#cdd6f4"
                        font.bold: isActive
                        font.pixelSize: 14
                    }
                }
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
