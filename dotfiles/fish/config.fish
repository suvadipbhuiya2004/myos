# ~/.config/fish/config.fish

# -----------------------------------------------------------------------------
# 1. ENVIRONMENT VARIABLES
# -----------------------------------------------------------------------------
# -g means global, -x means export to child processes
set -gx EDITOR helix
set -gx SUDO_EDITOR $EDITOR
set -gx BAT_THEME "Catppuccin Mocha"
# Carapace Config
set -gx CARAPACE_MATCH 1
set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'

# -----------------------------------------------------------------------------
# 2. INTERACTIVE INITIALIZATION & ALIASES
# -----------------------------------------------------------------------------
if status is-interactive

    # --- Tool Initialization ---

    if type -q mise
        mise activate fish | source
    end

    if type -q starship
        starship init fish | source
    end

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q carapace
        carapace _carapace | source
    end

    # --- Aliases ---

    # File System (eza)
    if type -q eza
        alias ls='eza -lha --group-directories-first --icons=auto'
        alias lsa='ls -a'
        alias lt='eza --tree --level=2 --long --icons --git'
        alias lta='lt -a'
    else
        alias ls='ls --color=auto -F'
        alias lsa='ls -la'
    end

    # General Tools
    alias grep='grep --color=auto'
    alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
    alias d='docker'
    alias r='rails'
    alias zed='zeditor'
    alias decompress="tar -xzf"
    alias icat="kitten icat"
    alias e='exit'
    alias c='clear'
    alias hx='helix'

    # Git
    alias g='git'
    alias gcm='git commit -m'
    alias gcam='git commit -a -m'
    alias gcad='git commit -a --amend'

    # Quick Navigation (Fish handles standard .. automatically, but explicit aliases are fine)
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'

end

# -----------------------------------------------------------------------------
# 3. FUNCTIONS
# -----------------------------------------------------------------------------
# In Fish, it is often better to put these in individual files under 
# ~/.config/fish/functions/ (e.g. with_pg.fish), but they work perfectly here too.

# Enhanced CD: Zoxide jump followed by auto-ls
function cd --wraps z
    if z $argv
        ls
    else
        return 1
    end
end

# Database Management (Auto start/stop PostgreSQL)
function with_pg
    if not systemctl is-active --quiet postgresql
        echo "🟢 Starting PostgreSQL..."
        sudo systemctl start postgresql
        $argv
        echo "🔴 Stopping PostgreSQL..."
        sudo systemctl stop postgresql
    else
        $argv
    end
end

# Fish uses wrappers easily
function psql --wraps psql
    with_pg psql $argv
end
function pgcli --wraps pgcli
    with_pg pgcli $argv
end

# Utilities
function open
    xdg-open $argv >/dev/null 2>&1 &
end

function compress
    # Removes trailing slash if present
    set -l target (string trim -r -c / $argv[1])
    tar -czf "$target.tar.gz" "$target"
end

function n --wraps nvim
    if not set -q argv[1]
        nvim .
    else
        nvim $argv
    end
end

function batman --description "Read man pages with syntax highlighting using bat"
    man $argv | bat -pl man
end

# Define the Android Home variable (-g for global, -x for export)
set -gx ANDROID_HOME $HOME/Android/Sdk

# Append the emulator and platform-tools to your PATH
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools
