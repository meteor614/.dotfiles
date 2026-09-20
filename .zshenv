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
