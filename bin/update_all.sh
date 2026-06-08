#!/bin/bash
# update_all.sh — update packages, language runtimes, plugins, and dotfiles.
# Uses topgrade as the core engine; falls back to manual steps when absent.
set -euo pipefail

begin=$(date +%s)

have_cmd() { command -v "$1" >/dev/null 2>&1; }
log() { printf '%s\n' "$1"; }

usage() {
    cat <<'EOF'
Usage: update_all.sh [all]

Commands:
  all   Also update ~/.dotfiles and its submodules
EOF
}

# ── Core: topgrade (auto-detects brew/gem/npm/pip/cargo/…)
run_topgrade() {
    if have_cmd topgrade; then
        log "=== topgrade ==="
        if topgrade; then
            log "topgrade finish"
            return 0
        fi
        log "topgrade failed"
        return 1
    fi
    return 1
}

# ── Fallback: manual updates (when topgrade is not installed)
update_pkg_manager() {
    if have_cmd brew; then
        export HOMEBREW_INSTALL_CLEANUP=1
        brew update
        brew upgrade
        brew cleanup
        log "brew update finish"
    elif have_cmd apt; then
        sudo apt update
        sudo apt upgrade -y
        sudo apt-get clean
        sudo apt autoremove -y
        log "apt update finish"
    elif have_cmd yum; then
        sudo yum -y update
        sudo yum clean all
        log "yum update finish"
    elif have_cmd ipkg; then
        sudo ipkg update
        sudo ipkg upgrade
        log "ipkg update finish"
    else
        log "update command not found"
    fi
}

update_gem() {
    if ! have_cmd gem; then
        return 0
    fi

    if have_cmd rbenv || have_cmd asdf; then
        return 0
    fi

    local gem_dir
    gem_dir="$(gem environment gemdir)"

    if [ -w "$gem_dir" ]; then
        gem update -f
        gem cleanup
    else
        sudo gem update -f
        sudo gem cleanup
    fi
    log "gem upgrade finish"
}

# ── Dotfiles repo (topgrade does not cover this)
update_dotfiles_repo() {
    if [ ! -d "$HOME/.dotfiles" ]; then
        return 0
    fi

    (
        cd "$HOME/.dotfiles"
        git pull --no-rebase
        git submodule update --init --recursive
        git submodule update --remote
        log ".dotfiles repo update finish"
        log "re-run ~/.dotfiles/setup.sh repair manually if links need reconciliation"
    )
}

# ── Zsh plugins (topgrade does not cover oh-my-zsh)
update_zsh_plugins() {
    if ! have_cmd zsh; then
        return 0
    fi

    if [ -n "${ZSH:-}" ] && [ -f "$ZSH/tools/upgrade.sh" ]; then
        ZSH="$ZSH" zsh -c '"$ZSH/tools/upgrade.sh"'
    fi

    if [ -f "$HOME/.antigen/init.zsh" ]; then
        DOTFILES_NONINTERACTIVE=1 zsh -c 'source ~/.antigen/init.zsh && type antigen &>/dev/null && { antigen update; antigen cleanup; echo "antigen upgrade finish"; }'
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
# Wrap the entire main block in `{ ... }` so bash reads it all into memory
# before executing. Without this, topgrade's "Git Repositories" step can
# rewrite this very file mid-run (via `git pull` on ~/.dotfiles), which
# shifts byte offsets and triggers spurious "syntax error near `then`"
# style errors as bash continues reading from the modified file.
main() {
    case "${1:-}" in
        ""|all) ;;
        -h|--help) usage; exit 0 ;;
        *) log "Unknown argument: ${1}"; usage; exit 1 ;;
    esac

    if ! run_topgrade; then
        log "=== topgrade not found — falling back to manual steps ==="
        update_pkg_manager
        update_gem
    fi

    if have_cmd cpan; then
        sudo cpan -u -T
        log "cpan upgrade finish"
    fi

    if [ "${1:-}" = "all" ]; then
        update_dotfiles_repo
    fi

    update_zsh_plugins

    end=$(date +%s)
    log "used $((end - begin)) seconds"
}

main "$@"
