# dotfiles

All my dotfiles.

* neovim/lazyvim
* ghostty
* zellij/herdr/tmux/tmuxinator
* zsh/bash
* claude/codex/codebuddy/reasonix
* starship/yazi
* git/lazygit
* gdb/lldb
* karabiner
* cheats
* brew/go/npm/gem/pip/conda source mirrors
* scripts
* …

## Notes

Neovim is based on a LazyVim starter tree managed in `~/.config/nvim`; this
repo only overlays `lua/config` and `lua/plugins`. Plugin versions intentionally
follow a rolling-update model, so `lazy-lock.json` is not tracked here. Use
`:Lazy update` / `:Lazy restore` on each machine as needed.
