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
    cheat clang-format cloc cmake coreutils cpulimit cscope
    ctags curl fd ffmpeg findutils fontconfig freetype fzf gawk git global
    gnu-getopt gnutls go gotags htop icdiff jq jsoncpp lua luajit luarocks mycli
    neovim ninja numpy oniguruma openssl pandoc parallel perl protobuf
    pstree psutils python readline ripgrep rtags rtmpdump ruby snappy sqlite
    starship swig telnet tig tmux tmux-xpanes tmuxinator tmuxinator-completion
    tree vnstat watch wget xz yarn yarn-completion yazi zellij zsh cppman
    bat reattach-to-user-namespace eza lazygit procs dust direnv rust atuin
    imagemagick bottom sd broot choose glow zoxide ouch mise topgrade jj ast-grep yq duf
)
brew_casks=(
    font-hack-nerd-font
    font-fira-code
    font-sarasa-gothic
)

# Linux/Synology: tools we install from GitHub release tarballs into ~/bin/.
# Synology DSM has no brew and no sudo; Entware (/opt/bin) and synocli already
# provide eza, fzf, zoxide, bat, rg, fd, btop, procs, sd — those are skipped.
# Format: <name>|<api_repo>|<download_url>|<bin_path_inside_archive>
# Use {VER} to interpolate the latest tag stripped of the leading 'v'; {TAG} keeps the leading 'v'.
linux_release_tools=(
    "topgrade|topgrade-rs/topgrade|https://github.com/topgrade-rs/topgrade/releases/download/{TAG}/topgrade-{TAG}-x86_64-unknown-linux-musl.tar.gz|topgrade"
    "starship|starship/starship|https://github.com/starship/starship/releases/download/{TAG}/starship-x86_64-unknown-linux-musl.tar.gz|starship"
    "zoxide|ajeetdsouza/zoxide|https://github.com/ajeetdsouza/zoxide/releases/download/{TAG}/zoxide-{VER}-x86_64-unknown-linux-musl.tar.gz|zoxide"
    "atuin|atuinsh/atuin|https://github.com/atuinsh/atuin/releases/download/{TAG}/atuin-x86_64-unknown-linux-musl.tar.gz|atuin-x86_64-unknown-linux-musl/atuin"
    "lazygit|jesseduffield/lazygit|https://github.com/jesseduffield/lazygit/releases/download/{TAG}/lazygit_{VER}_Linux_x86_64.tar.gz|lazygit"
    "delta|dandavison/delta|https://github.com/dandavison/delta/releases/download/{TAG}/delta-{TAG}-x86_64-unknown-linux-musl.tar.gz|delta-{TAG}-x86_64-unknown-linux-musl/delta"
    "dust|bootandy/dust|https://github.com/bootandy/dust/releases/download/{TAG}/dust-{TAG}-x86_64-unknown-linux-musl.tar.gz|dust-{TAG}-x86_64-unknown-linux-musl/dust"
    "hyperfine|sharkdp/hyperfine|https://github.com/sharkdp/hyperfine/releases/download/{TAG}/hyperfine-{TAG}-x86_64-unknown-linux-musl.tar.gz|hyperfine-{TAG}-x86_64-unknown-linux-musl/hyperfine"
    "gitui|extrawurst/gitui|https://github.com/extrawurst/gitui/releases/download/{TAG}/gitui-linux-x86_64.tar.gz|gitui"
    "fastfetch|fastfetch-cli/fastfetch|https://github.com/fastfetch-cli/fastfetch/releases/download/{TAG}/fastfetch-linux-amd64.tar.gz|fastfetch-linux-amd64/usr/bin/fastfetch"
    "zellij|zellij-org/zellij|https://github.com/zellij-org/zellij/releases/download/{TAG}/zellij-x86_64-unknown-linux-musl.tar.gz|zellij"
    "yazi|sxyazi/yazi|https://github.com/sxyazi/yazi/releases/download/{TAG}/yazi-x86_64-unknown-linux-musl.zip|yazi-x86_64-unknown-linux-musl/yazi"
)

