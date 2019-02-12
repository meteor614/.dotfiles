#!/bin/bash

begin=`date "+%s"`

type parallel >/dev/null 2>&1 || alias parallel='xargs -P 16'

# os package manager
{
    if type brew &>/dev/null; then
        export HOMEBREW_INSTALL_CLEANUP=1
        brew update
        brew upgrade --cleanup
        brew cleanup
        echo "brew update finish"
    elif type apt &>/dev/null; then
        sudo apt update
        sudo apt upgrade -y
        sudo apt-get clean
        sudo apt autoremove
        echo "apt update finish"
    elif type yum &>/dev/null; then
        sudo yum -y update
        sudo yum clean
        echo "yum update finish"
    elif type ipkg &>/dev/null; then
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
{
    if type pip3 &>/dev/null; then
        pip3 install --upgrade pip
        pip3 list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel pip3 install --upgrade
        #for i in `pip3 list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}'`; do
        #    pip3 install --upgrade $i &
        #done
        #wait
        echo "pip3 upgrade finish"
    elif type pip &>/dev/null; then
        if type brew &>/dev/null; then
            pip install --upgrade pip
            pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel pip install --upgrade
            #for i in `pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}'`; do
            #    pip install --upgrade $i &
            #done
        else
            sudo pip install --upgrade pip
            sudo pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel sudo pip install --upgrade
            #for i in `sudo pip list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}'`; do
            #    sudo pip install --upgrade $i &
            #done
        fi
        #wait
        echo "pip upgrade finish"
    fi
}&

# ruby modules
if type gem &>/dev/null; then
    {
        if type brew &>/dev/null; then
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
if type npm &>/dev/null; then
    {
        if type brew &>/dev/null; then
            sudo npm install -g npm
            sudo npm update
            sudo npm --force cache clean
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
    cd ~/gdb-dashboard
    git pull &
fi

# update voltron from github
if [ -d ~/voltron ]; then
    cd ~/voltron
    git pull &
fi

# perl modules
if type cpan &>/dev/null; then
    {
        sudo cpan -u -T
        echo "cpan upgrade finish"
    }&
fi

if [ x$1 == xall ]; then
    # python modules
    if type pip3 &>/dev/null && type pip2 &>/dev/null; then
        {
            pip2 install --upgrade pip
            pip2 list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}' | parallel pip2 install --upgrade
            #for i in `pip2 list --outdated|awk -F ' ' '{if ($2 ~ "[0-9].*") {print $1}}'`; do
            #    pip2 install --upgrade $i &
            #done
            #wait
            echo "pip2 upgrade finish"
        }&
    fi

    # update .dotfiles
    if [ -d ~/.dotfiles ]; then
        {
            cd ~/.dotfiles
            git pull
            ~/.dotfiles/setup.sh
            echo ".dotfiles update finish"
        }&
    fi
fi

# zsh plugins
if type zsh &>/dev/null; then
    # oh-my-zsh
    if [ -f ~/.oh-my-zsh/tools/upgrade.sh ]; then
        {
            source ~/.oh-my-zsh/tools/upgrade.sh
            echo "oh my zsh upgrade finish"
        }&
    fi

    # antigen
    echo 'type antigen &>/dev/null && { antigen update; antigen cleanup; echo "antigen upgrade finish" }' | zsh -i -s
fi

# vim plugins
if type vim &>/dev/null; then
    vim -c PlugUpgrade -c qa
    vim -c PlugInstall -c PlugUpdate -c qa
    if [ -d ~/.vim/plugged/coc.nvim ]; then
        vim -c CocUpdate -c qa
    fi
    echo "vim PlugUpdate finish"
fi

wait
end=`date "+%s"`
echo "used `expr $end - $begin` seconds"

