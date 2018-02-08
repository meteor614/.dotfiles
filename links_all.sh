#!/bin/bash
SCRIPTPATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd ~
files=($(ls -Fa ${SCRIPTPATH}| grep '^\..*[^/]$'))
for i in ${files[@]}; do
    ln -s ${SCRIPTPATH}/${i}
done
ln -s ~/.vimrc .vim/init.vim
