
//@ pragma UseQApplication
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io // This is required for the IpcHandler

import "bar"
import "lock_screen"

ShellRoot {
    // 1. Launch the Status Bar immediately
    Bar { }

    // 2. Keep the Lock Screen on standby
    Loader {
        id: lockScreenLoader
        active: false // Keep it hidden until triggered
        
        sourceComponent: Component {
            Lock_screen {
                // Listens for the signal we added to your LockScreen.qml
                onUnlockSuccessful: lockScreenLoader.active = false
            }
        }
    }

    // 3. The IPC Listener
    IpcHandler {
        target: "system" // The ID name we will use in the terminal
        
        // The function that actually turns the lock screen on
        function lock(): void {
            lockScreenLoader.active = true;
        }
    }
}


