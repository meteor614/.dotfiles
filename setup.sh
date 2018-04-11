#!/bin/bash

SCRIPTPATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# for .* file
cd ~
files=($(ls -FA ${SCRIPTPATH}|grep '^\..*[^/]$'))
for i in ${files[@]}; do
    ln -s ${SCRIPTPATH}/${i}
done

# for .aria2
ln -s ${SCRIPTPATH}/.aria2

# for neovim
ln -s ~/.vimrc .vim/init.vim

# for tmuxinator
cd ~/.config
ln -s ${SCRIPTPATH}/tmuxinator

# for bin/*
test -d ~/bin || mkdir ~/bin
cd ~/bin
files=($(ls ${SCRIPTPATH}/bin))
for i in ${files[@]}; do
    ln -s ${SCRIPTPATH}/bin/${i}
done
test -f ~/.vim/plugged/YCM-Generator/config_gen.py && ln -s ~/.vim/plugged/YCM-Generator/config_gen.py

# init ssh authorized_keys
if [ x$1 == xall ]; then
    test -d ~/.ssh || mkdir ~/.ssh
    cd ~/.ssh
    if cmp ${SCRIPTPATH}/.ssh/id_rsa.pub id_rsa.pub ; then
        echo 'id_rsa.pub exist, ignore'
    elif [ -f authorized_keys ] && [ x$(grep -F $(awk '{print $2}' ${SCRIPTPATH}/.ssh/id_rsa.pub) authorized_keys -c) == x1 ]; then
        echo 'authorized_keys exist'
    else
        cat ${SCRIPTPATH}/.ssh/id_rsa.pub >> authorized_keys
    fi
fi
