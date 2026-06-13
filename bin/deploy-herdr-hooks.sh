#!/bin/bash
# Deploy herdr agent-state hooks for reasonix, claude-internal, and codebuddy.
# This does the targeted deploy without running the full setup.sh.
set -euo pipefail

script_path="$(cd "$(dirname "$0")/.." && pwd)"
cd "$script_path"

# Source helper functions from setup.sh (ensure_link, ensure_dir, etc.)
# We need to extract just the functions, but setup.sh calls run_setup at the end.
# Instead, inline the helpers here.
ensure_dir() { [ -d "$1" ] || mkdir -p "$1"; }
ensure_link() {
    local src=$1 dst=$2
    if [ -L "$dst" ]; then
        local current; current=$(readlink "$dst" 2>/dev/null || true)
        [ "$current" = "$src" ] && return 0
    fi
    ln -sf "$src" "$dst"
}

echo "=== Deploying reasonix hooks ==="
src_dir="$script_path/.reasonix"
if [ -d "$src_dir" ]; then
    ensure_dir "$HOME/.reasonix/hooks"
    ensure_link "$src_dir/settings.json" "$HOME/.reasonix/settings.json"
    ensure_link "$src_dir/hooks/herdr-agent-state.sh" "$HOME/.reasonix/hooks/herdr-agent-state.sh"
    echo "  -> settings.json  $(readlink "$HOME/.reasonix/settings.json")"
    echo "  -> hooks/         $(readlink "$HOME/.reasonix/hooks/herdr-agent-state.sh")"
else
    echo "  skip: $src_dir not found"
fi

deploy_custom_hook() {
    local subdir="$1" target_dir="$2"
    local src_dir="$script_path/$subdir"
    [ -d "$src_dir" ] || { echo "  skip $subdir: source not found"; return 0; }
    [ -d "$target_dir" ] || { echo "  skip $subdir: target $target_dir not found"; return 0; }

    echo "=== Deploying $subdir hooks ==="
    ensure_dir "$target_dir/hooks"
    ensure_link "$src_dir/hooks/herdr-agent-state.sh" "$target_dir/hooks/herdr-agent-state.sh"
    echo "  -> hooks/herdr-agent-state.sh  $(readlink "$target_dir/hooks/herdr-agent-state.sh")"

    local settings="$target_dir/settings.json"
    local hooks_src="$src_dir/hooks-settings.json"
    if [ -f "$hooks_src" ]; then
        if command -v jq &>/dev/null; then
            if [ ! -f "$settings" ]; then
                printf '{}\n' > "$settings"
            fi
            local tmp; tmp="$(mktemp "${TMPDIR:-/tmp}/herdr-hook-merge.XXXXXX.json")"
            if jq -s '.[0] * {hooks: .[1].hooks}' "$settings" "$hooks_src" > "$tmp" 2>/dev/null; then
                mv "$tmp" "$settings"
                echo "  -> settings.json: hooks block merged"
            else
                rm -f "$tmp"
                echo "  !! settings.json merge failed; left untouched"
            fi
        else
            echo "  !! jq not installed; skipping settings.json merge"
        fi
    else
        echo "  skip: no hooks-settings.json found"
    fi
}

deploy_custom_hook ".claude-internal" "$HOME/.claude-internal"
deploy_custom_hook ".codebuddy"       "$HOME/.codebuddy"

echo ""
echo "=== Done ==="
echo "Verify with:"
echo "  ls -la ~/.reasonix/settings.json ~/.reasonix/hooks/herdr-agent-state.sh"
echo "  ls -la ~/.claude-internal/hooks/herdr-agent-state.sh"
echo "  jq '.hooks' ~/.claude-internal/settings.json"
echo "  ls -la ~/.codebuddy/hooks/herdr-agent-state.sh"
echo "  jq '.hooks' ~/.codebuddy/settings.json"
