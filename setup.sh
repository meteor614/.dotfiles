#!/bin/bash

set -euo pipefail

begin=$(date "+%s")
os=$(uname | tr '[:upper:]' '[:lower:]')
script_path="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

MODE="init"
BOOTSTRAP_NVIM=0
INIT_AUTHORIZED_KEYS=0
CHECK_FAILED=0
BACKUP_SUFFIX="$(date "+%Y%m%d%H%M%S")"

brew_formulae=(
    ack antigen autossh cheat clang-format cloc cmake coreutils cpulimit cscope
    ctags curl fd ffmpeg findutils fontconfig freetype fzf gawk git global
    gnu-getopt gnutls go gotags htop icdiff jq jsoncpp lua luajit luarocks mycli
    neovim ninja numpy oniguruma openssl osxutils pandoc parallel perl protobuf
    pstree psutils python readline ripgrep rtags rtmpdump ruby snappy sqlite
    starship swig telnet tig tmux tmux-xpanes tmuxinator tmuxinator-completion
    tree vim vnstat watch wget xz yarn yarn-completion yazi zellij zsh cppman
    bat reattach-to-user-namespace eza lazygit procs dust cargo atuin
    imagemagick bottom sd broot choose glow
)
brew_casks=(
    font-hack-nerd-font
    font-fira-code
    font-sarasa-gothic
)

background_pids=()

red() { printf '\033[31m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
ensure_dir() { [ -d "$1" ] || mkdir -p "$1"; }

usage() {
    cat <<'EOF'
Usage: setup.sh [init|check|repair] [all] [--bootstrap-nvim]

Commands:
  init            Create missing links and install missing dependencies (default)
  check           Report missing/mismatched links without writing changes
  repair          Backup and repair mismatched links

Flags:
  all             Also append this repo's public key to ~/.ssh/authorized_keys
  --bootstrap-nvim
                  Explicitly adopt LazyVim starter in ~/.config/nvim
EOF
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            init)
                MODE="init"
                ;;
            check|--check)
                MODE="check"
                ;;
            repair|--repair|--force)
                MODE="repair"
                ;;
            all)
                INIT_AUTHORIZED_KEYS=1
                ;;
            --bootstrap-nvim)
                BOOTSTRAP_NVIM=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                red "Unknown argument: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

track_background() {
    "$@" &
    background_pids+=("$!")
}

wait_for_background_jobs() {
    local pid
    local status=0

    if [ "${#background_pids[@]}" -eq 0 ]; then
        return 0
    fi

    for pid in "${background_pids[@]}"; do
        if ! wait "$pid"; then
            status=1
        fi
    done

    return "$status"
}

backup_existing_path() {
    local path=$1
    local backup="${path}.bak.${BACKUP_SUFFIX}"
    local index=1

    while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="${path}.bak.${BACKUP_SUFFIX}.${index}"
        index=$((index + 1))
    done

    mv "$path" "$backup"
    yellow "backup $path -> $backup"
}

mark_check_failure() {
    CHECK_FAILED=1
}

ensure_directory_target() {
    local dst=$1

    if [ -d "$dst" ] && [ ! -L "$dst" ]; then
        return 0
    fi

    case "$MODE" in
        check)
            yellow "check: directory mismatch $dst"
            mark_check_failure
            return 1
            ;;
        repair)
            if [ -e "$dst" ] || [ -L "$dst" ]; then
                backup_existing_path "$dst"
            fi
            mkdir -p "$dst"
            ;;
        *)
            if [ -e "$dst" ] || [ -L "$dst" ]; then
                echo "skip $dst (exists)"
                return 1
            fi
            mkdir -p "$dst"
            ;;
    esac
}

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

    if [ "$MODE" = "check" ]; then
        if [ -e "$dst" ] || [ -L "$dst" ]; then
            yellow "check: link mismatch $dst -> $src"
        else
            yellow "check: missing link $dst -> $src"
        fi
        mark_check_failure
        return 0
    fi

    ensure_dir "$(dirname "$dst")"

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ "$MODE" = "repair" ]; then
            backup_existing_path "$dst"
        else
            echo "skip $dst (exists)"
            return 0
        fi
    fi

    ln -s "$src" "$dst"
}

ensure_git_clone() {
    local repo=$1
    local dst=$2
    shift 2

    if [ -e "$dst" ]; then
        echo "skip $dst (exists)"
        return 0
    fi

    ensure_dir "$(dirname "$dst")"
    git clone "$@" "$repo" "$dst"
}

