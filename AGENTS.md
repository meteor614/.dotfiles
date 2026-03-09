# AGENTS.md

## Scope
- This repository is a personal dotfiles repo. Prefer minimal, reversible edits that preserve how files in this repo map into `$HOME`.
- Assume changes will be deployed by symlink, not copied. Renames and path moves are operational changes, not cosmetic ones.

## Repository Layout
- Top-level dotfiles such as `.zshrc`, `.vimrc`, `.wezterm.lua`, `.gitconfig`, and `.bashrc` are linked into `~/` by `setup.sh`.
- `.config/*` is generally linked into `~/.config/*` automatically.
- `.config/nvim` is a special case. `setup.sh` bootstraps a LazyVim starter tree in `~/.config/nvim` and only links `.config/nvim/lua/config` and `.config/nvim/lua/plugins` from this repo.
- Node is managed via `nvm` in this environment. Prefer the `nvm` default Node and do not reintroduce Homebrew `node` as a required dependency.
- `bin/*` is linked into `~/bin/*`.
- `tmuxinator/` is linked into `~/.tmuxinator`.
- `.aria2` and `.pip` are linked explicitly by `setup.sh`.
- `.tmux` and `cheat/cheatsheets` are git submodules. Treat them as upstream-managed content unless the user explicitly asks for a submodule change.

## Editing Guidelines
- Keep filenames and directory structure stable unless the user explicitly asks for a relocation.
- Prefer small targeted edits. Do not reformat unrelated personal config just to normalize style.
- Preserve commented-out blocks unless the user asks to remove them. Many of them document optional tools, alternate setup paths, or historical decisions.
- Match the existing interpreter and style of each script. This repo uses a mix of `bash`, `sh`, Lua, TOML, YAML, JSON, and tool-specific config formats.
- Prefer local overlay files over vendored content when both exist. Example: change `.tmux.conf.local` instead of editing the `.tmux` submodule directly.
- Do not add secrets, tokens, private keys, or machine-specific absolute paths unless the user explicitly requests that.
- The package and git mirror choices in `setup.sh` are intentional. Do not switch them to other mirrors or default upstreams unless asked.
- For Node-related setup, prefer `nvm` activation or `npm`/`corepack` usage over adding Homebrew `node`.

## High-Risk Operations
- Do not run `setup.sh` without explicit user approval. It writes into `$HOME`, creates symlinks, updates submodules, clones repositories, touches package manager configuration, and uses the network.
- Do not run `bin/update_all.sh` without explicit user approval. It updates system packages, language package managers, plugins, submodules, and may run privileged commands.
- `setup.sh` can move existing Neovim directories out of the way, bootstrap LazyVim, rewrite Homebrew remotes, install packages, and update external repositories.
- `setup.sh all` also appends this repo's `.ssh/id_rsa.pub` into `~/.ssh/authorized_keys`. Treat that path as sensitive.
- Avoid GUI tools, interactive installers, and login-shell side effects unless the user explicitly wants them.

## Validation
- After editing shell scripts, prefer syntax-only checks such as `bash -n setup.sh`, `bash -n bin/update_all.sh`, or `sh -n <script>`.
- After editing shell dotfiles, use non-executing syntax checks when available, for example `zsh -n .zshrc`.
- For app configs such as Neovim, tmux, WezTerm, Karabiner, and zellij, only run low-risk non-interactive validation that is already available locally.
- If a change affects symlink behavior or install flow, read the relevant `setup.sh` branch and verify the target path logic directly.
- If validation would require network access, package installation, or writing outside the repo, stop and ask before proceeding.

## Delivery Notes
- In summaries, call out any expected side effects on `$HOME`, submodules, package managers, or external services.
- If a request would require editing submodule content, clarify whether the user wants an upstream submodule change or a local override in this repo.
