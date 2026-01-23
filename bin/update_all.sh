#!/bin/bash

set -o pipefail

begin=$(date +%s)

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

log() {
    printf '%s\n' "$1"
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
        #sudo dnf upgrade
        #sudo pkg upgrade
        log "update command not found"
    fi
}

update_gem() {
    if ! have_cmd gem; then
        return 0
    fi

    if have_cmd brew; then
        gem update -f
        gem cleanup
    else
        sudo gem update -f
        sudo gem cleanup
    fi
    log "gem upgrade finish"
}

update_npm() {
    if ! have_cmd npm; then
        return 0
    fi

    if have_cmd brew; then
        npm install -g npm --force
        npm update
        npm --force cache clean
    else
        sudo npm install -g npm
        sudo npm update
        sudo npm --force cache clean
    fi
    log "npm upgrade finish"
}

update_git_repo() {
    local repo=$1
    shift

    if [ ! -d "$repo" ]; then
        return 0
    fi

    (
        cd "$repo" && "$@"
    )
}

update_dotfiles_repo() {
    if [ ! -d "$HOME/.dotfiles" ]; then
        return 0
    fi

    (
        cd "$HOME/.dotfiles"
        git pull --no-rebase
        "$HOME/.dotfiles/setup.sh"
        log ".dotfiles update finish"
    )
}

update_zsh_plugins() {
    if ! have_cmd zsh; then
        return 0
    fi

    zsh -ic "omz update"

    if [ -f "$HOME/.antigen/init.zsh" ]; then
        zsh -c 'source ~/.antigen/init.zsh && type antigen &>/dev/null && { antigen update; antigen cleanup; echo "antigen upgrade finish"; }'
    fi
}

update_submodules() {
    if [ ! -d "$HOME/.dotfiles" ]; then
        return 0
    fi

    (
        cd "$HOME/.dotfiles"
        git submodule update --remote
        log ".dotfiles submodule update finish"
    )
}

update_lvim() {
    if ! have_cmd lvim; then
        return 0
    fi

    (
        cd "$HOME/.local/share/lunarvim/lvim" && git pull
        lvim +LvimUpdate +qall
        lvim +TSUpdateSync +qall
        lvim +LvimSyncCorePlugins +qa
        log "lvim PlugUpdate finish"
    )
}

# os package manager
update_pkg_manager &

# ruby modules
update_gem &

# node.js modules
update_npm &

# update gdb-dashboard from github
update_git_repo "$HOME/gdb-dashboard" git pull --no-rebase &

# update voltron from github
update_git_repo "$HOME/voltron" git pull --no-rebase &

# perl modules
if have_cmd cpan; then
    (
        sudo cpan -u -T
        log "cpan upgrade finish"
    ) &
fi

if [ "${1:-}" = "all" ]; then
    # update .dotfiles
    update_dotfiles_repo &
fi

# zsh plugins
update_zsh_plugins

update_submodules &

update_lvim &

# vim plugins
# if have_cmd vim; then
#     vim -c PlugUpgrade -c qa
#     vim -c PlugInstall -c PlugUpdate -c qa
#     if [ -d ~/.vim/plugged/coc.nvim ]; then
#         vim -c CocUpdateSync -c qa
#     fi
#     echo "vim PlugUpdate finish"
# fi

wait
end=$(date +%s)
log "used $((end - begin)) seconds"