load_nvm_default_node() {
    local nvm_dir="${NVM_DIR:-$HOME/.nvm}"

    [ -s "$nvm_dir/nvm.sh" ] || return 0

    export NVM_DIR="$nvm_dir"
    # shellcheck disable=SC1090
    . "$NVM_DIR/nvm.sh"
    nvm use default >/dev/null 2>&1 || true
}

init_submodules() {
    red 'Init submodules...'
    (
        cd "${script_path}"
        git submodule update --init --recursive
    )
    yellow 'Init submodules finish.'
}

link_top_level_dotfiles() {
    red 'Init dotfiles...'
    while IFS= read -r -d '' file; do
        local base
        base=$(basename "$file")
        ensure_link "$file" "$HOME/$base"
    done < <(find "$script_path" -maxdepth 1 -mindepth 1 -name ".*" ! -name ".gitmodules" ! -name "*.zwc" ! -name ".git" ! -type d -print0)

    ensure_link "${script_path}/.aria2" "$HOME/.aria2"
    ensure_link "${script_path}/.pip" "$HOME/.pip"
    yellow 'Init dotfiles finish.'
}

link_config_entries() {
    local entry
    local name
    local child
    local child_name

    ensure_dir "$HOME/.config"
    while IFS= read -r -d '' entry; do
        name=$(basename "$entry")
        if [ -d "$entry" ] && [ ! -L "$entry" ]; then
            if ! ensure_directory_target "$HOME/.config/$name"; then
                continue
            fi

            while IFS= read -r -d '' child; do
                child_name=$(basename "$child")
                ensure_link "$child" "$HOME/.config/$name/$child_name"
            done < <(find "$entry" -maxdepth 1 -mindepth 1 ! -name ".gitmodules" ! -name "*.zwc" -print0)
        else
            ensure_link "$entry" "$HOME/.config/$name"
        fi
    done < <(find "$script_path/.config" -maxdepth 1 -mindepth 1 ! -name ".gitmodules" ! -name "*.zwc" ! -name "nvim" -print0)
}

bootstrap_lazyvim_starter() {
    local home_nvim="$HOME/.config/nvim"
    local home_share="$HOME/.local/share/nvim"
    local home_cache="$HOME/.cache/nvim"
    local marker="$home_nvim/.dotfiles-lazyvim-starter"

    if [ "$MODE" = "check" ]; then
        if [ ! -e "$marker" ]; then
            yellow "check: nvim starter not bootstrapped ($home_nvim)"
            mark_check_failure
        fi
        return 0
    fi

    if [ -d "$home_nvim" ]; then
        backup_existing_path "$home_nvim"
    elif [ -L "$home_nvim" ]; then
        backup_existing_path "$home_nvim"
    fi

    if [ -d "$home_share" ] || [ -L "$home_share" ]; then
        backup_existing_path "$home_share"
    fi
    if [ -d "$home_cache" ] || [ -L "$home_cache" ]; then
        backup_existing_path "$home_cache"
    fi

    git clone https://github.com/LazyVim/starter "$home_nvim"
    rm -rf "$home_nvim/.git"
    rm -rf "$home_nvim/lua/config"
    rm -rf "$home_nvim/lua/plugins"
    ensure_link "$script_path/.config/nvim/lua/config" "$home_nvim/lua/config"
    ensure_link "$script_path/.config/nvim/lua/plugins" "$home_nvim/lua/plugins"
    touch "$marker"
}

setup_neovim() {
    local home_nvim="$HOME/.config/nvim"
    local marker="$home_nvim/.dotfiles-lazyvim-starter"
    local config_link="$home_nvim/lua/config"
    local plugins_link="$home_nvim/lua/plugins"

    if [ -e "$marker" ] || [ -L "$config_link" ] || [ -L "$plugins_link" ]; then
        ensure_dir "$home_nvim/lua"
        ensure_link "$script_path/.config/nvim/lua/config" "$config_link"
        ensure_link "$script_path/.config/nvim/lua/plugins" "$plugins_link"
        if [ "$MODE" != "check" ]; then
            [ -e "$marker" ] || touch "$marker"
        fi
        return 0
    fi

    if [ "$BOOTSTRAP_NVIM" -eq 1 ]; then
        bootstrap_lazyvim_starter
        return 0
    fi

    yellow "skip ~/.config/nvim (unmanaged); rerun with --bootstrap-nvim to adopt LazyVim starter"
}

