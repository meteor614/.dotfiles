#!/bin/bash

begin=`date "+%s"`

script_path=$(cd $(dirname "${bash_source-$0}") && pwd)

# update submodule
{
    echo -e '\033[31mUpdate submodules...\033[0m'
    cd ${script_path}
    git submodule update --init --recursive 
    echo -e '\033[33mUpdate submodules finish.\033[0m'
}&

# for .* file only
echo -e '\033[31mInit dotfiles...\033[0m'
cd ~
files=($(ls -FA ${script_path}|grep '^\..*[^/]$'|grep -v '^\.gitmodules$'|grep -v '\.zwc$'))
for i in ${files[@]}; do
    ln -s ${script_path}/${i}
done

# for .aria2
ln -s ${script_path}/.aria2

# for .pip
ln -s ${script_path}/.pip

# brew mirrors
if type brew &>/dev/null && type git &>/dev/null; then
    cd "$(brew --repo)"
    git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
    git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask
    git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git
fi

# for .config
test -e ~/.config || mkdir ~/.config
cd ~/.config
files=($(ls -FA ${script_path}/.config|grep '.*[^/]$'|grep -v '^\.gitmodules$'|grep -v '\.zwc$'))
for i in ${files[@]}; do
    ln -s ${script_path}/.config/${i}
done

# for neovim
test -e ~/.vim || mkdir ~/.vim
ln -s ~/.vimrc ~/.vim/init.vim
test -e nvim || ln -s ~/.vim nvim
# for coc.nvim
ln -s ${script_path}/.vim/coc-settings.json ~/.vim/coc-settings.json
if type g++ &>/dev/null && type brew &>/dev/null && ! type cquery &>/dev/null; then
    brew install cquery
fi
if type npm &>/dev/null; then
    if ! type bash-language-server &>/dev/null; then
        npm i -g bash-language-server
    fi
    if ! type docker-langserver &>/dev/null; then
        npm i -g dockerfile-language-server-nodejs
    fi
fi
if type luarocks &>/dev/null && ! type lua-lsp &>/dev/null; then
    luarocks install --server=http://luarocks.org/dev lua-lsp
fi
if type go &>/dev/null && ! type go-langserver &>/dev/null; then
    go get -u github.com/sourcegraph/go-langserver
fi

# for tmuxinator
ln -s ${script_path}/tmuxinator                                         # for mac
test -e ~/.tmuxinator || ln -s ${script_path}/tmuxinator ~/.tmuxinator  # for linux

# for tmux
cd ~
ln -s ${script_path}/.tmux/.tmux.conf

# ipython settings
if type ipython &>/dev/null; then
    if [ ! -e ~/.ipython/profile_default/ipython_config.py ] || [ x$(grep  'c\.InteractiveShellApp\.matplotlib[ \t]*=' ~/.ipython/profile_default/ipython_config.py -c) != x1 ]; then
        mkdir -p ~/.ipython/profile_default
        echo "c.InteractiveShellApp.matplotlib = 'inline'" >> ~/.ipython/profile_default/ipython_config.py
    fi
fi

echo -e '\033[33mInit dotfiles finish.\033[0m'

# for bin/*
echo -e '\033[31mInit scripts...\033[0m'
test -d ~/bin || mkdir ~/bin
cd ~/bin
files=($(ls ${script_path}/bin))
for i in ${files[@]}; do
    ln -s ${script_path}/bin/${i}
done
#test -f ~/.vim/plugged/YCM-Generator/config_gen.py && ln -s ~/.vim/plugged/YCM-Generator/config_gen.py
echo -e '\033[33mInit scripts finish.\033[0m'

# install/update gdb-dashboard
if type gdb &>/dev/null; then
    {
        if [ -d ~/gdb-dashboard ]; then
            echo -e '\033[31mUpdate gdb-dashboard...\033[0m'
            cd ~/gdb-dashboard
            git pull
            echo -e '\033[33mUpdate gdb-dashboard finish.\033[0m'
        else
            echo -e '\033[31mGet gdb-dashboard...\033[0m'
            cd ~
            git clone https://github.com/cyrus-and/gdb-dashboard
            echo -e '\033[33mGet gdb-dashboard finish.\033[0m'
        fi
    }&
fi

# install/update voltron
if type lldb &>/dev/null; then
    {
        if [ -d ~/voltron ]; then
            echo -e '\033[31mUpdate voltron...\033[0m'
            cd ~/voltron
            git pull
            echo -e '\033[33mUpdate voltron finish.\033[0m'
        else
            echo -e '\033[31mGet & install voltron...\033[0m'
            cd ~
            git clone https://github.com/snare/voltron
            cd voltron
            ./install.sh -b lldb
            voltron_script=$(grep '^command script import .*/voltron/entry.py$' ~/.lldbinit|awk '{print $4}'|awk -F'/lib/' '{print $1"/bin/voltron"}')
            if [ -f ${voltron_script} ]; then
                ln -s ${voltron_script} ~/bin
            fi
            echo -e '\033[33mGet & install voltron finish.\033[0m'
        fi
    }&
fi

# generate cpp_tags
if type g++ &>/dev/null && type ctags &>/dev/null && [ ! -f ~/cpp_tags ]; then
    {
        echo -e '\033[31mGenerate cpp tags...\033[0m'
        ~/bin/generate_tags.sh
        echo -e '\033[33mGenerate cpp tags finish.\033[0m'
    }&
fi

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
    echo -e '\033[33mInit ssh authorized_keys finish.\033[0m'
    # luarocks install --server=http://luarocks.org/dev lua-lsp
    # npm install -g dockerfile-language-server-nodejs
    # npm i -g bash-language-server
    # brew install cquery
    # go get -u github.com/sourcegraph/go-langserver
    #  go get -u -v github.com/mdempsky/gocode
    #  go get -u -v github.com/golang/lint/golint
    #  go get -u -v golang.org/x/tools/cmd/guru
    #  go get -u -v golang.org/x/tools/cmd/goimports
    #  go get -u -v golang.org/x/tools/cmd/gorename

    # gem install neovim
    # pip install neovim
    # npm install -g neovim
fi

wait
end=`date "+%s"`
echo -e "\033[33mSetup finish in `expr $end - $begin` seconds.\033[0m"

