#!/bin/bash


BOLD="\e[1m"
BOLD_RESET="\e[0m"


# Define directories
DOTFILES_DIR="$HOME/myos/dotfiles"
CONFIG_DIR="$HOME/.config"

# Ensure ~/.config exists
mkdir -p "$CONFIG_DIR"

echo -e "------------------------------------------"
echo -e "  ${BOLD}     Setting up Dotfile Symlinks    ${BOLD_RESET}    "
echo -e "------------------------------------------"


echo
echo

# Helper function to create a link with a backup of existing files
link_item() {
    local src="$1"
    local dst="$2"
    
    if [ ! -e "$src" ]; then
        echo "[ERROR] Source $src does not exist!"
        return
    fi

    if [ -L "$dst" ]; then
        echo "[SKIP] $dst is already a symlink."
    else
        if [ -e "$dst" ]; then
            echo "[BACKUP] Moving existing item $dst to $dst.bak"
            mv "$dst" "$dst.bak"
        fi
        echo "[LINK] $src -> $dst"
        ln -s "$src" "$dst"
    fi
}

# --- Directories linked to ~/.config ---
link_item "$DOTFILES_DIR/emacs"      "$CONFIG_DIR/emacs"
link_item "$DOTFILES_DIR/fish"       "$CONFIG_DIR/fish"
link_item "$DOTFILES_DIR/helix"      "$CONFIG_DIR/helix"
link_item "$DOTFILES_DIR/kitty"      "$CONFIG_DIR/kitty"
link_item "$DOTFILES_DIR/mako"       "$CONFIG_DIR/mako"
link_item "$DOTFILES_DIR/niri"       "$CONFIG_DIR/niri"
link_item "$DOTFILES_DIR/quickshell" "$CONFIG_DIR/quickshell"
link_item "$DOTFILES_DIR/vicinae"    "$CONFIG_DIR/vicinae"
link_item "$DOTFILES_DIR/yazi"       "$CONFIG_DIR/yazi"

# --- Files linked to ~/.config ---
link_item "$DOTFILES_DIR/starship.toml" "$CONFIG_DIR/starship.toml"

# --- Files linked to $HOME ---
link_item "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
link_item "$DOTFILES_DIR/.bashrc"       "$HOME/.bashrc"
link_item "$DOTFILES_DIR/.blerc"        "$HOME/.blerc"

echo
echo

echo -e "------------------------------------------"
echo -e "     ${BOLD}      Symlinking Complete!   ${BOLD_RESET}        "
echo -e "------------------------------------------"
