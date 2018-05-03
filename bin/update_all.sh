#!/bin/bash

begin=`date "+%s"`

# os package manager
{
    if type brew &>/dev/null; then
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
        for i in `pip3 list --outdated|awk -F ' ' '{print $1}'`
            do pip3 install --upgrade $i &
        done
        wait
        echo "pip3 upgrade finish"
    else
        pip install --upgrade pip
        for i in `pip list --outdated|awk -F ' ' '{print $1}'`
            do pip install --upgrade $i &
        done
        wait
        echo "pip upgrade finish"
    fi
}&

# zsh plugins
if type upgrade_oh_my_zsh &>/dev/null; then
    {
        upgrade_oh_my_zsh
        echo "Oh My Zsh upgrade finish"
    }&
fi

# ruby modules
if type gem &>/dev/null; then
    {
        gem update -f
        gem cleanup
        echo "gem upgrade finish"
    }&
fi

# node.js modules
if type npm &>/dev/null; then
    {
        npm update
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
        cpan -u -T
        echo "cpan upgrade finish"
    }&
fi

if [ x$1 == xall ]; then
    # update .dotfiles
    if [ -d ~/.dotfiles ]; then
        {
            cd ~/.dotfiles
            git pull
            ~/.dotfiles/setup.sh
            echo ".dotfiles update finish"
        }&
    fi

    # go binaries
    {
        vim -c GoUpdateBinaries -c qa only_for_load_go.go
        echo "vim GoUpdateBinaries finish"
    }&

    # python modules
    {
        if type pip3 &>/dev/null; then
            pip install --upgrade pip
            for i in `pip list --outdated|awk -F ' ' '{print $1}'`
                do pip install --upgrade $i &
            done
            wait
            echo "pip upgrade finish"
        fi
    }&
fi

# vim plugins
vim -c PlugUpgrade -c qa
vim -c PlugInstall -c PlugUpdate -c qa
echo "vim PlugUpdate finish"

wait
end=`date "+%s"`
echo "used `expr $end - $begin` seconds"
