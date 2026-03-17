// This line tells Qt6 to strictly enforce modern scoping rules (fixes the warnings)
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls 2.15
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Io // Required to run shell commands like niri msg

import "../module" 

// 1. Wrap everything in an Item so WlSessionLock doesn't complain about multiple objects
Item {
    id: root

    signal unlockSuccessful()

    // 2. Global State Variables (Fixes the Unqualified Access warning)
    property bool isError: false
    property bool isAuthenticating: false

    // --- DISPLAY SLEEP LOGIC ---
    // Command to tell Niri to put the displays to sleep
    Process {
        id: powerOffMonitors
        command: ["niri", "msg", "action", "power-off-monitors"]
    }

    // Starts counting the exact millisecond the lock screen appears
    Timer {
        id: displaySleepTimer
        interval: 60000 // 60 seconds
        running: true
        repeat: false
        onTriggered: powerOffMonitors.running = true
    }
    // ---------------------------

    Timer {
        id: pamRestartTimer
        interval: 600
        onTriggered: {
            root.isError = false;
            root.isAuthenticating = false;
            pam.start();
        }
    }

    PamContext {
        id: pam
        Component.onCompleted: pam.start()

        onCompleted: (result) => {
            if (result === PamResult.Success) {
                lock.locked = false; 
                root.unlockSuccessful(); 
            } else {
                root.isError = true; // Tell the UI we failed
                pamRestartTimer.start();
            }
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        surface: Component {
            WlSessionLockSurface {
                Item {
                    anchors.fill: parent

                    Rectangle {
                        anchors.fill: parent
                        color: "#0f0f14" 
                    }

                    Image {
                        id: wallpaperImage
                        anchors.fill: parent
                        source: "file:///tmp/wallpaper.jpg"
                        fillMode: Image.PreserveAspectCrop
                        cache: false 

                        Timer {
                            interval: 300000 
                            running: true
                            repeat: true
                            onTriggered: {
                                wallpaperImage.source = "file:///tmp/wallpaper.jpg?t=" + new Date().getTime();
                            }
                        }
                                                
                        Rectangle {
                            anchors.fill: parent
                            color: "#99000000" 
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 24
                        width: 320

                        Clock {
                            color: "white"
                            font.pixelSize: 64 
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        TextField {
                            id: usernameInput
                            width: parent.width
                            placeholderText: "suvadip"
                            placeholderTextColor: "#aaaaaa"
                            color: "white"
                            font.pixelSize: 18
                            horizontalAlignment: TextInput.AlignHCenter
                            KeyNavigation.tab: passwordInput 
                            
                            // Reset the display sleep timer if you type here
                            Keys.onPressed: displaySleepTimer.restart()
                            
                            background: Rectangle {
                                color: "#44ffffff"
                                radius: 8
                                border.color: usernameInput.activeFocus ? "#ffffff" : "#88ffffff"
                                border.width: usernameInput.activeFocus ? 2 : 1
                            }
                        }

                        TextField {
                            id: passwordInput
                            width: parent.width
                            
                            // React dynamically to the state variables
                            placeholderText: root.isError ? "Incorrect password..." : "Password"
                            placeholderTextColor: root.isError ? "#ffaaaa" : "#aaaaaa"
                            enabled: !root.isAuthenticating // Lock input while checking
                            
                            color: "white"
                            font.pixelSize: 18
                            echoMode: TextInput.Password
                            focus: true 
                            horizontalAlignment: TextInput.AlignHCenter

                            // Reset the display sleep timer if you type here
                            Keys.onPressed: displaySleepTimer.restart()
                            
                            // Automatically grab focus again when the error timer finishes
                            onEnabledChanged: {
                                if (enabled) forceActiveFocus();
                            }
                            
                            background: Rectangle {
                                id: passwordBackground
                                color: "#44ffffff"
                                radius: 8
                                // Turn red if error, otherwise use normal focus colors
                                border.color: root.isError ? "#ff5555" : (passwordInput.activeFocus ? "#ffffff" : "#88ffffff")
                                border.width: passwordInput.activeFocus ? 2 : 1
                                Behavior on border.color { ColorAnimation { duration: 200 } }
                            }
                            
                            onAccepted: {
                                if (text === "" || !enabled) return; 
                                
                                root.isAuthenticating = true;
                                root.isError = false;
                                pam.respond(text);
                                text = ""; // Clear text box instantly so password isn't lingering
                            }
                        }
                    }
                }
            }
        }
    }
}
