#!/bin/bash

begin=$(date "+%s")
os=$(uname | tr '[:upper:]' '[:lower:]')
script_path="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

red() { printf '\033[31m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
ensure_dir() { [ -d "$1" ] || mkdir -p "$1"; }
ensure_link() {
    local src=$1
    local dst=$2

    if [ -L "$dst" ]; then
        local current
        current=$(readlink "$dst" 2>/dev/null || true)
        if [ "$current" = "$src" ]; then
            return 0
        fi
    fi
    if [ -e "$dst" ]; then
        echo "skip $dst (exists)"
        return 0
    fi
    ln -s "$src" "$dst"
}

# update submodule
{
    red 'Update submodules...'
    cd "${script_path}"
    git submodule update --init --recursive
    git submodule update --remote
    yellow 'Update submodules finish.'
}&

# for .* file only
red 'Init dotfiles...'
cd ~
while IFS= read -r -d '' file; do
    base=$(basename "$file")
    ensure_link "$file" "$HOME/$base"
done < <(find "$script_path" -maxdepth 1 -mindepth 1 -name ".*" ! -name ".gitmodules" ! -name "*.zwc" ! -name ".git" ! -type d -print0)

# for .aria2
ensure_link "${script_path}/.aria2" "$HOME/.aria2"

# for .pip
ensure_link "${script_path}/.pip" "$HOME/.pip"

# for .config
ensure_dir "$HOME/.config"
while IFS= read -r -d '' entry; do
    name=$(basename "$entry")
    if [ -L "$entry" ]; then
        echo "skip .config/$name"
        continue
    fi
    if [ -d "$entry" ]; then
        ensure_dir "$HOME/.config/$name"
        while IFS= read -r -d '' child; do
            child_name=$(basename "$child")
            ensure_link "$child" "$HOME/.config/$name/$child_name"
        done < <(find "$entry" -maxdepth 1 -mindepth 1 ! -name ".gitmodules" ! -name "*.zwc" -print0)
    else
        ensure_link "$entry" "$HOME/.config/$name"
    fi
done < <(find "$script_path/.config" -maxdepth 1 -mindepth 1 ! -name ".gitmodules" ! -name "*.zwc" ! -name "nvim" -print0)

# for neovim
# if [ ! -d ~/.config/lvim ]; then
#     bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
#     rm ~/.config/lvim/config.lua
#     ln -s ${script_path}/.config/lvim/config.lua ~/.config/lvim/config.lua
#     lvim +LvimUpdate +q
#     lvim +TSInstallSync +q
#     lvim +TSUpdateSync +q
#     lvim +LvimSyncCorePlugins +qa
# fi
# install LazyVim
if [ ! -e "$HOME/.config/nvim/lua/config" ]; then
    if [ -d "$HOME/.config/nvim" ]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
    fi
    if [ -d "$HOME/.local/share/nvim" ]; then
        mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak"
    fi
    if [ -d "$HOME/.cache/nvim" ]; then
        mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak"
    fi
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    rm -rf "$HOME/.config/nvim/lua/config"
    rm -rf "$HOME/.config/nvim/lua/plugins"
    ensure_link "$script_path/.config/nvim/lua/config" "$HOME/.config/nvim/lua/config"
    ensure_link "$script_path/.config/nvim/lua/plugins" "$HOME/.config/nvim/lua/plugins"
fi

# for tmuxinator
ensure_link "${script_path}/tmuxinator" "$HOME/.tmuxinator"  # for linux
# for tmux
cd ~
ensure_link "${script_path}/.tmux/.tmux.conf" "$HOME/.tmux.conf"

# ipython settings
# if type ipython &>/dev/null; then
#     if [ ! -e ~/.ipython/profile_default/ipython_config.py ] || [ x$(grep  'c\.InteractiveShellApp\.matplotlib[ \t]*=' ~/.ipython/profile_default/ipython_config.py -c) != x1 ]; then
#         mkdir -p ~/.ipython/profile_default
#         echo "c.InteractiveShellApp.matplotlib = 'inline'" >> ~/.ipython/profile_default/ipython_config.py
#     fi
# fi

# git mirrors
# git config --global url."https://hub.fastgit.org".insteadOf https://github.com

# brew
if ! command_exists brew && [ "$os" = "darwin" ]; then
    red 'Install brew...'
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew tap Homebrew/homebrew-cask
    brew tap Homebrew/homebrew-cask-fonts
    brew tap Homebrew/homebrew-cask-drivers
fi

# brew mirrors
if command_exists brew && command_exists git; then
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
# test -e ~/.vim/coc-settings.json || ln -s ${script_path}/.vim/coc-settings.json ~/.vim/coc-settings.json
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

# install oh-my-zsh
if type zsh &>/dev/null; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
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
# if type go &>/dev/null && ! type go-langserver &>/dev/null; then
#     {
#         go get -u github.com/sourcegraph/go-langserver
#         go get -u -v github.com/mdempsky/gocode
#         go get -u -v github.com/golang/lint/golint
#         go get -u -v golang.org/x/tools/cmd/guru
#         go get -u -v golang.org/x/tools/cmd/goimports
#         go get -u -v golang.org/x/tools/cmd/gorename
#     }&
# fi

yellow 'Init dotfiles finish.'

# for bin/*
red 'Init scripts...'
ensure_dir "$HOME/bin"
cd ~/bin
while IFS= read -r -d '' binfile; do
    base=$(basename "$binfile")
    ensure_link "$binfile" "$HOME/bin/$base"
done < <(find "$script_path/bin" -maxdepth 1 -mindepth 1 -print0)
yellow 'Init scripts finish.'

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

if [ "x${1-}" = xall ]; then
    red 'Init ssh authorized_keys...'
    # init ssh authorized_keys
    test -d ~/.ssh || mkdir ~/.ssh
    cd ~/.ssh
    if cmp "${script_path}/.ssh/id_rsa.pub" id_rsa.pub; then
        echo 'Local file ~/.ssh/id_rsa.pub exist, ignore it'
    elif [ -f authorized_keys ] && [ x$(grep -F "$(awk '{print $2}' "${script_path}/.ssh/id_rsa.pub")" authorized_keys -c) == x1 ]; then
        echo 'Authorized_keys exist'
    else
        cat "${script_path}/.ssh/id_rsa.pub" >> authorized_keys
    fi
    yellow 'Init ssh authorized_keys finish.'
fi

wait
end=$(date "+%s")
echo -e "\033[33mSetup finish in $(expr "$end" - "$begin") seconds.\033[0m"
