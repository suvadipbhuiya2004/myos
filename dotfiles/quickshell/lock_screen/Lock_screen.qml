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

    // --- Global State Variables ---
    property bool isError: false
    property bool isAuthenticating: false
    property string currentUsername: "suvadip" // Default user

    // --- DISPLAY SLEEP LOGIC ---
    Process {
        id: powerOffMonitors
        command: ["niri", "msg", "action", "power-off-monitors"]
    }

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
        user: root.currentUsername
        
        // Start PAM when the component is ready
        Component.onCompleted: pam.start()

        onCompleted: (result) => {
            if (result === PamResult.Success) {
                lock.locked = false; 
                root.unlockSuccessful(); 
            } else {
                root.isError = true; 
                pamRestartTimer.start();
            }
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        surface: Component {
            WlSessionLockSurface {
                id: lockSurface
                
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
                            text: root.currentUsername
                            placeholderText: "Username"
                            placeholderTextColor: "#aaaaaa"
                            color: "white"
                            font.pixelSize: 18
                            horizontalAlignment: TextInput.AlignHCenter
                            
                            onTextChanged: root.currentUsername = text
                            
                            Keys.onPressed: displaySleepTimer.restart()
                            
                            background: Rectangle {
                                color: "#44ffffff"
                                radius: 8
                                border.color: usernameInput.activeFocus ? "#ffffff" : "#88ffffff"
                                border.width: usernameInput.activeFocus ? 2 : 1
                            }

                            onAccepted: passwordInput.forceActiveFocus()
                        }

                        TextField {
                            id: passwordInput
                            width: parent.width
                            
                            placeholderText: root.isError ? "Incorrect password..." : "Password"
                            placeholderTextColor: root.isError ? "#ffaaaa" : "#aaaaaa"
                            enabled: !root.isAuthenticating
                            
                            color: "white"
                            font.pixelSize: 18
                            echoMode: TextInput.Password
                            focus: true 
                            horizontalAlignment: TextInput.AlignHCenter

                            Keys.onPressed: displaySleepTimer.restart()
                            
                            onEnabledChanged: {
                                if (enabled) {
                                    passwordInput.text = "";
                                    passwordInput.forceActiveFocus();
                                }
                            }
                            
                            background: Rectangle {
                                color: "#44ffffff"
                                radius: 8
                                border.color: root.isError ? "#ff5555" : (passwordInput.activeFocus ? "#ffffff" : "#88ffffff")
                                border.width: passwordInput.activeFocus ? 2 : 1
                                Behavior on border.color { ColorAnimation { duration: 200 } }
                            }
                            
                            onAccepted: {
                                if (text === "" || !enabled) return; 
                                
                                root.isAuthenticating = true;
                                root.isError = false;
                                pam.respond(text);
                                text = ""; // Clear password field
                            }
                        }
                    }
                }
            }
        }
    }
}
