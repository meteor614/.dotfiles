#!/bin/bash

set -euo pipefail

begin=$(date +%s)

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

log() {
    printf '%s\n' "$1"
}

usage() {
    cat <<'EOF'
Usage: update_all.sh [all]

Commands:
  all   Also update ~/.dotfiles and its submodules
EOF
}

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

    # Skip if Ruby version is managed by rbenv or asdf
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

update_git_repo() {
    local repo=$1
    shift

    if [ ! -d "$repo" ]; then
        return 0
    fi

    (
        cd "$repo"
        "$@"
    )
}

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

update_zsh_plugins() {
    if ! have_cmd zsh; then
        return 0
    fi

    DOTFILES_NONINTERACTIVE=1 zsh -ic "omz update"

    if [ -f "$HOME/.antigen/init.zsh" ]; then
        DOTFILES_NONINTERACTIVE=1 zsh -c 'source ~/.antigen/init.zsh && type antigen &>/dev/null && { antigen update; antigen cleanup; echo "antigen upgrade finish"; }'
    fi
}

update_lvim() {
    if ! have_cmd lvim; then
        return 0
    fi

    (
        cd "$HOME/.local/share/lunarvim/lvim"
        git pull --no-rebase
        lvim +LvimUpdate +qall
        lvim +TSUpdateSync +qall
        lvim +LvimSyncCorePlugins +qa
        log "lvim PlugUpdate finish"
    )
}

case "${1:-}" in
    ""|all)
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        log "Unknown argument: ${1}"
        usage
        exit 1
        ;;
esac

update_pkg_manager
update_gem
update_git_repo "$HOME/gdb-dashboard" git pull --no-rebase
update_git_repo "$HOME/voltron" git pull --no-rebase

if have_cmd cpan; then
    sudo cpan -u -T
    log "cpan upgrade finish"
fi

if [ "${1:-}" = "all" ]; then
    update_dotfiles_repo
fi

update_zsh_plugins
update_lvim

end=$(date +%s)
log "used $((end - begin)) seconds"
