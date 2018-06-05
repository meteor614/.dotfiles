#!/bin/bash

script_path=$(cd $(dirname "${bash_source-$0}") && pwd)

# update submodule
echo -e '\033[31mUpdate submodules...\033[0m'
cd ${script_path}
git submodule update --init --recursive 

# for .* file only
echo -e '\033[31mInit dotfiles...\033[0m'
cd ~
files=($(ls -FA ${script_path}|grep '^\..*[^/]$'|grep -v '^\.gitmodules$'))
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
echo -e '\033[31mInit scripts...\033[0m'
test -d ~/bin || mkdir ~/bin
cd ~/bin
files=($(ls ${script_path}/bin))
for i in ${files[@]}; do
    ln -s ${script_path}/bin/${i}
done
test -f ~/.vim/plugged/YCM-Generator/config_gen.py && ln -s ~/.vim/plugged/YCM-Generator/config_gen.py

# for tmux
cd ~
ln -s ${script_path}/.tmux/.tmux.conf

# install/update gdb-dashboard
if type gdb &>/dev/null; then
    if [ -d ~/gdb-dashboard ]; then
        echo -e '\033[31mUpdate gdb-dashboard...\033[0m'
        cd ~/gdb-dashboard
        git pull
    else
        echo -e '\033[31mGet gdb-dashboard...\033[0m'
        cd ~
        git clone https://github.com/cyrus-and/gdb-dashboard
    fi
fi

# install/update voltron
if type lldb &>/dev/null; then
    if [ -d ~/voltron ]; then
        echo -e '\033[31mUpdate voltron...\033[0m'
        cd ~/voltron
        git pull
    else
        echo -e '\033[31mGet & install voltron...\033[0m'
        cd ~
        git clone https://github.com/snare/voltron
        cd voltron
        ./install.sh -b lldb
    fi
fi

# ipython settings
if type ipython &>/dev/null; then
    if [ ! -e ~/.ipython/profile_default/ipython_config.py ] || [ x$(grep  'c\.InteractiveShellApp\.matplotlib[ \t]*=' ~/.ipython/profile_default/ipython_config.py -c) != x1 ]; then
        mkdir -p ~/.ipython/profile_default
        echo "c.InteractiveShellApp.matplotlib = 'inline'" >> ~/.ipython/profile_default/ipython_config.py
    fi
fi

# generate cpp_tags
echo -e '\033[31mGenerate cpp tags...\033[0m'
test ! type g++ &>/dev/null || test ! type ctags &>/dev/null || test -f ~/cpp_tags || ~/bin/generate_tags.sh

if [ x$1 == xall ]; then
    echo -e '\033[31mInit ssh authorized_keys...\033[0m'
    # init ssh authorized_keys
    test -d ~/.ssh || mkdir ~/.ssh
    cd ~/.ssh
    if cmp ${script_path}/.ssh/id_rsa.pub id_rsa.pub ; then
        echo 'Local file ~/.ssh/id_rsa.pub exist, ignore it'
    elif [ -f authorized_keys ] && [ x$(grep -F $(awk '{print $2}' ${script_path}/.ssh/id_rsa.pub) authorized_keys -c) == x1 ]; then
        echo 'Authorized_keys exist'
    else
        cat ${script_path}/.ssh/id_rsa.pub >> authorized_keys
    fi
fi