link_tmux_and_bin() {
    red 'Init scripts...'
    ensure_link "${script_path}/tmuxinator" "$HOME/.tmuxinator"
    ensure_link "${script_path}/.tmux/.tmux.conf" "$HOME/.tmux.conf"

    ensure_dir "$HOME/bin"
    while IFS= read -r -d '' binfile; do
        local base
        base=$(basename "$binfile")
        ensure_link "$binfile" "$HOME/bin/$base"
    done < <(find "$script_path/bin" -maxdepth 1 -mindepth 1 -print0)
    yellow 'Init scripts finish.'
}

ensure_brew_tap_remote() {
    local tap=$1
    local remote=$2
    local repo

    if [ "$tap" = "brew" ]; then
        repo=$(brew --repo)
    else
        if ! brew tap | grep -qx "$tap"; then
            return 0
        fi
        repo=$(brew --repo "$tap")
    fi

    git -C "$repo" remote set-url origin "$remote"
}

install_missing_brew_packages() {
    local pkg
    local missing_formulae=()
    local missing_casks=()

    if ! command_exists brew; then
        return 0
    fi

    for pkg in "${brew_formulae[@]}"; do
        if ! brew list --formula "$pkg" >/dev/null 2>&1; then
            missing_formulae+=("$pkg")
        fi
    done

    for pkg in "${brew_casks[@]}"; do
        if ! brew list --cask "$pkg" >/dev/null 2>&1; then
            missing_casks+=("$pkg")
        fi
    done

    if [ "${#missing_formulae[@]}" -gt 0 ]; then
        brew install "${missing_formulae[@]}"
    fi

    if [ "${#missing_casks[@]}" -gt 0 ]; then
        brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
        brew install --cask "${missing_casks[@]}"
    fi
}

