
import QtQuick
import QtQuick.Controls 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

import "../module" 

WlSessionLock {
    id: lock
    locked: true

    signal unlockSuccessful()

    // --- FAIL SAFE 1: The Cooldown Timer ---
    // Safely restarts PAM after a brief delay to prevent process crashes
    Timer {
        id: pamRestartTimer
        interval: 600 // Wait 0.6 seconds
        onTriggered: {
            passwordInput.text = "";
            passwordInput.enabled = true; // Unlock the text box
            passwordInput.forceActiveFocus(); // Force cursor back into the box
            pam.start();
        }
    }

    PamContext {
        id: pam
        
        Component.onCompleted: pam.start()

        onCompleted: (result) => {
            if (result === PamResult.Success) {
                lock.locked = false; 
                unlockSuccessful(); 
            } else {
                console.log("Wrong password!");
                passwordInput.placeholderText = "Incorrect password...";
                passwordBackground.border.color = "#ff5555";
                
                // Start the cooldown timer instead of restarting PAM instantly
                pamRestartTimer.start();
            }
        }
    }

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
                        interval: 5000 
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
                        placeholderText: "Password"
                        placeholderTextColor: "#aaaaaa"
                        color: "white"
                        font.pixelSize: 18
                        echoMode: TextInput.Password
                        focus: true 
                        horizontalAlignment: TextInput.AlignHCenter
                        
                        background: Rectangle {
                            id: passwordBackground
                            color: "#44ffffff"
                            radius: 8
                            border.color: passwordInput.activeFocus ? "#ffffff" : "#88ffffff"
                            border.width: passwordInput.activeFocus ? 2 : 1
                            Behavior on border.color { ColorAnimation { duration: 200 } }
                        }
                        
                        onAccepted: {
                            // --- FAIL SAFE 2 & 3: Input Locking ---
                            if (text === "" || !enabled) return; // Ignore empty/spam enter presses
                            
                            enabled = false; // Lock the text box while authenticating
                            passwordBackground.border.color = "#ffffff";
                            pam.respond(text);
                        }
                    }
                }
            }
        }
    }
}
