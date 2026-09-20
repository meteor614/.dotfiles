#!/bin/bash

set -euo pipefail

begin=$(date "+%s")
os=$(uname | tr '[:upper:]' '[:lower:]')
script_path="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

MODE="init"
BOOTSTRAP_NVIM=0
DRY_RUN=0
ONLY_SECTIONS=""
CHECK_FAILED=0
BACKUP_SUFFIX="$(date "+%Y%m%d%H%M%S")"

brew_formulae=(
    cheat clang-format cloc cmake coreutils cpulimit cscope
    ctags curl fd ffmpeg findutils fontconfig freetype fzf gawk git global
    gnu-getopt gnutls go gotags htop icdiff jq jsoncpp lua luajit luarocks mycli
    neovim ninja numpy oniguruma openssl@3 pandoc parallel perl protobuf
    pstree psutils python@3.14 readline ripgrep rtags rtmpdump ruby snappy sqlite
    starship swig telnet tig tmux tmux-xpanes tmuxinator tmuxinator-completion
    tree vnstat watch wget xz yarn yarn-completion yazi zellij zsh cppman
    bat reattach-to-user-namespace eza lazygit procs dust direnv rust atuin
    imagemagick bottom sd broot choose glow zoxide ouch mise topgrade jj ast-grep yq duf git-delta pipx shellcheck
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
# Use {LINUX_ARCH} and tool-specific aliases for GitHub asset architectures selected by uname -m.
# Integrity: starship/atuin/lazygit/zellij ship official checksums and are
# verified before install (see checksum_url_for); the rest are installed
# unverified because upstream publishes no digests — adding a tool here with
# checksum assets only requires extending checksum_url_for.
linux_release_tools=(
    "topgrade|topgrade-rs/topgrade|https://github.com/topgrade-rs/topgrade/releases/download/{TAG}/topgrade-{TAG}-{LINUX_ARCH}-unknown-linux-musl.tar.gz|topgrade"
    "starship|starship/starship|https://github.com/starship/starship/releases/download/{TAG}/starship-{LINUX_ARCH}-unknown-linux-musl.tar.gz|starship"
    "zoxide|ajeetdsouza/zoxide|https://github.com/ajeetdsouza/zoxide/releases/download/{TAG}/zoxide-{VER}-{LINUX_ARCH}-unknown-linux-musl.tar.gz|zoxide"
    "atuin|atuinsh/atuin|https://github.com/atuinsh/atuin/releases/download/{TAG}/atuin-{LINUX_ARCH}-unknown-linux-musl.tar.gz|atuin-{LINUX_ARCH}-unknown-linux-musl/atuin"
    "lazygit|jesseduffield/lazygit|https://github.com/jesseduffield/lazygit/releases/download/{TAG}/lazygit_{VER}_Linux_{LINUX_ARCH_LAZYGIT}.tar.gz|lazygit"
    "delta|dandavison/delta|https://github.com/dandavison/delta/releases/download/{TAG}/delta-{TAG}-{LINUX_ARCH}-unknown-linux-musl.tar.gz|delta-{TAG}-{LINUX_ARCH}-unknown-linux-musl/delta"
    "dust|bootandy/dust|https://github.com/bootandy/dust/releases/download/{TAG}/dust-{TAG}-{LINUX_ARCH}-unknown-linux-musl.tar.gz|dust-{TAG}-{LINUX_ARCH}-unknown-linux-musl/dust"
    "hyperfine|sharkdp/hyperfine|https://github.com/sharkdp/hyperfine/releases/download/{TAG}/hyperfine-{TAG}-{LINUX_ARCH}-unknown-linux-musl.tar.gz|hyperfine-{TAG}-{LINUX_ARCH}-unknown-linux-musl/hyperfine"
    "gitui|extrawurst/gitui|https://github.com/extrawurst/gitui/releases/download/{TAG}/gitui-linux-{LINUX_ARCH}.tar.gz|gitui"
    "fastfetch|fastfetch-cli/fastfetch|https://github.com/fastfetch-cli/fastfetch/releases/download/{TAG}/fastfetch-linux-{LINUX_ARCH_FASTFETCH}.tar.gz|fastfetch-linux-{LINUX_ARCH_FASTFETCH}/usr/bin/fastfetch"
    "zellij|zellij-org/zellij|https://github.com/zellij-org/zellij/releases/download/{TAG}/zellij-{LINUX_ARCH}-unknown-linux-musl.tar.gz|zellij"
    "yazi|sxyazi/yazi|https://github.com/sxyazi/yazi/releases/download/{TAG}/yazi-{LINUX_ARCH}-unknown-linux-musl.zip|yazi-{LINUX_ARCH}-unknown-linux-musl/yazi"
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
# Newline-delimited list (NAS ships bash 3.2; `local -a` is unsupported there).
_temp_dirs=""

red() { printf '\033[31m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
ensure_dir() {
    [ -d "$1" ] && return 0
    # check mode is strictly read-only; a missing parent dir is already
    # reported by ensure_link as a missing link.
    [ "$MODE" = "check" ] && return 0
    if [ "$DRY_RUN" = "1" ]; then
        yellow "[dry-run] would create dir $1"
        return 0
    fi
    mkdir -p "$1"
}

register_temp_dir() { _temp_dirs="${_temp_dirs}${1}
"; }
remove_temp_dir() {
    _temp_dirs=$(printf '%s\n' "$_temp_dirs" | grep -Fxv "$1" || true)
}

cleanup_temp_dirs() {
    local d
    [ -n "$_temp_dirs" ] || return 0
    while IFS= read -r d; do
        [ -n "$d" ] && [ -d "$d" ] && rm -rf -- "$d"
    done < <(printf '%s\n' "$_temp_dirs")
    _temp_dirs=""
}

# Kill still-running tracked background jobs and drop temp dirs on any exit,
# including Ctrl-C mid-install. EXIT fires after an INT/TERM trap exits, so
# one handler is enough.
_dotfiles_cleanup_on_exit() {
    local _pid
    for _pid in ${background_pids[@]+"${background_pids[@]}"}; do
        kill "$_pid" 2>/dev/null || true
    done
    cleanup_temp_dirs
}
setup_exit_trap() {
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap _dotfiles_cleanup_on_exit EXIT
}

usage() {
    cat <<'EOF'
Usage: setup.sh [init|check|repair|prune] [--bootstrap-nvim] [--dry-run] [--only SECTION]

Commands:
  init            Create missing links and install missing dependencies (default)
  check           Report missing/mismatched links without writing changes
  repair          Backup and repair mismatched links
  prune           Remove stale links under the managed roots that point back into
                  this repo but whose source no longer exists (and stale *.zwc).
                  Honors --only: prune runs when its sections are selected
                  (stale *.zwc cleanup belongs to the links section).

Flags:
  --bootstrap-nvim
                  Explicitly adopt LazyVim starter in ~/.config/nvim

  --dry-run       Print what would be done without executing any installs.
                  Links are still checked (read-only) but never created.
                  Combine with --only to preview a subset of sections.

  --only SECTION  Run only the named section(s). Comma-separated list.
                  Note: --only does not pull in dependencies. To install packages
                  on a fresh machine you usually need `--only runtimes,packages`
                  (and `herdr` also needs the `links` section first).
                  Available sections:
                    links      — dotfile symlinks (top-level, .config, bin)
                    nvim       — Neovim / LazyVim bootstrap
                    brew       — Homebrew install + formulae/casks  (macOS only)
                    entware    — Entware opkg packages              (Linux/Synology)
                    releases   — GitHub release binaries → ~/bin   (Linux/Synology)
                    runtimes   — mise install + nvm default node
                    mirrors    — Homebrew + package manager mirrors
                    packages   — npm/pip/gem language packages
                    zsh        — zsh plugin clones
                    herdr      — herdr agent integrations
EOF
}

# Valid section names for --only
VALID_SECTIONS="links nvim brew entware releases runtimes mirrors packages zsh herdr"

section_requested() {
    # With no --only filter, every section runs.
    [ -z "$ONLY_SECTIONS" ] && return 0
    printf '%s\n' "$ONLY_SECTIONS" | tr ',' '\n' | grep -qx "$1"
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
            prune|--prune)
                MODE="prune"
                ;;
            --bootstrap-nvim)
                BOOTSTRAP_NVIM=1
                ;;
            --dry-run)
                DRY_RUN=1
                ;;
            --only)
                shift
                [ "$#" -gt 0 ] || { red "--only requires a section name"; usage; exit 1; }
                ONLY_SECTIONS="$1"
                # Validate section names early so typos fail fast.
                local sec
                for sec in $(printf '%s\n' "$ONLY_SECTIONS" | tr ',' ' '); do
                    if ! printf '%s\n' $VALID_SECTIONS | grep -qx "$sec"; then
                        red "Unknown section: $sec (valid: $VALID_SECTIONS)"
                        exit 1
                    fi
                done
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

# ---------------------------------------------------------------------------
# track_background — run a command in the background and remember its PID
# ---------------------------------------------------------------------------
track_background() {
    "$@" &
    background_pids+=("$!")
}
setup_exit_trap

linux_release_arch() {
    case "$(uname -m)" in
        x86_64|amd64) printf '%s\n' x86_64 ;;
        aarch64|arm64) printf '%s\n' aarch64 ;;
        *) return 1 ;;
    esac
}

