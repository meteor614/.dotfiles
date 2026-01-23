#!/bin/bash

set -o pipefail

begin=$(date +%s)

have_cmd() {
    command -v "$1" &>/dev/null
}

parallel_cmd() {
    xargs -P 16 "$@"
}

# os package manager
{
    if have_cmd brew; then
        export HOMEBREW_INSTALL_CLEANUP=1
        brew update
        brew upgrade
        brew cleanup
        echo "brew update finish"
    elif have_cmd apt; then
        sudo apt update
        sudo apt upgrade -y
        sudo apt-get clean
        sudo apt autoremove -y
        echo "apt update finish"
    elif have_cmd yum; then
        sudo yum -y update
        sudo yum clean all
        echo "yum update finish"
    elif have_cmd ipkg; then
        sudo ipkg update
        sudo ipkg upgrade
        echo "ipkg update finish"
    else
        #sudo dnf upgrade 
        #sudo pkg upgrade
        echo "update command not found"
    fi
}&

# python modules
# {
#     if type python3 &>/dev/null; then
#         if type brew &>/dev/null; then
#             python3 -m pip install --upgrade pip
#             #python3 -m pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python3 -m pip install --upgrade
#             python3 -m pip list |awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python3 -m pip install --upgrade
#         else
#             python3 -m pip install --upgrade pip
#             #sudo python3 -m pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python3 -m pip install --upgrade
#             python3 -m pip list |awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python3 -m pip install --upgrade
#         fi
#         echo "pip3 upgrade finish"
#     elif type python &>/dev/null; then
#         if type brew &>/dev/null; then
#             python -m pip install --upgrade pip
#             #python -m pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python -m pip install --upgrade
#             python -m pip list |awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python -m pip install --upgrade
#         else
#             sudo python -m pip install --upgrade pip
#             #sudo python -m pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 sudo python -m pip install --upgrade
#             sudo python -m pip list |awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 sudo python -m pip install --upgrade
#         fi
#         #wait
#         echo "pip upgrade finish"
#     fi
# }&

# ruby modules
if have_cmd gem; then
    {
        if have_cmd brew; then
            gem update -f
            gem cleanup
        else
            sudo gem update -f
            sudo gem cleanup
        fi
        echo "gem upgrade finish"
    }&
fi

# node.js modules
if have_cmd npm; then
    {
        if have_cmd brew; then
            npm install -g npm --force
            npm update
            npm --force cache clean
        else
            sudo npm install -g npm
            sudo npm update
            sudo npm --force cache clean
        fi
        echo "npm upgrade finish"
    }&
fi

# update gdb-dashboard from github
if [ -d ~/gdb-dashboard ]; then
    {
        cd ~/gdb-dashboard
        git pull --no-rebase 
    }&
fi

# update voltron from github
if [ -d ~/voltron ]; then
    {
        cd ~/voltron
        git pull --no-rebase
    }&
fi

# perl modules
if have_cmd cpan; then
    {
        sudo cpan -u -T
        echo "cpan upgrade finish"
    }&
fi

if [ "${1:-}" = "all" ]; then
    # python modules
    # if type python3 &>/dev/null && type python2 &>/dev/null; then
    #     {
    #         if type brew &>/dev/null; then
    #             python2 -m pip install --upgrade pip
    #             #python2 -m pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python2 -m pip install --upgrade
    #             python2 -m pip list |awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python2 -m pip install --upgrade
    #         else
    #             sudo python2 -m pip install --upgrade pip
    #             #sudo python2 -m pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 python2 -m pip install --upgrade
    #             sudo python2 -m pip list |awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel -P 16 sudo python2 -m pip install --upgrade
    #         fi
    #         echo "pip2 upgrade finish"
    #     }&
    # fi

    # update .dotfiles
    if [ -d ~/.dotfiles ]; then
        {
            cd ~/.dotfiles
            git pull --no-rebase
            ~/.dotfiles/setup.sh
            echo ".dotfiles update finish"
        }&
    fi
fi

# zsh plugins
if have_cmd zsh; then
    zsh -ic "omz update"

    # antigen
    if [ -f ~/.antigen/init.zsh ]; then
        zsh  -c 'source ~/.antigen/init.zsh && type antigen &>/dev/null && { antigen update; antigen cleanup; echo "antigen upgrade finish" }' &
    fi
fi

if [ -d ~/.dotfiles ]; then
    {
        cd ~/.dotfiles
        git submodule update --remote
        echo ".dotfiles submodule update finish"
    }&
fi

if have_cmd lvim; then
    {
        cd ~/.local/share/lunarvim/lvim && git pull
        lvim +LvimUpdate +qall
        lvim +TSUpdateSync +qall
        lvim +LvimSyncCorePlugins +qa
        echo "lvim PlugUpdate finish"
    }&
fi
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
echo "used $((end - begin)) seconds"
