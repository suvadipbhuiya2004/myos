# .bashrc - Standard Dynamic Initialization

# -----------------------------------------------------------------------------
# 1. INTERACTIVE CHECK & INITIALIZATION
# -----------------------------------------------------------------------------
# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# Source ble.sh early (attach happens at the very end for speed)
[[ -f /usr/share/blesh/ble.sh ]] && source /usr/share/blesh/ble.sh --attach=none

# -----------------------------------------------------------------------------
# 2. ENVIRONMENT VARIABLES
# -----------------------------------------------------------------------------
export EDITOR='helix'
export SUDO_EDITOR="$EDITOR"
export BAT_THEME="ansi"

# Carapace Config
export CARAPACE_MATCH=1
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

# -----------------------------------------------------------------------------
# 3. BASH SHELL SETTINGS
# -----------------------------------------------------------------------------
shopt -s histappend        # Append to history, don't overwrite
shopt -s checkwinsize     # Update lines/cols after each command
HISTCONTROL=ignoreboth    # Don't log duplicates or lines starting with space
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# Ensure command hashing is off
set +h

# -----------------------------------------------------------------------------
# 4. TOOL INITIALIZATION (Dynamic Loading)
# -----------------------------------------------------------------------------

# Mise (Version Manager)
if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
fi

# Starship Prompt
if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# Zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

# FZF (Fuzzy Finder)
if [[ -f /usr/share/fzf/completion.bash ]]; then
  source /usr/share/fzf/completion.bash
  source /usr/share/fzf/key-bindings.bash
fi

# Carapace (Completions)
if command -v carapace &>/dev/null; then
  source <(carapace _carapace)
fi

# -----------------------------------------------------------------------------
# 5. ALIASES
# -----------------------------------------------------------------------------

# File System (eza)
if command -v eza &>/dev/null; then
  alias ls='eza -lha --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
else
  alias ls='ls --color=auto -F'
  alias lsa='ls -la'
fi

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

# Quick Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# -----------------------------------------------------------------------------
# 6. FUNCTIONS
# -----------------------------------------------------------------------------

# Enhanced CD: Zoxide jump followed by auto-ls
if command -v zoxide &>/dev/null; then
  alias cd="__z_and_ls"
  __z_and_ls() {
    if z "$@"; then
      ls
    else
      return 1
    fi
  }
fi

# Database Management (Auto start/stop PostgreSQL)
with_pg() {
  if ! systemctl is-active --quiet postgresql; then
    echo "🟢 Starting PostgreSQL..."
    sudo systemctl start postgresql
    "$@"
    echo "🔴 Stopping PostgreSQL..."
    sudo systemctl stop postgresql
  else
    "$@"
  fi
}
alias psql='with_pg psql'
alias pgcli='with_pg pgcli'

# Utilities
open() { xdg-open "$@" >/dev/null 2>&1 & }
compress() { tar -czf "${1%/}.tar.gz" "${1%}"; }
n() { [ "$#" -eq 0 ] && nvim . || nvim "$@"; }

# -----------------------------------------------------------------------------
# 7. FINAL ATTACHMENTS
# -----------------------------------------------------------------------------
# Fallback prompt if starship fails
_prompt_icon=$'\uf0a9 '
PS1="\[\e]0;\w\a\]${_prompt_icon}"

batman() {
    # Detect if the system uses 'bat' or 'batcat' (Debian/Ubuntu)
    local bat_cmd="bat"
    if command -v batcat &> /dev/null; then
        bat_cmd="batcat"
    fi

    # Set bat as the pager, stripping raw backspaces with col, and telling bat it's a man page
    MANPAGER="sh -c 'col -bx | $bat_cmd -l man -p'" man "$@"
}

# Attach ble.sh last for best compatibility
[[ ${BLE_VERSION-} ]] && ble-attach

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
