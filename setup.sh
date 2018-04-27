#!/bin/bash

script_path=$(cd $(dirname "${bash_source[0]}") && pwd)

# for .* file only
cd ~
files=($(ls -FA ${script_path}|grep '^\..*[^/]$'))
for i in ${files[@]}; do
    ln -s ${script_path}/${i}
done

# for .aria2
ln -s ${script_path}/.aria2

# for neovim
test -e ~/.config || mkdir ~/.config
cd ~/.config
ln -s ~/.vimrc ~/.vim/init.vim
test -e nvim || ln -s ~/.vim nvim

# for tmuxinator
ln -s ${script_path}/tmuxinator                                         # for mac
test -e ~/.tmuxinator || ln -s ${script_path}/tmuxinator ~/.tmuxinator  # for linux

# for bin/*
test -d ~/bin || mkdir ~/bin
cd ~/bin
files=($(ls ${script_path}/bin))
for i in ${files[@]}; do
    ln -s ${script_path}/bin/${i}
done
test -f ~/.vim/plugged/YCM-Generator/config_gen.py && ln -s ~/.vim/plugged/YCM-Generator/config_gen.py

# generate cpp_tags
test ! type g++ &>/dev/null || test -f ~/cpp_tags || ~/bin/generate_tags.sh

# install/update gdb-dashboard
if type gdb &>/dev/null; then
    if [ -d ~/gdb-dashboard ]; then
        cd ~/gdb-dashboard
        git pull
    else
        cd ~
        git clone https://github.com/cyrus-and/gdb-dashboard
    fi
fi

# install/update voltron
if type lldb &>/dev/null; then
    if [ -d ~/voltron ]; then
        cd ~/voltron
        git pull
    else
        cd ~
        git clone https://github.com/snare/voltron
    fi
fi

if [ x$1 == xall ]; then
    # init ssh authorized_keys
    test -d ~/.ssh || mkdir ~/.ssh
    cd ~/.ssh
    if cmp ${script_path}/.ssh/id_rsa.pub id_rsa.pub ; then
        echo 'local file ~/.ssh/id_rsa.pub exist, ignore it'
    elif [ -f authorized_keys ] && [ x$(grep -F $(awk '{print $2}' ${script_path}/.ssh/id_rsa.pub) authorized_keys -c) == x1 ]; then
        echo 'authorized_keys exist'
    else
        cat ${script_path}/.ssh/id_rsa.pub >> authorized_keys
    fi
fi