linux_release_arch_lazygit() {
    case "$(uname -m)" in
        x86_64|amd64) printf '%s\n' x86_64 ;;
        aarch64|arm64) printf '%s\n' arm64 ;;
        *) return 1 ;;
    esac
}

linux_release_arch_fastfetch() {
    case "$(uname -m)" in
        x86_64|amd64) printf '%s\n' amd64 ;;
        aarch64|arm64) printf '%s\n' aarch64 ;;
        *) return 1 ;;
    esac
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

# ---------------------------------------------------------------------------
# resolve_path — canonicalize a path, tolerating a missing final component
# (e.g. a dangling symlink). Uses `readlink -f` where available (GNU coreutils
# and macOS 12.3+); otherwise chases the link manually.
# ---------------------------------------------------------------------------
resolve_path() {
    local out p dir base

    out=$(readlink -f "$1" 2>/dev/null) || true
    if [ -n "$out" ]; then
        printf '%s\n' "$out"
        return 0
    fi

    p=$1
    while [ -L "$p" ]; do
        base=$(readlink "$p" 2>/dev/null || true)
        [ -n "$base" ] || break
        case "$base" in
            /*) p=$base ;;
            *) p="$(dirname -- "$p")/$base" ;;
        esac
    done

    dir=$(dirname -- "$p")
    base=$(basename -- "$p")
    if [ -d "$dir" ]; then
        printf '%s/%s\n' "$(cd -P -- "$dir" && pwd)" "$base"
    else
        printf '%s\n' "$p"
    fi
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
            if [ "$DRY_RUN" = "1" ]; then
                yellow "[dry-run] would backup and recreate directory $dst"
                return 1
            fi
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
            if [ "$DRY_RUN" = "1" ]; then
                yellow "[dry-run] would create directory $dst"
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
        # Accept an equivalent path too: a relative link, or one that only
        # differs because a parent directory is itself a symlink (e.g.
        # /etc vs /private/etc on macOS). Compare canonicalized targets.
        if [ -n "$current" ] && \
           [ "$(resolve_path "$dst")" = "$(resolve_path "$src")" ]; then
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

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            yellow "[dry-run] would skip $dst (exists, not linked)"
            return 0
        elif [ "$MODE" = "repair" ]; then
            backup_existing_path "$dst"
        else
            echo "skip $dst (exists)"
            return 0
        fi
    elif [ "$DRY_RUN" = "1" ]; then
        [ -d "$(dirname "$dst")" ] \
            || yellow "[dry-run] would create dir $(dirname "$dst")"
        yellow "[dry-run] would link $dst -> $src"
        return 0
    fi

    ensure_dir "$(dirname "$dst")"
    ln -s "$src" "$dst"
}

ensure_git_clone() {
    local repo=$1
    local dst=$2
    shift 2

    # A dangling symlink passes neither -e nor -d, but `git clone` still
    # refuses the path — drop it first (unless this is a --dry-run), then treat
    # as missing.
    if [ -L "$dst" ] && [ ! -e "$dst" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            yellow "[dry-run] would remove dangling link $dst"
        else
            rm -f -- "$dst"
        fi
    fi

    if [ -e "$dst" ]; then
        echo "skip $dst (exists)"
        return 0
    fi

    if [ "$DRY_RUN" = "1" ]; then
        yellow "[dry-run] would clone $repo -> $dst"
        return 0
    fi

    ensure_dir "$(dirname "$dst")"
    git clone "$@" "$repo" "$dst"
}

# ---------------------------------------------------------------------------
# Stale-link / stale-artifact pruning
#
# `check`/`repair` only look at the links setup.sh would (re)create, so they
# never notice links left behind by *removed* config entries. These helpers
# scan the managed roots for:
#   * dangling symlinks whose target lives inside this repo, and
#   * *.zwc files that are older than the file they were compiled from.
# ---------------------------------------------------------------------------

# Roots/pruning depth managed by setup.sh — "<root>\t<maxdepth>". Depth is
# relative to the root (1 = immediate children). Only links that resolve into
# this repo are ever touched, so unrelated user links are safe.
managed_scan_specs() {
    printf '%s\t1\n' "$HOME"
    printf '%s\t2\n' "$HOME/.config"
    printf '%s\t1\n' "$HOME/bin"
    printf '%s\t2\n' "$HOME/.vim"
    # Agent-CLI config dirs that used to be linked by setup.sh.
    printf '%s\t3\n' "$HOME/.pi"
    printf '%s\t2\n' "$HOME/.reasonix"
    printf '%s\t2\n' "$HOME/.codebuddy"
    printf '%s\t2\n' "$HOME/.claude-internal"
}

# find_managed_links — NUL-separated list of candidate symlinks.
find_managed_links() {
    local root depth
    while IFS="$(printf '\t')" read -r root depth; do
        [ -n "$root" ] && [ -d "$root" ] || continue
        find "$root" -maxdepth "$depth" -mindepth 1 -type l -print0 2>/dev/null
    done < <(managed_scan_specs)
}

# is_repo_dangling_link <link> — true when <link> is a broken symlink that
# points (lexically) into this repository.
is_repo_dangling_link() {
    local link=$1 target

    [ -L "$link" ] || return 1
    [ -e "$link" ] && return 1           # resolves fine — not dangling

    target=$(readlink "$link" 2>/dev/null || true)
    [ -n "$target" ] || return 1
    case "$target" in
        /*) ;;
        *) target="$(dirname -- "$link")/$target" ;;
    esac
    target=$(resolve_path "$target")

    case "$target" in
        "$script_path"/*) return 0 ;;
        *) return 1 ;;
    esac
}

# report_dangling_links — print repo-owned dangling links (check mode).
report_dangling_links() {
    local link found=0

    while IFS= read -r -d '' link; do
        if is_repo_dangling_link "$link"; then
            yellow "check: dangling link $link -> $(readlink "$link")"
            found=1
        fi
    done < <(find_managed_links)

    [ "$found" -eq 1 ] && mark_check_failure
    return 0
}

# prune_stale_zwc — remove *.zwc that is older than the file it was compiled
# from (zsh compdump, or a sourced rc file). A stale compiled dump is always
# regenerable, so removing it is safe; a *.zwc with no sibling source is left
# alone. Honors $DRY_RUN.
prune_stale_zwc() {
    local zwc src root

    for root in "$HOME" "$HOME/bin" "$HOME/.config" \
                "$HOME/.zsh_cache" "${ZSH_CACHE_DIR:-$HOME/.zsh_cache}"; do
        [ -n "$root" ] && [ -d "$root" ] || continue
        while IFS= read -r -d '' zwc; do
            src=${zwc%.zwc}
            [ -f "$src" ] || continue
            [ "$zwc" -ot "$src" ] || continue
            if [ "$DRY_RUN" = "1" ]; then
                yellow "[dry-run] would remove stale $zwc (older than $src)"
            else
                rm -f -- "$zwc"
                yellow "prune: removed stale $zwc (older than $src)"
            fi
        done < <(find "$root" -maxdepth 1 -mindepth 1 -name '*.zwc' -print0 2>/dev/null)
    done
}

# prune_managed_links — delete repo-owned dangling links + stale *.zwc.
# Honors $DRY_RUN.
prune_managed_links() {
    local link removed=0

    while IFS= read -r -d '' link; do
        if is_repo_dangling_link "$link"; then
            if [ "$DRY_RUN" = "1" ]; then
                yellow "[dry-run] would remove dangling link $link"
            else
                rm -f -- "$link"
                yellow "prune: removed dangling link $link"
            fi
            removed=$((removed + 1))
        fi
    done < <(find_managed_links)

    prune_stale_zwc

    if [ "$removed" -eq 0 ]; then
        echo 'prune: no dangling links found'
    fi
    return 0
}

# remove_dangling_links — repair-mode counterpart of report_dangling_links:
# delete repo-owned dangling links (they have no content, no backup needed).
# Honors $DRY_RUN like prune_managed_links. Never touches *.zwc — that stays
# prune's job.
remove_dangling_links() {
    local link removed=0

    while IFS= read -r -d '' link; do
        if is_repo_dangling_link "$link"; then
            if [ "$DRY_RUN" = "1" ]; then
                yellow "[dry-run] would remove dangling link $link"
            else
                rm -f -- "$link"
                yellow "repair: removed dangling link $link"
            fi
            removed=$((removed + 1))
        fi
    done < <(find_managed_links)

    [ "$removed" -eq 0 ] && echo 'repair: no dangling links found'
    return 0
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
            done < <(find "$entry" -maxdepth 1 -mindepth 1 ! -name ".gitmodules" ! -name "*.zwc" ! -name "package.toml" -print0)
        else
            ensure_link "$entry" "$HOME/.config/$name"
        fi
    done < <(find "$script_path/.config" -maxdepth 1 -mindepth 1 ! -name ".gitmodules" ! -name "*.zwc" ! -name "nvim" -print0)
}

# ---------------------------------------------------------------------------
# warn_unmanaged_nvim_entries — ~/.config/nvim is a LazyVim starter tree, so
# this repo only owns `lua/config` and `lua/plugins` (linked by setup_neovim);
# everything else under .config/nvim is excluded from link_config_entries and
# would NOT be deployed. Warn about anything we now track there so a new
# subdirectory is not silently dropped.
# ---------------------------------------------------------------------------
warn_unmanaged_nvim_entries() {
    local src_nvim="$script_path/.config/nvim"
    [ -d "$src_nvim" ] || return 0

    local rel
    while IFS= read -r -d '' rel; do
        rel=${rel#"$src_nvim"/}
        case "$rel" in
            lua/config/*|lua/plugins/*) ;;
            *)
                yellow "warn: .config/nvim/$rel is not linked (only lua/config, lua/plugins are managed)"
                ;;
        esac
    done < <(find "$src_nvim" -type f ! -name '.gitmodules' -print0 2>/dev/null)
    return 0
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

    if [ "$DRY_RUN" = "1" ]; then
        yellow "[dry-run] would bootstrap LazyVim starter into $home_nvim (backing up existing nvim dirs)"
        return 0
    fi

    # Clone into a temp dir FIRST: a network/API failure must never leave the
    # user's existing nvim tree half-moved into .bak backups.
    local tmpdir
    tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-lazyvim.XXXXXX")
    register_temp_dir "$tmpdir"
    if ! git clone https://github.com/LazyVim/starter "$tmpdir/starter"; then
        remove_temp_dir "$tmpdir"
        cleanup_temp_dirs
        red "LazyVim starter clone failed; existing nvim config left untouched"
        return 1
    fi
    rm -rf "$tmpdir/starter/.git"
    rm -rf "$tmpdir/starter/lua/config" "$tmpdir/starter/lua/plugins"

    if [ -d "$home_nvim" ] || [ -L "$home_nvim" ]; then
        backup_existing_path "$home_nvim"
    fi
    if [ -d "$home_share" ] || [ -L "$home_share" ]; then
        backup_existing_path "$home_share"
    fi
    if [ -d "$home_cache" ] || [ -L "$home_cache" ]; then
        backup_existing_path "$home_cache"
    fi

    ensure_dir "$(dirname "$home_nvim")"
    mv "$tmpdir/starter" "$home_nvim"
    remove_temp_dir "$tmpdir"
    cleanup_temp_dirs

    ensure_link "$script_path/.config/nvim/lua/config" "$home_nvim/lua/config"
    ensure_link "$script_path/.config/nvim/lua/plugins" "$home_nvim/lua/plugins"
    touch "$marker"
}

setup_neovim() {
    local home_nvim="$HOME/.config/nvim"
    local marker="$home_nvim/.dotfiles-lazyvim-starter"
    local config_link="$home_nvim/lua/config"
    local plugins_link="$home_nvim/lua/plugins"

    warn_unmanaged_nvim_entries

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
    if ! command_exists brew; then
        return 0
    fi

    local missing_formulae=()
    local missing_casks=()
    local installed_formulae installed_casks pkg

    # One `brew list` per kind instead of one fork per package (60+ calls).
    # `brew list -1` prints every installed formula/cask (including deps), so
    # exact-name membership is sufficient. Keep versioned formulae explicit
    # (e.g. python@3.14, openssl@3) instead of Homebrew aliases to avoid
    # repeated "already installed" warnings.
    installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
    for pkg in "${brew_formulae[@]}"; do
        printf '%s\n' "$installed_formulae" | grep -qxF -- "$pkg" || missing_formulae+=("$pkg")
    done

    installed_casks="$(brew list --cask -1 2>/dev/null || true)"
    for pkg in "${brew_casks[@]}"; do
        printf '%s\n' "$installed_casks" | grep -qxF -- "$pkg" || missing_casks+=("$pkg")
    done

    [ "${#missing_formulae[@]}" -gt 0 ] && brew install "${missing_formulae[@]}"
    # --adopt lets Homebrew take ownership of matching artifacts that already
    # exist outside brew, common for fonts restored from backup/iCloud.
    [ "${#missing_casks[@]}" -gt 0 ] && brew install --cask --adopt "${missing_casks[@]}"
    return 0
}

install_brew_if_needed() {
    if command_exists brew || [ "$os" != "darwin" ]; then
        return 0
    fi

    red 'Install brew...'
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

# Homebrew's installer only updates shell profiles; the current setup process
# still has the pre-install PATH. Eval `brew shellenv` so formulae installed in
# this same run (mise, etc.) are visible to later steps.
sync_brew_shellenv() {
    [ "$os" = "darwin" ] || return 0

    local brew_bin="" candidate brew_shellenv
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$candidate" ]; then
            brew_bin="$candidate"
            break
        fi
    done
    [ -n "$brew_bin" ] || return 0

    brew_shellenv="$("$brew_bin" shellenv 2>/dev/null)" || return 0
    eval "$brew_shellenv"
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
# check_mode=1 skips the mirror — used for checksum files, which must come
# from the canonical GitHub release so a mirror cannot fake both artifact and
# digest.
gh_dl() {
    local url=$1
    local out=$2
    local check_mode=${3:-0}
    local mirror=${DOTFILES_GH_MIRROR-$GH_MIRROR_DEFAULT}
    if [ -n "$mirror" ] && [ "$check_mode" != "1" ]; then
        if curl -fsSL --connect-timeout 15 --max-time 240 "${mirror}${url}" -o "$out"; then
            return 0
        fi
    fi
    curl -fsSL --connect-timeout 15 --max-time 240 "$url" -o "$out"
}

# sha256_of — print the sha256 hex digest of a file (GNU or BSD tool).
sha256_of() {
    if command_exists sha256sum; then
        sha256sum "$1" | cut -d' ' -f1
    elif command_exists shasum; then
        shasum -a 256 "$1" | cut -d' ' -f1
    else
        return 1
    fi
}

# verify_sha256 <file> <expected-hex>
verify_sha256() {
    local actual
    actual=$(sha256_of "$1") || return 1
    [ "$actual" = "$2" ]
}

# checksum_url_for — canonical checksum asset URL for verified release tools,
# derived from the download URL itself. Returns 1 for tools without official
# checksums (see the verify flag on linux_release_tools entries).
checksum_url_for() {
    local name=$1 url=$2 tag url_root
    case "$name" in
        starship|atuin)
            printf '%s.sha256\n' "$url"
            ;;
        lazygit)
            tag=$(printf '%s\n' "$url" | sed -n 's|.*/download/\([^/]*\)/.*|\1|p')
            printf 'https://github.com/jesseduffield/lazygit/releases/download/%s/checksums.txt\n' "$tag"
            ;;
        zellij)
            url_root=${url%.tar.gz}
            printf '%s.sha256sum\n' "$url_root"
            ;;
        topgrade|zoxide|delta|dust|hyperfine|gitui|fastfetch|yazi)
            return 1
            ;;
        *)
            return 1
            ;;
    esac
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

    local linux_arch linux_arch_lazygit linux_arch_fastfetch tag ver url bin_path
    linux_arch=$(linux_release_arch) || {
        yellow "skip $name (unsupported Linux architecture: $(uname -m))"
        return 0
    }
    linux_arch_lazygit=$(linux_release_arch_lazygit) || linux_arch_lazygit="$linux_arch"
    linux_arch_fastfetch=$(linux_release_arch_fastfetch) || linux_arch_fastfetch="$linux_arch"
    # set -e aborts the whole script if this command-substitution assignment
    # returns nonzero; absorb the exit so the -z skip below actually runs
    # instead of killing the entire install on a single API failure.
    tag=$(gh_latest_tag "$repo") || tag=""
    if [ -z "$tag" ]; then
        yellow "skip $name (could not resolve latest tag for $repo)"
        return 0
    fi
    ver="${tag#v}"

    url=${url_tpl//\{TAG\}/$tag}
    url=${url//\{VER\}/$ver}
    url=${url//\{LINUX_ARCH\}/$linux_arch}
    url=${url//\{LINUX_ARCH_LAZYGIT\}/$linux_arch_lazygit}
    url=${url//\{LINUX_ARCH_FASTFETCH\}/$linux_arch_fastfetch}
    bin_path=${bin_tpl//\{TAG\}/$tag}
    bin_path=${bin_path//\{VER\}/$ver}
    bin_path=${bin_path//\{LINUX_ARCH\}/$linux_arch}
    bin_path=${bin_path//\{LINUX_ARCH_LAZYGIT\}/$linux_arch_lazygit}
    bin_path=${bin_path//\{LINUX_ARCH_FASTFETCH\}/$linux_arch_fastfetch}

    local workdir
    workdir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-$name.XXXXXX")
    register_temp_dir "$workdir"
    # RETURN fires on every `return` path and is auto-cleared afterwards, so it
    # never clobbers the global EXIT handler (which kills background jobs).
    # Interruption between/before returns is covered by register_temp_dir +
    # the global EXIT trap's cleanup_temp_dirs.
    # shellcheck disable=SC2064
    trap "rm -rf -- '$workdir'" RETURN

    local archive="$workdir/pkg"
    if ! gh_dl "$url" "$archive"; then
        yellow "skip $name (download failed: $url)"
        return 0
    fi

    # Integrity: tools whose releases ship official checksums are verified
    # (checksum fetched from GitHub directly — never the mirror). A mismatch
    # triggers one direct re-download; still-bad or unavailable checksums
    # skip the tool rather than install an unverifiable binary.
    local cs_url cs_file want
    if cs_url=$(checksum_url_for "$name" "$url"); then
        cs_file="$workdir/pkg.sha256"
        if ! gh_dl "$cs_url" "$cs_file" 1; then
            yellow "skip $name (checksum fetch failed: $cs_url)"
            return 0
        fi
        want=$(grep -F -- "$(basename "$url")" "$cs_file" 2>/dev/null \
               | grep -oE '\b[0-9a-fA-F]{64}\b' | head -1)
        [ -n "$want" ] || want=$(grep -oE '\b[0-9a-fA-F]{64}\b' "$cs_file" | head -1)
        if [ -z "$want" ]; then
            yellow "skip $name (no usable digest in $cs_url)"
            return 0
        fi
        if ! verify_sha256 "$archive" "$want"; then
            yellow "$name checksum mismatch via mirror; re-downloading direct from GitHub"
            if ! gh_dl "$url" "$archive" 1 || ! verify_sha256 "$archive" "$want"; then
                red "skip $name (checksum verification FAILED for $url — possible corruption or MITM)"
                return 0
            fi
        fi
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
    # Mirror the gating used for the HOMEBREW_*_GIT_REMOTE env exports in
    # common.sh: skip when the CN mirror is disabled. Set
    # DOTFILES_CONFIGURE_BREW_MIRRORS=1 to force-enable regardless.
    local configure="${DOTFILES_CONFIGURE_BREW_MIRRORS:-${USE_CN_MIRROR:-1}}"
    [ "$configure" = "1" ] || return 0

    if ! command_exists brew || ! command_exists git; then
        return 0
    fi

    ensure_brew_tap_remote brew https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    ensure_brew_tap_remote homebrew/core https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    ensure_brew_tap_remote homebrew/cask https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
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
        if ruby_is_macos_system_ruby; then
            yellow "skip gem mirror config (macOS system Ruby is too old/noisy)"
        else
            if ! gem sources --list | grep -Fq 'http://mirrors.tencent.com/rubygems/'; then
                gem sources --add http://mirrors.tencent.com/rubygems/
            fi
            if gem sources --list | grep -Fq 'https://rubygems.org/'; then
                gem sources --remove https://rubygems.org/
            fi
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

# Detect a PEP 668 "externally-managed" interpreter (Homebrew/system python).
# mise-managed pythons are generally not marked, so this is usually false there.
python_externally_managed() {
    local marker
    marker=$(python3 -c 'import sysconfig,sys,os;print(os.path.join(sysconfig.get_path("stdlib",vars={"base":sys.prefix}),"EXTERNALLY-MANAGED"))' 2>/dev/null) || return 1
    [ -n "$marker" ] && [ -f "$marker" ]
}

# Install python packages into the user site when the active interpreter allows
# it. Do not bypass PEP 668 automatically: Homebrew/system pythons are
# externally-managed, and setup.sh should not opt users into
# --break-system-packages. Designed to run in a background subshell via
# track_background.
_dotfiles_pip_install_user() {
    if python_externally_managed; then
        yellow "skip python user packages on externally-managed python: $*"
        yellow "install pipx or activate a mise-managed python before rerunning setup"
        return 0
    fi

    python3 -m pip install --user "$@"
}

ruby_is_macos_system_ruby() {
    [ "$os" = "darwin" ] || return 1
    [ "$(command -v ruby 2>/dev/null || true)" = "/usr/bin/ruby" ]
}

gem_package_installed() {
    local pkg=$1
    gem list -i "^${pkg}$" >/dev/null 2>&1
}

install_user_language_packages() {
    local npm_packages=()
    local pkg

    if command_exists python3; then
        if python3 -m pip --version >/dev/null 2>&1; then
            # CLI entry-point tools go through pipx when available, which
            # isolates each in its own venv, survives python upgrades, and is
            # immune to PEP 668. We intentionally do not auto-install pynvim:
            # this nvim config has no Python provider dependency, and installing
            # provider libraries into an arbitrary active python is too implicit.
            local pipx_cli_tools=("bpython:bpython" "python-lsp-server:pylsp")
            local tool cmd
            if command_exists pipx; then
                for pkg in "${pipx_cli_tools[@]}"; do
                    tool=${pkg%%:*}
                    cmd=${pkg#*:}
                    if ! command_exists "$cmd" \
                        && ! pipx list 2>/dev/null | grep -qE "^   package ${tool} "; then
                        pipx install "$tool" || yellow "pipx install $tool failed"
                    fi
                done
                unset tool cmd
            else
                local _pip_missing=()
                for pkg in "${pipx_cli_tools[@]}"; do
                    tool=${pkg%%:*}
                    cmd=${pkg#*:}
                    command_exists "$cmd" || python_package_installed "$tool" || _pip_missing+=("$tool")
                done
                unset tool cmd
                [ "${#_pip_missing[@]}" -gt 0 ] \
                    && track_background _dotfiles_pip_install_user "${_pip_missing[@]}"
            fi

        else
            yellow "skip python user packages (python3 -m pip unavailable)"
        fi
    fi

    if command_exists npm; then
        if npm_prefix_is_user_writable; then
            command_exists bash-language-server || npm_packages+=("bash-language-server")
            command_exists docker-langserver || npm_packages+=("dockerfile-language-server-nodejs")

            if [ "${#npm_packages[@]}" -gt 0 ]; then
                track_background npm install -g "${npm_packages[@]}"
            fi
        else
            yellow "skip npm global packages (npm prefix is not user-writable)"
        fi
    fi

    if command_exists gem; then
        if ruby_is_macos_system_ruby; then
            yellow "skip ruby neovim provider gem (macOS system Ruby is too old)"
        elif ! gem_package_installed neovim; then
            track_background gem install --user-install neovim
        fi
    fi
}

install_zsh_plugins() {
    if ! command_exists zsh; then
        return 0
    fi

    # Clone the plugins we source directly into an XDG data dir — no
    # oh-my-zsh framework (and no curl|sh OMZ installer) required.
    local plugins_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
    ensure_git_clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    ensure_git_clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
}

# Install herdr's stock claude hook script into ~/.claude. Other
# Claude-Code-compatible config dirs (e.g. ~/.codebuddy) go through
# link_custom_herdr_hook below so we can label them distinctly in
# herdr's sidebar.
# Symlinking is unsafe — herdr's installer overwrites the hook file in
# place, so a shared symlink would let one uninstall remove all of them.
install_herdr_integrations() {
    if ! command_exists herdr; then
        return 0
    fi

    red 'Init herdr integrations...'

    local dir dirs=("$HOME/.claude")
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            CLAUDE_CONFIG_DIR="$dir" herdr integration install claude \
                || yellow "herdr integration install claude failed for $dir"
        fi
    done

    yellow 'Init herdr integrations finish.'
}

# check_source_present <repo-path> — check-mode-only diagnostic for the repo
# sources this script links into $HOME. A missing source is reported separately
# from a missing/mismatched link (ensure_link reports the latter) so the two
# causes are not conflated. No-op outside check mode.
check_source_present() {
    [ "$MODE" = "check" ] || return 0
    [ -f "$1" ] && return 0
    yellow "check: missing source $1 (its link cannot resolve)"
    mark_check_failure
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
    # ensure_dir/ensure_link are read-only in check mode, so link state is
    # verified there too; a missing repo source is reported on top of it.
    check_source_present "$src_dir/settings.json"
    check_source_present "$src_dir/hooks/herdr-agent-state.sh"
    check_source_present "$src_dir/config.toml"

    ensure_dir "$HOME/.reasonix/hooks"
    ensure_link "$src_dir/settings.json"            "$HOME/.reasonix/settings.json"
    ensure_link "$src_dir/hooks/herdr-agent-state.sh" "$HOME/.reasonix/hooks/herdr-agent-state.sh"

    # Deploy model/provider config to ~/.reasonix/ so it stays alongside hooks/settings.
    local config_dst="$HOME/.reasonix/config.toml"
    ensure_dir "$(dirname "$config_dst")"
    ensure_link "$src_dir/config.toml" "$config_dst"
}

# ~/.pi/agent mixes runtime data (sessions/, models-store.json, auth.json)
# with user-managed config (models.json, extensions/), so we symlink only the
# files we own and merge the extension list into pi's settings.json (which pi
# itself owns).
link_pi_config() {
    local src_dir="$script_path/.pi"
    [ -d "$src_dir" ] || return 0

    # ensure_dir/ensure_link are read-only in check mode, so link state is
    # verified there too; a missing repo source is reported on top of it.
    check_source_present "$src_dir/agent/models.json"
    check_source_present "$src_dir/agent/extensions/openrouter-slim.mjs"

    ensure_dir "$HOME/.pi/agent"
    ensure_link "$src_dir/agent/models.json" "$HOME/.pi/agent/models.json"

    # Model-slimming extension: replaces pi's large built-in openrouter catalog
    # with only the models reasonix configures.
    ensure_dir "$HOME/.pi/agent/extensions"
    ensure_link "$src_dir/agent/extensions/openrouter-slim.mjs" "$HOME/.pi/agent/extensions/openrouter-slim.mjs"

    # Register the extension in pi's settings.json without clobbering fields
    # pi owns (defaultModel, theme, packages, ...).
    local settings="$HOME/.pi/agent/settings.json"
    [ -f "$settings" ] || return 0
    if ! command_exists jq; then
        yellow "skip pi settings.json extensions merge: jq not installed"
        return 0
    fi

    ext_entry="./extensions/openrouter-slim.mjs"
    if jq -e --arg e "$ext_entry" '.extensions // [] | index($e)' "$settings" >/dev/null 2>&1; then
        return 0
    fi
    if [ "$DRY_RUN" = "1" ]; then
        yellow "[dry-run] would merge extensions entry into $settings"
        return 0
    fi

    merge_into_settings 'pi extensions' "$settings" \
        '.extensions = ((.extensions // []) + [$e])' \
        --arg e "$ext_entry" "$settings"
}

# Symlink a hand-written herdr hook script into a Claude-Code-compatible
# agent's config dir, then merge the dotfiles `hooks` block into the
# agent's settings.json (which also holds gateway/model/etc. owned by the
# agent itself). Used for codebuddy so each pane carries the right agent label
# in herdr's sidebar (rather than all being tagged "claude" by herdr's stock
# installer).
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

    # ensure_dir/ensure_link are read-only in check mode, so link state is
    # verified there too; a missing repo source is reported on top of it.
    check_source_present "$src_dir/hooks/herdr-agent-state.sh"
    ensure_dir "$target_dir/hooks"
    ensure_link "$src_dir/hooks/herdr-agent-state.sh" "$target_dir/hooks/herdr-agent-state.sh"

    local settings="$target_dir/settings.json"
    local hooks_src="$src_dir/hooks-settings.json"
    [ -f "$hooks_src" ] || return 0

    # check mode must stay read-only: creating $settings here would break that
    # contract. The merge state is verified read-only by check_custom_herdr_hook.
    [ "$MODE" = "check" ] && return 0

    if ! command_exists jq; then
        yellow "skip $subdir settings.json hooks merge: jq not installed"
        return 0
    fi

    if [ ! -f "$settings" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            yellow "[dry-run] would create $settings and merge hooks"
            return 0
        fi
        printf '{}\n' > "$settings"
    fi

    if [ "$DRY_RUN" = "1" ]; then
        yellow "[dry-run] would merge hooks from $hooks_src into $settings"
        return 0
    fi

    merge_into_settings "$subdir hooks" "$settings" \
        -s '.[0] * {hooks: .[1].hooks}' "$settings" "$hooks_src"
}

# ---------------------------------------------------------------------------
# jq merge helpers for agent-owned settings.json files. `mv` of a mktemp file
# would impose 0600 on the target, so write with `cat >` and record/restore
# the original mode.
# ---------------------------------------------------------------------------
settings_file_mode() {
    local file=$1 mode=""
    mode=$(stat -c '%a' "$file" 2>/dev/null) || true
    [ -n "$mode" ] || mode=$(stat -f '%Lp' "$file" 2>/dev/null) || true
    printf '%s\n' "${mode:-644}"
}

merge_into_settings() {
    # args: <label> <settings-file> <jq-program> [jq args & input files...]
    # The caller supplies the full jq input list (program + flags + files);
    # merge result is written back into <settings-file> in place.
    # check mode is read-only by contract; its jq state is verified by the
    # dedicated check_* helpers instead.
    local label=$1 settings=$2 prog=$3
    shift 3
    [ "$MODE" = "check" ] && return 0

    local tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/dotfiles-settings-merge.XXXXXX.json")"
    if jq "$prog" "$@" > "$tmp" 2>/dev/null; then
        if [ "$MODE" = "repair" ]; then
            local mode
            mode=$(settings_file_mode "$settings")
            cp -p "$settings" "${settings}.bak.${BACKUP_SUFFIX}" 2>/dev/null \
                || cp "$settings" "${settings}.bak.${BACKUP_SUFFIX}"
            chmod "$mode" "${settings}.bak.${BACKUP_SUFFIX}" 2>/dev/null || true
            yellow "backup $settings -> ${settings}.bak.${BACKUP_SUFFIX}"
        fi
        cat "$tmp" > "$settings"
        rm -f "$tmp"
        echo "$label merged into $settings"
    else
        rm -f "$tmp"
        yellow "$label merge failed; $settings left untouched"
    fi
}

# check_pi_settings_merge — read-only counterpart of link_pi_config's merge.
check_pi_settings_merge() {
    local settings="$HOME/.pi/agent/settings.json"
    [ -f "$settings" ] || return 0
    if ! command_exists jq; then
        yellow "check: cannot verify pi settings.json merge (jq not installed)"
        return 0
    fi
    if ! jq -e --arg e './extensions/openrouter-slim.mjs' \
        '.extensions // [] | index($e)' "$settings" >/dev/null 2>&1; then
        yellow "check: pi settings.json missing extensions entry"
        mark_check_failure
    fi
}

# check_custom_herdr_hook — read-only jq verification for link_custom_herdr_hook
# (its symlink half is checked by ensure_link itself in check mode).
check_custom_herdr_hook() {
    local subdir="$1" target_dir="$2"
    local src_dir="$script_path/$subdir"
    [ -d "$src_dir" ] || return 0
    [ -d "$target_dir" ] || return 0

    local settings="$target_dir/settings.json"
    local hooks_src="$src_dir/hooks-settings.json"
    [ -f "$hooks_src" ] || return 0

    if [ ! -f "$settings" ]; then
        yellow "check: $settings missing (would be created on init)"
        mark_check_failure
        return 0
    fi
    if ! command_exists jq; then
        yellow "check: cannot verify $subdir settings.json merge (jq not installed)"
        return 0
    fi
    if ! jq -e -s '(.[0].hooks // {}) as $cur | (.[1].hooks // {}) as $new
            | all($new | keys[]; . as $k | $cur[$k] == $new[$k])' \
            "$settings" "$hooks_src" >/dev/null 2>&1; then
        yellow "check: $subdir settings.json hooks not merged"
        mark_check_failure
    fi
}

run_setup() {
    # `prune` only removes stale artifacts; it never creates links or installs.
    if [ "$MODE" = "prune" ]; then
        if section_requested "links"; then
            red 'Prune stale links...'
            prune_managed_links
            yellow 'Prune finish.'
        fi
        return 0
    fi

    if [ "$MODE" != "check" ] && [ "$DRY_RUN" != "1" ]; then
        init_submodules
    fi

    # ── links ──────────────────────────────────────────────────────────────
    if section_requested "links"; then
        link_top_level_dotfiles
        link_config_entries
        link_tmux_and_bin
    fi

    # ── nvim ───────────────────────────────────────────────────────────────
    if section_requested "nvim"; then
        setup_neovim
    fi

    # ── agent link sections ────────────────────────────────────────────────
    # Read-only in check mode (ensure_link/ensure_dir no-op), preview-only in
    # dry-run; herdr's own integration installer stays init/repair-only.
    if section_requested "herdr"; then
        if [ "$MODE" != "check" ] && [ "$DRY_RUN" != "1" ]; then
            install_herdr_integrations
        fi
        link_reasonix_herdr_integration
        link_pi_config
        link_custom_herdr_hook ".codebuddy" "$HOME/.codebuddy"
    fi

    # Report links left behind by config entries removed from this repo. These
    # are invisible to ensure_link (which only knows about live sources).
    if section_requested "links"; then
        if [ "$MODE" = "check" ]; then
            report_dangling_links
            check_pi_settings_merge
            check_custom_herdr_hook ".codebuddy" "$HOME/.codebuddy"
        elif [ "$MODE" = "repair" ]; then
            remove_dangling_links
        fi
    fi

    if [ "$MODE" = "check" ] || [ "$DRY_RUN" = "1" ]; then
        # In dry-run mode, list what the remaining install sections would do
        # without executing any of them. Link sections above already printed
        # their actions via ensure_link.
        if [ "$DRY_RUN" = "1" ]; then
            _dry_run_remaining
        fi
        return 0
    fi

    # ── brew / entware / releases ──────────────────────────────────────────
    if [ "$os" = "darwin" ]; then
        if section_requested "brew"; then
            install_brew_if_needed
            sync_brew_shellenv
            install_missing_brew_packages
        fi
    else
        if section_requested "entware"; then
            install_entware_packages
        fi
        if section_requested "releases"; then
            install_linux_release_tools
        fi
    fi

    # ── runtimes ───────────────────────────────────────────────────────────
    if section_requested "runtimes"; then
        # Install configured runtimes before npm/pipx/gem packages that depend
        # on them. `mise install` is idempotent and exits quickly when versions
        # are already present.
        load_nvm_default_node
        if command_exists mise; then
            red 'Install mise runtimes...'
            mise install --yes
            load_nvm_default_node
        fi
    fi

    # ── mirrors ────────────────────────────────────────────────────────────
    if section_requested "mirrors"; then
        if [ "$os" = "darwin" ]; then
            configure_brew_mirrors
        fi
        configure_package_mirrors
    fi

    # ── packages ───────────────────────────────────────────────────────────
    if section_requested "packages"; then
        install_user_language_packages
    fi

    # ── zsh ────────────────────────────────────────────────────────────────
    if section_requested "zsh"; then
        install_zsh_plugins
    fi
}

# Print a summary of what the install-time sections would do without running
# any of them. Called only in --dry-run mode after link sections have run.
_dry_run_remaining() {
    printf '\033[36m[dry-run]\033[0m Section summary (no changes made):\n'

    if [ "$os" = "darwin" ]; then
        if section_requested "brew"; then
            echo "  brew      — install Homebrew (if missing) + missing formulae/casks"
        fi
    else
        section_requested "entware"  && echo "  entware   — opkg install missing packages"
        section_requested "releases" && echo "  releases  — download GitHub release binaries → ~/bin"
    fi

    section_requested "runtimes" && echo "  runtimes  — mise install --yes + nvm default node"
    section_requested "mirrors"  && echo "  mirrors   — configure Homebrew + npm/pip/gem mirrors"
    section_requested "packages" && echo "  packages  — install npm/pipx/gem language packages"
    section_requested "zsh"      && echo "  zsh       — clone zsh plugin repos (autosuggestions, syntax-highlighting)"
    section_requested "herdr"    && echo "  herdr     — link agent configs/hooks (herdr integration install itself is skipped in dry-run)"
}

parse_args "$@"
run_setup

if [ "$DRY_RUN" = "1" ]; then
    yellow 'Dry run complete — no changes were made.'
    exit 0
fi

if ! wait_for_background_jobs; then
    red 'One or more background setup jobs failed.'
    exit 1
fi

if [ "$MODE" = "check" ] && [ "$CHECK_FAILED" -ne 0 ]; then
    red 'Setup check detected mismatches.'
    exit 1
fi

end=$(date "+%s")
echo -e "\033[33mSetup (${MODE}) finish in $((end - begin)) seconds.\033[0m"
