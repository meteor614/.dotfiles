#!/bin/bash
# update_all.sh — update packages, language runtimes, plugins, and dotfiles.
# Uses topgrade as the core engine; falls back to manual steps when absent.
set -euo pipefail

begin=$(date +%s)

have_cmd() { command -v "$1" >/dev/null 2>&1; }
log() { printf '%s\n' "$1"; }

# Some hosts (e.g. Synology DSM) mount /tmp with `noexec`, which breaks any
# updater that downloads an installer to $TMPDIR and tries to chmod+x it
# (atuin-update, rustup-init, etc.). Redirect TMPDIR to an exec-allowed dir
# in $HOME when /tmp is noexec.
ensure_exec_tmpdir() {
    local probe
    probe=$(mktemp /tmp/.update_all_exec_probe.XXXXXX 2>/dev/null) || return 0
    printf '#!/bin/sh\nexit 0\n' >"$probe"
    chmod +x "$probe" 2>/dev/null
    if "$probe" >/dev/null 2>&1; then
        rm -f "$probe"
        return 0
    fi
    rm -f "$probe"
    local exec_tmp="$HOME/.cache/tmp"
    mkdir -p "$exec_tmp"
    chmod 700 "$exec_tmp"
    export TMPDIR="$exec_tmp"
    log "/tmp is noexec; using TMPDIR=$TMPDIR"
}
ensure_exec_tmpdir

usage() {
    cat <<'EOF'
Usage: update_all.sh [all]

Commands:
  all   Also update ~/.dotfiles and its submodules
EOF
}

# ── Conda — pre-run conda so that topgrade's mamba step is a no-op.
#    mamba 2.8.x has a bug: `pip inspect --local` on a large env produces
#    "Broken pipe" + exit 1, which makes topgrade prompt "Retry?" and block.
#    conda handles this gracefully (exit 0), and running it first means
#    topgrade's mamba step will find nothing to update and skip.
update_conda() {
    if ! have_cmd conda; then
        return 0
    fi
    log "=== conda ==="
    if conda update --all -n base --yes 2>/dev/null; then
        log "conda finish"
    else
        log "conda update failed"
    fi
}

# ── Core: topgrade (auto-detects brew/gem/npm/pip/cargo/…)
run_topgrade() {
    if have_cmd topgrade; then
        log "=== topgrade ==="
        # Pre-run conda so topgrade's mamba step is a no-op (avoids
        # mamba 2.8.x Broken pipe bug with large pip package lists).
        # Also disable topgrade's built-in mamba step — we handle it
        # ourselves via update_conda.
        update_conda

        # On macOS, atuin is managed by brew and already updated via
        # topgrade's own brew step — disable the redundant atuin step.
        # On Linux, atuin is a manual ~/bin/atuin binary with no brew
        # coverage, so keep it enabled as the sole auto-update path.
        local topgrade_args=("-y" "--disable" "mamba")
        if [ "$(uname)" = "Darwin" ]; then
            topgrade_args+=("--disable" "atuin")
        fi

        if topgrade "${topgrade_args[@]}"; then
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

# Ruby < 3.2.0 is macOS system Ruby — its gems are Apple-bundled system deps.
# Updating them via sudo is low-value and risky; gem self-upgrade fails anyway.
# Only run gem operations on a user-installed modern Ruby (≥ 3.2.0).
readonly GEM_RUBY_MINVER="3.2.0"

update_gem() {
    if ! have_cmd gem; then
        return 0
    fi

    # Version managers (rbenv/asdf/mise) each handle their own gem lifecycle.
    if have_cmd rbenv || have_cmd asdf || have_cmd mise; then
        return 0
    fi

    local ruby_ver
    ruby_ver="$(ruby -e 'puts RUBY_VERSION' 2>/dev/null)" || ruby_ver=""

    if [ -z "$ruby_ver" ] || [ "$ruby_ver" = "$(printf '%s\n' "$GEM_RUBY_MINVER" "$ruby_ver" | sort -V | tail -1)" ]; then
        # Ruby ≥ 3.2.0 (user-installed) — safe to update gems normally
        gem update -f
        gem cleanup
        gem update --system
        log "gem upgrade finish"
    else
        log "ruby ${ruby_ver} is macOS system Ruby (< ${GEM_RUBY_MINVER}) — skipping gem update"
    fi
}

# ── Dotfiles repo (topgrade does not cover this)
update_dotfiles_repo() {
    if [ ! -d "$HOME/.dotfiles" ]; then
        return 0
    fi

    (
        cd "$HOME/.dotfiles"
        if have_cmd jj && [ -d .jj ]; then
            jj git fetch
            jj rebase -d master
        else
            log "jj not found or .jj missing; falling back to git pull for dotfiles"
            git pull --no-rebase
        fi
        git submodule update --init --recursive
        git submodule update --remote
        log ".dotfiles repo update finish"
        log "re-run ~/.dotfiles/setup.sh repair manually if links need reconciliation"
    )
}

# ── Zsh plugins (cloned directly by setup.sh; no oh-my-zsh framework)
update_zsh_plugins() {
    if ! have_cmd zsh; then
        return 0
    fi

    local plugins_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
    local d
    for d in "$plugins_dir"/zsh-autosuggestions "$plugins_dir"/zsh-syntax-highlighting; do
        if [ -d "$d/.git" ]; then
            git -C "$d" pull --ff-only 2>/dev/null && log "updated $(basename "$d")"
        fi
    done

    if [ -f "$HOME/.antigen/init.zsh" ]; then
        DOTFILES_NONINTERACTIVE=1 zsh -c 'source ~/.antigen/init.zsh && type antigen &>/dev/null && { antigen update; antigen cleanup; echo "antigen upgrade finish"; }'
    fi
}

# ── Mise: upgrade runtime versions (node/python/go) to latest in pinned range
update_mise() {
    if ! have_cmd mise; then
        return 0
    fi
    log "=== mise ==="
    if mise upgrade 2>/dev/null; then
        log "mise finish"
    else
        log "mise upgrade failed"
    fi
}

# ── Rustup: keep Rust toolchain current
update_rustup() {
    if ! have_cmd rustup; then
        return 0
    fi
    log "=== rustup ==="
    if rustup update 2>/dev/null; then
        log "rustup finish"
    else
        log "rustup update failed"
    fi
}

# ── Reasonix: coding agent self-update (Linux: npm global; macOS: brew cask)
update_reasonix() {
    [ "$(uname)" = "Darwin" ] && return 0
    if ! have_cmd reasonix; then
        return 0
    fi
    log "=== reasonix ==="
    if reasonix upgrade 2>/dev/null; then
        log "reasonix finish"
    else
        log "reasonix upgrade failed"
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

        # npm/pipx — covered by topgrade when present, manual on fallback
        if have_cmd npm; then
            npm update -g 2>/dev/null && log "npm global update finish" || log "npm global update failed"
        fi
        if have_cmd pipx; then
            pipx upgrade-all 2>/dev/null && log "pipx upgrade-all finish" || log "pipx upgrade-all failed"
        fi
    fi

    # Run gem update separately from topgrade (topgrade disables gem to avoid
    # `gem update --system` on old system Ruby). Our update_gem handles the
    # version check gracefully.
    update_gem

    update_mise
    update_rustup
    update_reasonix

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
