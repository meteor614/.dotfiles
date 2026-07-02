# AGENTS.md

## Scope
- This repository is a personal dotfiles repo. Prefer minimal, reversible edits that preserve how files in this repo map into `$HOME`.
- Assume changes will be deployed by symlink, not copied. Renames and path moves are operational changes, not cosmetic ones.

## Repository Layout
- Top-level dotfiles such as `.zshrc`, `.gitconfig`, and `.bashrc` are linked into `~/` by `setup.sh`.
- `.config/*` is generally linked into `~/.config/*` automatically.
- `.config/nvim` is a special case. `setup.sh` bootstraps a LazyVim starter tree in `~/.config/nvim` and only links `.config/nvim/lua/config` and `.config/nvim/lua/plugins` from this repo.
- `.zshrc` and `.bashrc` are shared shell entrypoints for both local and remote hosts. Optional tool init such as `starship`, `atuin`, and lazy `mise`/`nvm` loading should remain conditional so shells still start cleanly when a tool is absent.
- Shell startup flow:
  - `.zshenv` is intentionally tiny and is sourced by every zsh invocation; keep only pure environment/PATH exports there.
  - `.zshrc` owns zsh framework-level setup: fpath, compinit, zsh plugins, zsh init caching, and final `$HOME/bin` priority.
  - `.config/shell/common.sh` holds bash+zsh shared environment, aliases, runtime manager activation, tool init caches, and cross-shell helpers. Keep it POSIX-ish.
  - `.zshrc.local` is for zsh-only interactive UX: keymaps, local aliases/functions, SSH multiplexer autostart, and machine/user conveniences.
  - `.bashrc` is for bash-only prompt, PATH helpers, completions, and bash-specific hooks such as bash-preexec/Atuin.
- Node is managed via `mise` in this environment (fallback: `nvm`). Prefer `mise` for runtime versions and do not reintroduce Homebrew `node` as a required dependency.
- `.config/mise/config.toml` declares default runtime versions (node/python/go). `setup.sh` runs `mise install --yes` to ensure they're present. `not_found_auto_install = false` means missing shims do **not** trigger silent installs — runtimes are only installed via explicit `mise install`.
- `bin/*` is linked into `~/bin/*`.
- `tmuxinator/` is linked into `~/.tmuxinator`.
- `.config/pip` is linked into `~/.config/pip` via the same generic `.config/*` link logic (no special-case handling in `setup.sh`).
- `.tmux` and `cheat/cheatsheets` are git submodules. Treat them as upstream-managed content unless the user explicitly asks for a submodule change.
- This repo is a `jj` workspace. Use `jj` for all commits, branch moves, and pushes — e.g. `jj commit -m …`, `jj bookmark set master -r @-`, `jj git push`. Do **not** run `git commit` / `git push` directly: `jj` will reset the working copy parent on its next invocation, and stray git operations land you in detached-HEAD with commits that aren't on any jj-tracked branch. Reading via `git log` / `git diff` is fine — `jj` commits stay git-compatible.
- After every `jj git fetch`, always follow up by rebasing the working copy onto the updated bookmark (e.g. `jj rebase -d master`) so local work sits on top of the latest remote state. If the rebase reports conflicts, resolve them by editing the conflicted files to remove conflict markers, then run `jj squash` to move the resolution into the conflicted commit. Never leave the working copy stale after a fetch.

## Editing Guidelines
- Keep filenames and directory structure stable unless the user explicitly asks for a relocation.
- Prefer small targeted edits. Do not reformat unrelated personal config just to normalize style.
- Preserve commented-out blocks unless the user asks to remove them. Many of them document optional tools, alternate setup paths, or historical decisions.
- Match the existing interpreter and style of each script. This repo uses a mix of `bash`, `sh`, Lua, TOML, YAML, JSON, and tool-specific config formats.
- Prefer capability checks and existing fallback patterns over assuming a single machine layout. This repo is used across heterogeneous local and remote environments.
- Prefer local overlay files over vendored content when both exist. Example: change `.tmux.conf.local` instead of editing the `.tmux` submodule directly.
- Multiplexer stance: zellij + herdr 是日常主力，tmux 保留作为远程 SSH 兼容场景。编辑 tmux 配置时优先通过 `.tmux.conf.local` 覆盖，避免直接修改 submodule。
- Do not add secrets, tokens, private keys, or machine-specific absolute paths unless the user explicitly requests that.
- The package and git mirror choices in `setup.sh` are intentional. Do not switch them to other mirrors or default upstreams unless asked.
- For Node-related setup, prefer `mise` activation (fallback `nvm`) or `npm`/`corepack` usage over adding Homebrew `node`.

## High-Risk Operations
- Do not run `setup.sh` without explicit user approval. It writes into `$HOME`, creates symlinks, updates submodules, clones repositories, touches package manager configuration, and uses the network.
- Do not run `bin/update_all.sh` without explicit user approval. It updates system packages, language package managers, plugins, submodules, and may run privileged commands.
- `setup.sh` can move existing Neovim directories out of the way, bootstrap LazyVim, rewrite Homebrew remotes, install packages, and update external repositories.
- `setup.sh all` also appends this repo's `.ssh/id_rsa.pub` into `~/.ssh/authorized_keys`. Treat that path as sensitive.
- Do not perform remote `ssh` provisioning or host changes without explicit user approval. Installing packages, changing login shells, touching remote dotfiles, or modifying local/remote `~/.ssh` state are all high-impact operations.
- Avoid GUI tools, interactive installers, and login-shell side effects unless the user explicitly wants them.

## Validation
- After editing shell scripts, prefer syntax-only checks such as `bash -n setup.sh`, `bash -n bin/update_all.sh`, or `sh -n <script>`.
- After editing shell dotfiles, use non-executing syntax checks when available, for example `zsh -n .zshrc`.
- For app configs such as Neovim, tmux, Ghostty, Karabiner, and zellij, only run low-risk non-interactive validation that is already available locally.
- If a change affects symlink behavior or install flow, read the relevant `setup.sh` branch and verify the target path logic directly.
- If validation would require network access, package installation, or writing outside the repo, stop and ask before proceeding.

## Delivery Notes
- In summaries, call out any expected side effects on `$HOME`, remote hosts, shell startup behavior, submodules, package managers, or external services.
- If a request would require editing submodule content, clarify whether the user wants an upstream submodule change or a local override in this repo.
