#!/bin/bash

SCRIPTPATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd ~
files=($(ls -FA ${SCRIPTPATH}|grep '^\..*$'|grep -v '^\.git/$'))
for i in ${files[@]}; do
    ln -s ${SCRIPTPATH}/${i}
done
# for neovim
ln -s ~/.vimrc .vim/init.vim
