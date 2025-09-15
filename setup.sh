#!/bin/bash

begin=`date "+%s"`
os=$(uname|tr '[:upper:]' '[:lower:]')
script_path=$(cd $(dirname "${bash_source-$0}") && pwd)

# update submodule
{
    echo -e '\033[31mUpdate submodules...\033[0m'
    cd ${script_path}
    git submodule update --init --recursive 
    git submodule update --remote
    echo -e '\033[33mUpdate submodules finish.\033[0m'
}&

# for .* file only
echo -e '\033[31mInit dotfiles...\033[0m'
cd ~
files=($(ls -FA ${script_path}|grep '^\..*[^/]$'|grep -v '^\.gitmodules$'|grep -v '\.zwc$'))
for i in ${files[@]}; do
    test -e ${i} || ln -s ${script_path}/${i}
done

# for .aria2
test -e .aria2 || ln -s ${script_path}/.aria2

# for .pip
test -e .pip || ln -s ${script_path}/.pip

# for .config
test -e ~/.config || mkdir ~/.config
files=($(ls -A ${script_path}/.config|grep '.*[^/]$'|grep -v '^\.gitmodules$'|grep -v '\.zwc$'|grep -v '^nvim$'))
for i in ${files[@]}; do
    if [ -L ${script_path}/.config/${i} ]; then
        echo "skip .config/${i}"
    elif [ -d ${script_path}/.config/${i} ]; then
        test -e ~/.config/${i} || mkdir ~/.config/${i}
        cd ~/.config/${i}
        files2=($(ls -A ${script_path}/.config/${i}|grep -v '^\.gitmodules$'|grep -v '\.zwc$'))
        for j in ${files2[@]}; do
            test -e ${j} || ln -s ${script_path}/.config/${i}/${j}
        done
    else
        cd ~/.config
        test -e ${i} || ln -s ${script_path}/.config/${i}
    fi
done

# for neovim
if [ ! -d ~/.config/lvim ]; then
    bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
    rm ~/.config/lvim/config.lua
    ln -s ${script_path}/.config/lvim/config.lua ~/.config/lvim/config.lua
    lvim +LvimUpdate +q
    lvim +TSInstallSync +q
    lvim +TSUpdateSync +q
    lvim +LvimSyncCorePlugins +qa
fi

# for tmuxinator
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

# git mirrors
# git config --global url."https://hub.fastgit.org".insteadOf https://github.com

# brew
if ! type brew &>/dev/null && [ "$os" = "darwin" ]; then
    echo -e '\033[31mInstall brew...\033[0m'
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew tap Homebrew/homebrew-cask
    brew tap Homebrew/homebrew-cask-fonts
    brew tap Homebrew/homebrew-cask-drivers
fi

# brew mirrors
if type brew &>/dev/null && type git &>/dev/null; then
    #git -C "$(brew --repo)" remote set-url origin https://github.com/homebrew/brew.git
    #git -C "$(brew --repo homebrew/core)" remote set-url origin https://github.com/Homebrew/homebrew-core.git
    #git -C "$(brew --repo homebrew/cask)" remote set-url origin https://github.com/homebrew/homebrew-cask.git
    #git -C "$(brew --repo homebrew/cask-fonts)" remote set-url origin https://github.com/homebrew/homebrew-cask-fonts.git
    #git -C "$(brew --repo homebrew/cask-drivers)" remote set-url origin https://github.com/homebrew/homebrew-cask-drivers.git

    git -C "$(brew --repo)" remote set-url origin https://mirrors.cloud.tencent.com/homebrew/brew.git
    git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.cloud.tencent.com/homebrew/homebrew-core.git
    git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
    git -C "$(brew --repo homebrew/cask-fonts)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-fonts.git
    git -C "$(brew --repo homebrew/cask-drivers)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-drivers.git
fi
# install package
if type brew &>/dev/null && ! type nvim &>/dev/null; then
    brew install ack antigen autossh cheat clang-format cloc cmake coreutils cpulimit cquery cscope ctags curl fd ffmpeg findutils fontconfig freetype fzf gawk git global gnu-getopt gnutls go gotags htop icdiff jq jsoncpp lua luajit luarocks mycli neovim ninja node numpy oniguruma openssl osxutils pandoc parallel perl protobuf pstree psutils python readline ripgrep rtags rtmpdump ruby snappy sqlite swig telnet tig tmux tmux-xpanes tmuxinator tmuxinator-completion tree vim vnstat watch wget xz yarn yarn-completion zsh cppman bat reattach-to-user-namespace exa lazygit procs dust cargo
    brew install font-hack-nerd-font font-fira-code font-sarasa-gothic
    # brew install qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize suspicious-package quicklookase qlvideo
fi
# npm mirrors
if type npm &>/dev/null; then
    npm config set registry https://mirrors.tencent.com/npm/
fi
# gem mirrors
if type gem &>/dev/null; then
    gem sources --add http://mirrors.tencent.com/rubygems/ --remove https://rubygems.org/
fi

# for coc.nvim
test -e ~/.vim/coc-settings.json || ln -s ${script_path}/.vim/coc-settings.json ~/.vim/coc-settings.json
if type g++ &>/dev/null && type brew &>/dev/null && ! type cquery &>/dev/null; then
    brew install cquery
fi
# python
if type python3 &>/dev/null && ! type pip &>/dev/null; then
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && rm get-pip.py
    python3 -m pip install bpython
fi
if type python3 &>/dev/null; then
    python3 -m pip install python-language-server pynvim &
fi
# if type python2 &>/dev/null; then
#     python2 -m pip install python-language-server pynvim &
# fi
# npm
if type npm &>/dev/null; then
    {
        if ! type bash-language-server &>/dev/null; then
            sudo npm i -g bash-language-server
        fi
        if ! type docker-langserver &>/dev/null; then
            sudo npm i -g dockerfile-language-server-nodejs
        fi
        sudo npm install -g neovim
    }&
fi
# gem
if type gem &>/dev/null; then
    gem install neovim &
fi
# lua
if type luarocks &>/dev/null && ! type lua-lsp &>/dev/null; then
    luarocks install --server=http://luarocks.org/dev lua-lsp &
fi
# go
if type go &>/dev/null && ! type go-langserver &>/dev/null; then
    {
        go get -u github.com/sourcegraph/go-langserver
        go get -u -v github.com/mdempsky/gocode
        go get -u -v github.com/golang/lint/golint
        go get -u -v golang.org/x/tools/cmd/guru
        go get -u -v golang.org/x/tools/cmd/goimports
        go get -u -v golang.org/x/tools/cmd/gorename
    }&
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
echo -e '\033[33mInit scripts finish.\033[0m'

# install/update gdb-dashboard
if type gdb &>/dev/null; then
    {
        if [ -d ~/gdb-dashboard ]; then
            echo -e '\033[31mUpdate gdb-dashboard...\033[0m'
            cd ~/gdb-dashboard
            git pull --no-rebase
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
            git pull --no-rebase
            echo -e '\033[33mUpdate voltron finish.\033[0m'
        else
            echo -e '\033[31mGet & install voltron...\033[0m'
            cd ~
            git clone https://github.com/snare/voltron
            cd voltron
        fi
        if ! type voltron &>/dev/null; then
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

if [ x$1 = xall ]; then
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
fi

wait
end=`date "+%s"`
echo -e "\033[33mSetup finish in `expr $end - $begin` seconds.\033[0m"

