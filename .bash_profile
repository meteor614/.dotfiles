# ~/.bash_profile — login-shell entrypoint for bash.
# macOS Terminal starts login shells, which read .bash_profile (not .bashrc).
# Keep this thin; shared config lives in ~/.bashrc -> ~/.config/shell/common.sh.
# Machine-local additions belong in ~/.bashrc.local.

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
