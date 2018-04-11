#!/bin/bash

SCRIPTPATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd ~
files=($(ls -FA ${SCRIPTPATH}|grep '^\..*$'|grep -v '^\.git/$'))
for i in ${files[@]}; do
    ln -s ${SCRIPTPATH}/${i}
done

# for neovim
ln -s ~/.vimrc .vim/init.vim

# for tmuxinator
cd ~/.config
ln -s ${SCRIPTPATH}/tmuxinator

# for bin/*
cd
test -d bin || mkdir bin
cd bin
files=($(ls ${SCRIPTPATH}/bin))
for i in ${files[@]}; do
    ln -s ${SCRIPTPATH}/bin/${i}
done
test -f ~/.vim/plugged/YCM-Generator/config_gen.py && ln -s ~/.vim/plugged/YCM-Generator/config_gen.py

# ssh
cd
test -d .ssh || mkdir .ssh
cd .ssh
if cmp ${SCRIPTPATH}/.ssh/id_rsa.pub id_rsa.pub ; then
    echo 'id_rsa.pub exist, ignore'
elif [ -f authorized_keys ] && [ x$(grep -F $(awk '{print $2}' ${SCRIPTPATH}/.ssh/id_rsa.pub) authorized_keys -c) == x1 ]; then
    echo 'authorized_keys exist'
else
    cat ${SCRIPTPATH}/.ssh/id_rsa.pub >> authorized_keys
fi
