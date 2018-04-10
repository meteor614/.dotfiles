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