# Entware packages available on Synology DSM via /opt/bin/opkg.
# These are kept small — anything tricky comes from linux_release_tools above.
entware_packages=(
    eza fzf fd zoxide
)

# GitHub release downloads from this NAS occasionally hit SSL timeouts; first
# try a mirror, then fall back to direct. Override via DOTFILES_GH_MIRROR=...
# (set to empty string to disable the mirror entirely).
GH_MIRROR_DEFAULT="https://gh-proxy.com/"

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

    # Mise manages runtimes — if it's available, sync its env into this shell.
    # Use hook-env (one-shot env sync) rather than activate, which installs
    # precmd/chpwd hooks intended for interactive rc files and is a no-op
    # in a non-sourced setup script.
    if command -v mise >/dev/null 2>&1; then
        eval "$(mise hook-env -s bash 2>/dev/null)" || true
        return 0
    fi

    [ -s "$nvm_dir/nvm.sh" ] || return 0

    export NVM_DIR="$nvm_dir"
    # shellcheck disable=SC1090
    . "$NVM_DIR/nvm.sh"
    nvm use default >/dev/null 2>&1 || true
}

init_submodules() {
    # Skip when every registered submodule already has a matching checkout
    # (status lines starting with "-" or "+" mean uninitialized/out-of-sync).
    if [ -f "${script_path}/.gitmodules" ]; then
        local status
        status=$(git -C "${script_path}" submodule status 2>/dev/null || true)
        if [ -n "$status" ] && ! printf '%s\n' "$status" | grep -qE '^[-+]'; then
            echo 'skip submodules (already initialized)'
            return 0
        fi
    fi

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
    done < <(find "$script_path" -maxdepth 1 -mindepth 1 -name ".*" ! -name ".gitmodules" ! -name ".gitignore" ! -name ".ripgreprc" ! -name ".envrc" ! -name "*.zwc" ! -name ".git" ! -type d -print0)

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

    if [ "$MODE" = "check" ]; then
        if [ -e "$marker" ] || [ -L "$config_link" ] || [ -L "$plugins_link" ]; then
            if [ ! -e "$marker" ]; then
                yellow "check: nvim marker missing ($marker); repair will recreate it"
                mark_check_failure
            fi
            ensure_link "$script_path/.config/nvim/lua/config" "$config_link"
            ensure_link "$script_path/.config/nvim/lua/plugins" "$plugins_link"
        else
            yellow "check: ~/.config/nvim unmanaged; rerun with --bootstrap-nvim to adopt LazyVim starter"
        fi
        return 0
    fi

    if [ -e "$marker" ] || [ -L "$config_link" ] || [ -L "$plugins_link" ]; then
        ensure_dir "$home_nvim/lua"
        ensure_link "$script_path/.config/nvim/lua/config" "$config_link"
        ensure_link "$script_path/.config/nvim/lua/plugins" "$plugins_link"
        [ -e "$marker" ] || touch "$marker"
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

# ---------------------------------------------------------------------------
# Linux package installers (Entware + GitHub release tarballs)
# ---------------------------------------------------------------------------

# Detect a Synology DSM box. We do NOT gate Linux installs on this — the
# release-tarball path works on any glibc/musl x86_64 Linux — but the Entware
# step is Synology/router-specific and only runs when /opt/bin/opkg is present.
is_synology() {
    [ -f /etc.defaults/VERSION ] || [ -d /var/packages ]
}

# Fetch a URL via the GitHub mirror, then fall back to direct.
gh_dl() {
    local url=$1
    local out=$2
    local mirror=${DOTFILES_GH_MIRROR-$GH_MIRROR_DEFAULT}
    if [ -n "$mirror" ]; then
        if curl -fsSL --connect-timeout 15 --max-time 240 "${mirror}${url}" -o "$out"; then
            return 0
        fi
    fi
    curl -fsSL --connect-timeout 15 --max-time 240 "$url" -o "$out"
}

# Resolve the latest release tag for a repo. api.github.com is queried
# directly (the gh-proxy mirror returns 403 for the API) and the response is
# parsed without jq so this works on barebones Synology shells.
gh_latest_tag() {
    local repo=$1
    local response tag
    local curl_args=(-fsSL --connect-timeout 10 --max-time 30)

    if [ -n "${GITHUB_TOKEN:-}" ]; then
        curl_args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
    fi

    response=$(curl "${curl_args[@]}" \
        "https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null) || {
        yellow "GitHub API lookup failed for $repo; set GITHUB_TOKEN if rate-limited, or check network/proxy access to api.github.com" >&2
        return 1
    }

    tag=$(printf '%s\n' "$response" \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' \
        | head -1)
    if [ -z "$tag" ]; then
        yellow "GitHub API response for $repo did not include a latest release tag; set GITHUB_TOKEN if this is a rate-limit issue" >&2
        return 1
    fi

    printf '%s\n' "$tag"
}

# Install one tool entry from linux_release_tools.
# Args: name, repo, url_template, bin_path_template
install_linux_release_tool() {
    local name=$1
    local repo=$2
    local url_tpl=$3
    local bin_tpl=$4
    local target="$HOME/bin/$name"

    if [ -x "$target" ]; then
        return 0
    fi

    local tag ver url bin_path
    tag=$(gh_latest_tag "$repo")
    if [ -z "$tag" ]; then
        yellow "skip $name (could not resolve latest tag for $repo)"
        return 0
    fi
    ver="${tag#v}"

    url=${url_tpl//\{TAG\}/$tag}
    url=${url//\{VER\}/$ver}
    bin_path=${bin_tpl//\{TAG\}/$tag}
    bin_path=${bin_path//\{VER\}/$ver}

    local workdir
    workdir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-$name.XXXXXX")
    # shellcheck disable=SC2064
    trap "rm -rf '$workdir'" RETURN

    local archive="$workdir/pkg"
    if ! gh_dl "$url" "$archive"; then
        yellow "skip $name (download failed: $url)"
        return 0
    fi

    case "$url" in
        *.zip)
            if command_exists unzip; then
                (cd "$workdir" && unzip -o -q pkg)
            elif [ -x /opt/bin/unzip ]; then
                (cd "$workdir" && /opt/bin/unzip -o -q pkg)
            else
                yellow "skip $name (need unzip for $url)"
                return 0
            fi
            ;;
        *.tar.gz|*.tgz)
            (cd "$workdir" && tar -xzf pkg)
            ;;
        *)
            yellow "skip $name (unknown archive type: $url)"
            return 0
            ;;
    esac

    if [ ! -f "$workdir/$bin_path" ]; then
        yellow "skip $name (binary not found at $bin_path inside archive)"
        return 0
    fi

    ensure_dir "$HOME/bin"
    mv "$workdir/$bin_path" "$target"
    chmod +x "$target"
    echo "installed $name -> $target"
}

install_linux_release_tools() {
    if [ "$os" != "linux" ]; then
        return 0
    fi
    if ! command_exists curl || ! command_exists tar; then
        yellow "skip linux release tools (curl or tar missing)"
        return 0
    fi

    red 'Install linux release tools...'
    local entry name repo url bin_path
    for entry in "${linux_release_tools[@]}"; do
        IFS='|' read -r name repo url bin_path <<<"$entry"
        install_linux_release_tool "$name" "$repo" "$url" "$bin_path"
    done
    yellow 'Install linux release tools finish.'
}

install_entware_packages() {
    if [ "$os" != "linux" ] || [ ! -x /opt/bin/opkg ]; then
        return 0
    fi

    local pkg installed missing=()
    installed=$(/opt/bin/opkg list-installed 2>/dev/null | awk '{print $1}')
    for pkg in "${entware_packages[@]}"; do
        if ! printf '%s\n' "$installed" | grep -qx "$pkg"; then
            missing+=("$pkg")
        fi
    done

    [ "${#missing[@]}" -eq 0 ] && return 0

    red "Install entware packages: ${missing[*]}"
    # opkg writes to /opt — needs root. Try without sudo first (some Synology
    # boxes let the user write /opt directly), then sudo -n if available.
    if /opt/bin/opkg install "${missing[@]}" 2>/dev/null; then
        return 0
    fi
    if command_exists sudo && sudo -n true 2>/dev/null; then
        sudo /opt/bin/opkg install "${missing[@]}" || yellow "opkg install failed"
    else
        yellow "skip opkg install (need root); run manually: sudo /opt/bin/opkg install ${missing[*]}"
    fi
}

configure_brew_mirrors() {
    if ! command_exists brew || ! command_exists git; then
        return 0
    fi

    ensure_brew_tap_remote brew https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    ensure_brew_tap_remote homebrew/core https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    ensure_brew_tap_remote homebrew/cask https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
    ensure_brew_tap_remote homebrew/cask-fonts https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-fonts.git
    ensure_brew_tap_remote homebrew/cask-drivers https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-drivers.git
}

configure_package_mirrors() {
    local configure_language_mirrors="${DOTFILES_CONFIGURE_LANGUAGE_MIRRORS:-${USE_CN_MIRROR:-1}}"
    if [ "$configure_language_mirrors" != "1" ]; then
        return 0
    fi

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

    # Mise: install configured runtimes (versions from .config/mise/config.toml).
    # `mise install` is idempotent and exits quickly when versions are present,
    # so just always invoke it rather than trying to detect-and-skip (which is
    # tricky — `mise ls` lists configured-but-uninstalled tools too). Errors are
    # reported instead of swallowed, since python builds in particular often
    # fail on missing system headers (openssl/xz/libffi).
    if command_exists mise; then
        track_background mise install --yes || yellow "mise install failed (see above)"
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

init_authorized_keys_if_requested() {
    if [ "$INIT_AUTHORIZED_KEYS" -ne 1 ]; then
        return 0
    fi

    red 'Init ssh authorized_keys...'
    ensure_dir "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    local src_pub="${script_path}/.ssh/id_rsa.pub"
    local auth_file="$HOME/.ssh/authorized_keys"

    if [ ! -f "$src_pub" ]; then
        yellow "skip authorized_keys (missing $src_pub)"
        return 0
    fi

    if cmp -s "$src_pub" "$HOME/.ssh/id_rsa.pub" 2>/dev/null; then
        echo 'Local ~/.ssh/id_rsa.pub matches repo key; leaving authorized_keys alone'
        return 0
    fi

    # Read the repo's public key (first line only, stripped of trailing newline).
    local pubkey
    pubkey=$(awk 'NR==1' "$src_pub")
    if [ -z "$pubkey" ]; then
        yellow "skip authorized_keys (empty $src_pub)"
        return 0
    fi

    # Append only if this exact line is not already present.
    if [ -f "$auth_file" ] && grep -Fxq -- "$pubkey" "$auth_file"; then
        echo 'Authorized_keys already contains this key'
    else
        # Ensure trailing newline before appending so entries never collide.
        if [ -s "$auth_file" ] && [ "$(tail -c 1 "$auth_file" 2>/dev/null)" != "" ]; then
            printf '\n' >> "$auth_file"
        fi
        printf '%s\n' "$pubkey" >> "$auth_file"
        chmod 600 "$auth_file"
    fi
    yellow 'Init ssh authorized_keys finish.'
}

# Install herdr's stock claude hook script into ~/.claude. The other
# Claude-Code-compatible config dirs (~/.claude-internal, ~/.codebuddy)
# go through link_custom_herdr_hook below so we can label them
# distinctly in herdr's sidebar.
# Symlinking is unsafe — herdr's installer overwrites the hook file in
# place, so a shared symlink would let one uninstall remove all of them.
install_herdr_integrations() {
    if ! command_exists herdr; then
        return 0
    fi

    red 'Init herdr integrations...'

    local dir
    for dir in "$HOME/.claude"; do
        if [ -d "$dir" ]; then
            CLAUDE_CONFIG_DIR="$dir" herdr integration install claude \
                || yellow "herdr integration install claude failed for $dir"
        fi
    done

    yellow 'Init herdr integrations finish.'
}

# ~/.reasonix mixes runtime data (sessions/, version-cache.json)
# with user-managed config (config.json, settings.json, hooks/), so we symlink only the
# files we own. Reasonix has no built-in herdr integration — these hooks
# report agent state to herdr's socket API, modeled on the official
# claude integration hook.
link_reasonix_herdr_integration() {
    local src_dir="$script_path/.reasonix"
    [ -d "$src_dir" ] || return 0

    # Reasonix reads config.toml from ~/.reasonix/config.toml
    # (model/provider config, project overrides via ./reasonix.toml).
    # Hooks config lives in ~/.reasonix/settings.json.
    ensure_dir "$HOME/.reasonix/hooks"
    ensure_link "$src_dir/settings.json"            "$HOME/.reasonix/settings.json"
    ensure_link "$src_dir/hooks/herdr-agent-state.sh" "$HOME/.reasonix/hooks/herdr-agent-state.sh"

    # Deploy model/provider config to ~/.reasonix/ so it stays alongside hooks/settings.
    local config_dst="$HOME/.reasonix/config.toml"
    ensure_dir "$(dirname "$config_dst")"
    ensure_link "$src_dir/config.toml" "$config_dst"
}

# Symlink a hand-written herdr hook script into a Claude-Code-compatible
# agent's config dir, then merge the dotfiles `hooks` block into the
# agent's settings.json (which also holds gateway/model/etc. owned by the
# agent itself). Used for both claude-internal and codebuddy so each pane
# carries the right agent label in herdr's sidebar (rather than all being
# tagged "claude" by herdr's stock installer).
#
# args: <dotfiles-subdir-name> <target-dir>
#   dotfiles-subdir-name: directory under $script_path that holds
#     hooks/herdr-agent-state.sh + hooks-settings.json
#   target-dir: the agent's actual config dir, e.g. $HOME/.codebuddy
link_custom_herdr_hook() {
    local subdir="$1"
    local target_dir="$2"
    local src_dir="$script_path/$subdir"
    [ -d "$src_dir" ] || return 0
    [ -d "$target_dir" ] || return 0

    ensure_dir "$target_dir/hooks"
    ensure_link "$src_dir/hooks/herdr-agent-state.sh" "$target_dir/hooks/herdr-agent-state.sh"

    local settings="$target_dir/settings.json"
    local hooks_src="$src_dir/hooks-settings.json"
    [ -f "$hooks_src" ] || return 0

    if ! command_exists jq; then
        yellow "skip $subdir settings.json hooks merge: jq not installed"
        return 0
    fi

    if [ ! -f "$settings" ]; then
        printf '{}\n' > "$settings"
    fi

    local tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/herdr-hook-merge.XXXXXX.json")"
    if jq -s '.[0] * {hooks: .[1].hooks}' "$settings" "$hooks_src" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$settings"
    else
        rm -f "$tmp"
        yellow "$subdir settings.json merge failed; left untouched"
    fi
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
    if [ "$os" = "darwin" ]; then
        install_brew_if_needed
        configure_brew_mirrors
        install_missing_brew_packages
    else
        install_entware_packages
        install_linux_release_tools
    fi
    configure_package_mirrors
    install_user_language_packages
    install_oh_my_zsh_plugins

    init_authorized_keys_if_requested
    install_herdr_integrations
    link_reasonix_herdr_integration
    link_custom_herdr_hook ".claude-internal" "$HOME/.claude-internal"
    link_custom_herdr_hook ".codebuddy"       "$HOME/.codebuddy"
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
