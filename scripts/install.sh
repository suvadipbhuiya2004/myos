#!/bin/bash


BOLD="\e[1m"
BOLD_RESET="\e[0m"

PACMAN_PKGS=(
    "awww"                   # Wallpaper daemon
    "bat"                    # A cat clone with wings
    "bluez"                  # Bluetooth stack
    "bluez-utils"            # Bluetooth control (bluetoothctl)
    "brightnessctl"          # Backlight control
    "code"                   # Visual Studio Code (OSS version)
    "emacs-wayland"          # Extensible editor (Wayland version)
    "fd"                     # Fast search tool
    "fish"                   # Shell
    "fzf"                    # Fuzzy finder
    "gemini-cli"             # Google Gemini CLI
    "git"                    # Version control
    "helix"                  # Modal text editor
    "kitty"                  # Terminal emulator
    "mako"                   # Notification daemon
    "networkmanager"         # Network management (nmcli)
    "niri"                   # Wayland compositor
    "pavucontrol"            # PulseAudio volume control
    "pipewire"               # Audio/video server
    "pipewire-audio"         # Audio support
    "playerctl"              # Media player control
    "qrencode"
    "ripgrep"                # Fast grep tool
    "rustup"                 # Rust toolchain installer
    "starship"               # Shell prompt
    "swayidle"               # Idle management daemon
    "ttf-bitstream-vera"     # Bitstream Vera fonts
    "ttf-carlito"            # Carlito fonts
    "ttf-dejavu"             # DejaVu fonts
    "ttf-firacode-nerd"      # FiraCode Nerd Font
    "ttf-liberation"         # Liberation fonts
    "ttf-linux-libertine"    # Linux Libertine fonts
    "ttf-meslo-nerd"         # Meslo Nerd Font
    "ttf-opensans"           # Open Sans fonts
    "upower"                 # Battery/power management
    "vlc"                    # Media player
    "vivaldi"                # Vivaldi web browser
    "wireplumber"            # PipeWire session manager
    "wl-clip-persist"        # Wayland clipboard persistence
    "yazi"                   # Terminal file manager
    "zed"                    # High-performance code editor
    "zig"                    # Zig programming language
    "zip"                    # Compression utility
    "zoxide"              # Smarter cd command
)

AUR_PKGS=(
    "blesh"
    "bibata-cursor-theme-bin"
    "quickshell-git"   # Desktop shell/bar
    "vicinae-bin"      # Launcher and extensions
)

# Helper function to check if package is installed
is_installed() {
    pacman -Qi "$1" &> /dev/null
}

echo -e  "------------------------------------------"
echo -e  "     ${BOLD} MyOS Dependency Installer ${BOLD_RESET}    "
echo -e  "------------------------------------------"

echo
echo


# 1. Install Pacman Packages
echo -e "${BOLD}Installing official packages...${BOLD_RESET}"
echo
for pkg in "${PACMAN_PKGS[@]}"; do
    if is_installed "$pkg"; then
        echo "[SKIP] $pkg is already installed."
    else
        echo "[INST] Installing $pkg..."
        sudo pacman -S --noconfirm --needed "$pkg"
    fi
done

echo
echo

# 2. Setup Paru
if ! command -v paru &> /dev/null; then
    echo "paru (AUR helper) not found!"
    read -p "Would you like to install 'paru' now? (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru && makepkg -si --noconfirm
        cd -
    else
        echo "Skipping AUR packages as paru is missing."
        exit 0
    fi
fi

# 3. Install AUR Packages
echo -e "${BOLD}Installing AUR packages...${BOLD_RESET}"
echo
for pkg in "${AUR_PKGS[@]}"; do
    if is_installed "$pkg"; then
        echo "[SKIP] $pkg (AUR) is already installed."
    else
        read -p "Install AUR package: $pkg? (y/N): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "[INST] Installing $pkg via paru..."
            paru -S --noconfirm --needed "$pkg"
        fi
    fi
done

echo
echo

echo -e "------------------------------------------"
echo -e "  ${BOLD}     Installation Process Finished! ${BOLD_RESET}     "
echo -e "------------------------------------------"
