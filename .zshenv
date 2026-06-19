# ~/.zshenv — minimal environment for every zsh invocation.
# Keep this file tiny: it is sourced by interactive and non-interactive shells.

# pnpm/corepack global binaries.  This mirrors pnpm's standard shell setup so
# tools launched from non-interactive zsh (for example topgrade hooks) can find
# pnpm-installed commands without sourcing the heavier ~/.zshrc.
if [ -z "${PNPM_HOME:-}" ]; then
    if [ -d "$HOME/Library/pnpm" ]; then
        export PNPM_HOME="$HOME/Library/pnpm"
    else
        export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
    fi
fi
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