install_brew_if_needed() {
    if command_exists brew || [ "$os" != "darwin" ]; then
        return 0
    fi

    red 'Install brew...'
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

configure_brew_mirrors() {
    if ! command_exists brew || ! command_exists git; then
        return 0
    fi

    ensure_brew_tap_remote brew https://mirrors.cloud.tencent.com/homebrew/brew.git
    ensure_brew_tap_remote homebrew/core https://mirrors.cloud.tencent.com/homebrew/homebrew-core.git
    ensure_brew_tap_remote homebrew/cask https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
    ensure_brew_tap_remote homebrew/cask-fonts https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-fonts.git
    ensure_brew_tap_remote homebrew/cask-drivers https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-drivers.git
}

configure_package_mirrors() {
    if command_exists npm; then
        npm config set registry https://mirrors.tencent.com/npm/
    fi

    if command_exists gem; then
        if ! gem sources --list | grep -Fq 'http://mirrors.tencent.com/rubygems/'; then
            gem sources --add http://mirrors.tencent.com/rubygems/
        fi
        if gem sources --list | grep -Fq 'https://rubygems.org/'; then
            gem sources --remove https://rubygems.org/
        fi
    fi
}

npm_prefix_is_user_writable() {
    local prefix
    prefix=$(npm prefix -g 2>/dev/null || true)
    [ -n "$prefix" ] && [ -w "$prefix" ]
}

npm_global_package_installed() {
    local pkg=$1
    npm list -g --depth=0 "$pkg" >/dev/null 2>&1
}

python_package_installed() {
    local pkg=$1
    python3 -m pip show "$pkg" >/dev/null 2>&1
}

gem_package_installed() {
    local pkg=$1
    gem list -i "^${pkg}$" >/dev/null 2>&1
}

install_user_language_packages() {
    local npm_packages=()
    local python_candidates=(
        bpython
        pynvim
        python-lsp-server
    )
    local python_packages=()
    local pkg

    if command_exists python3; then
        if python3 -m pip --version >/dev/null 2>&1; then
            for pkg in "${python_candidates[@]}"; do
                python_package_installed "$pkg" || python_packages+=("$pkg")
            done
            if [ "${#python_packages[@]}" -gt 0 ]; then
                track_background python3 -m pip install --user "${python_packages[@]}"
            fi
        else
            yellow "skip python user packages (python3 -m pip unavailable)"
        fi
    fi

    if command_exists npm; then
        if npm_prefix_is_user_writable; then
            command_exists bash-language-server || npm_packages+=("bash-language-server")
            command_exists docker-langserver || npm_packages+=("dockerfile-language-server-nodejs")
            npm_global_package_installed neovim || npm_packages+=("neovim")

            if [ "${#npm_packages[@]}" -gt 0 ]; then
                track_background npm install -g "${npm_packages[@]}"
            fi
        else
            yellow "skip npm global packages (npm prefix is not user-writable)"
        fi
    fi

    if command_exists gem; then
        if ! gem_package_installed neovim; then
            track_background gem install --user-install neovim
        fi
    fi

    if command_exists luarocks && ! command_exists lua-lsp; then
        track_background luarocks install --server=http://luarocks.org/dev lua-lsp
    fi
}

install_oh_my_zsh_plugins() {
    local omz_dir
    local zsh_custom_dir

    if ! command_exists zsh; then
        return 0
    fi

    omz_dir="$HOME/.oh-my-zsh"
    zsh_custom_dir="${ZSH_CUSTOM:-$omz_dir/custom}"

    if [ ! -d "$omz_dir" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "skip $omz_dir (exists)"
    fi

    ensure_git_clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom_dir/plugins/zsh-autosuggestions"
    ensure_git_clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom_dir/plugins/zsh-syntax-highlighting"
}

setup_gdb_dashboard() {
    if ! command_exists gdb; then
        return 0
    fi

    if [ -d "$HOME/gdb-dashboard" ]; then
        echo "skip $HOME/gdb-dashboard (exists)"
        return 0
    fi

    track_background git clone https://github.com/cyrus-and/gdb-dashboard "$HOME/gdb-dashboard"
}

setup_voltron() {
    if ! command_exists lldb; then
        return 0
    fi

    if [ ! -d "$HOME/voltron" ]; then
        ensure_git_clone https://github.com/snare/voltron "$HOME/voltron"
    fi

    if command_exists voltron; then
        return 0
    fi

    (
        cd "$HOME/voltron"
        ./install.sh -b lldb
        voltron_script=$(grep '^command script import .*/voltron/entry.py$' "$HOME/.lldbinit" | awk '{print $4}' | awk -F'/lib/' '{print $1"/bin/voltron"}')
        if [ -n "${voltron_script:-}" ] && [ -f "$voltron_script" ]; then
            ensure_link "$voltron_script" "$HOME/bin/voltron"
        fi
    ) &
    background_pids+=("$!")
}

generate_cpp_tags_if_missing() {
    if command_exists g++ && command_exists ctags && [ ! -f "$HOME/cpp_tags" ]; then
        track_background "$HOME/bin/generate_tags.sh"
    fi
}

init_authorized_keys_if_requested() {
    if [ "$INIT_AUTHORIZED_KEYS" -ne 1 ]; then
        return 0
    fi

    red 'Init ssh authorized_keys...'
    ensure_dir "$HOME/.ssh"
    cd "$HOME/.ssh"
    if cmp "${script_path}/.ssh/id_rsa.pub" id_rsa.pub >/dev/null 2>&1; then
        echo 'Local file ~/.ssh/id_rsa.pub exist, ignore it'
    elif [ -f authorized_keys ] && [ "$(grep -F "$(awk '{print $2}' "${script_path}/.ssh/id_rsa.pub")" authorized_keys -c)" = "1" ]; then
        echo 'Authorized_keys exist'
    else
        cat "${script_path}/.ssh/id_rsa.pub" >> authorized_keys
    fi
    yellow 'Init ssh authorized_keys finish.'
}

run_setup() {
    if [ "$MODE" != "check" ]; then
        init_submodules
    fi

    link_top_level_dotfiles
    link_config_entries
    setup_neovim
    link_tmux_and_bin

    if [ "$MODE" = "check" ]; then
        return 0
    fi

    load_nvm_default_node
    install_brew_if_needed
    configure_brew_mirrors
    install_missing_brew_packages
    configure_package_mirrors
    install_user_language_packages
    install_oh_my_zsh_plugins

    setup_gdb_dashboard
    setup_voltron
    generate_cpp_tags_if_missing
    init_authorized_keys_if_requested
}

parse_args "$@"
run_setup
wait_for_background_jobs

if [ "$MODE" = "check" ] && [ "$CHECK_FAILED" -ne 0 ]; then
    red 'Setup check detected mismatches.'
    exit 1
fi

end=$(date "+%s")
echo -e "\033[33mSetup (${MODE}) finish in $(expr "$end" - "$begin") seconds.\033[0m"
