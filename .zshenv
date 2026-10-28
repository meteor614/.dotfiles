# ~/.zshenv — minimal environment for every zsh invocation.
# Keep this file tiny: it is sourced by interactive and non-interactive shells.

# XDG base directories are pure environment and useful even for non-interactive
# zsh invocations. Heavier PATH/tool setup stays in ~/.zshrc/common.sh.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Default Reasonix in-app mouse capture on (even over SSH) so the wheel
# scrolls the transcript inside the TUI; /mouse or REASONIX_DISABLE_MOUSE=1
# turns it off and hands the mouse back to the terminal. External values win.
export REASONIX_DISABLE_MOUSE="${REASONIX_DISABLE_MOUSE:-0}"

# Skip the distro-wide `compinit` that Debian/Ubuntu's /etc/zsh/zshrc runs before
# this file's owners get a say. ~/.zshrc already runs a lazy compinit at the
# first prompt (with its own dump under ~/.zsh_cache), so the system one only
# costs startup time and leaves a second, unused ~/.zcompdump behind.
# This variable is read only by that distro file (Ubuntu also gates on
# /etc/os-release ID=*ubuntu; Debian checks it unconditionally). On macOS,
# Arch, Fedora, Synology/Entware it is never consulted and does nothing — it is
# a plain shell variable, not a zsh option, so it cannot disable completion on
# its own. Must live here rather than ~/.zshrc: /etc/zsh/zshrc is sourced before
# ~/.zshrc. Not exported, so child shells do not inherit it.
skip_global_compinit=1
