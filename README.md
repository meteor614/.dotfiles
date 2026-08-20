# dotfiles

我的全部 dotfiles，由 `setup.sh` 通过符号链接部署到 `$HOME`。

* neovim/lazyvim
* ghostty
* zellij/herdr/tmux/tmuxinator
* zsh/bash
* claude/codex/codebuddy/reasonix
* starship/yazi/atuin/direnv
* git/lazygit
* gdb/lldb
* karabiner
* cheats
* brew/go/npm/gem/pip/conda 源镜像
* 脚本

## 新机器初始化

1. 安装前置依赖：`git`、`zsh`（macOS：`brew install git zsh`）。
2. 将本仓库克隆到 `~/.dotfiles`。
3. 运行安装器：

   ```sh
   ~/.dotfiles/setup.sh init
   ```

   在 macOS 上会安装 Homebrew（若缺失）、安装缺失的 formulae/casks、配置国内镜像、安装语言包与 zsh 插件。
   在 Linux/Synology 上会安装 Entware 软件包，并把 GitHub release 工具装到 `~/bin`。
4. 如果使用 zsh，设置登录 shell：

   ```sh
   chsh -s "$(command -v zsh)"
   ```

5. Neovim 单独管理（见 [目录结构](#目录结构)），首次初始化：

   ```sh
   ~/.dotfiles/setup.sh init --bootstrap-nvim
   ```

6. 校验链接是否正确：

   ```sh
   ~/.dotfiles/setup.sh check
   ```

## setup.sh

`setup.sh` 支持三种模式：

| 模式      | 行为                                                    |
| --------- | ------------------------------------------------------- |
| `init`    | （默认）创建缺失的符号链接，然后安装依赖                 |
| `check`   | 只读：报告缺失/不匹配的链接，不写入任何内容              |
| `repair`  | 备份并修复不匹配的链接                                   |

参数：

* `--bootstrap-nvim` — 在 `~/.config/nvim` 采用 LazyVim starter 树
  （会先备份已有的 nvim 目录）。

按 OS 区分的安装行为：macOS → Homebrew；Linux/Synology → Entware（`opkg`）+
GitHub release 压缩包（装到 `~/bin`）。镜像配置遵循 `USE_CN_MIRROR` /
`DOTFILES_CONFIGURE_*` 覆盖项。

## 目录结构

* 顶层 dotfiles（`.zshrc`、`.gitconfig` 等）→ 符号链接到 `~/`。
* `.config/*` → `~/.config/*`（文件符号链接；目录先创建再链接内容）。
* `.config/nvim` — 特例：LazyVim starter 树位于 `~/.config/nvim`，
  只有 `lua/config` 和 `lua/plugins` 来自本仓库。
* `bin/*` → `~/bin/*`。
* `tmuxinator/` → `~/.tmuxinator`。
* `.tmux`、`cheat/cheatsheets` — git 子模块（视为上游管理）。

完整的 shell 启动流程与编辑规范见 `AGENTS.md`。

## Shell 启动流程

* `.zshenv` — 仅纯环境变量导出。
* `.zshrc` — zsh 框架部分：fpath/compinit、插件、缓存 init、PATH。
* `.bashrc` — 仅 bash 相关部分。
* `.config/shell/common.sh` — bash+zsh 共享环境、别名、运行时管理器激活、
  工具 init 缓存、跨 shell 辅助函数。
* `.zshrc.local` / `.bashrc.local` — 机器本地覆盖（不在本仓库中）。

## bin/ 脚本

| 脚本                     | 用途                                                       |
| ------------------------ | ---------------------------------------------------------- |
| `color.sh`               | 用循环 ANSI 颜色给 stdin 行上色                             |
| `find_duplicated.sh`     | 查找重复文件（大小 → md5），并行处理                        |
| `fzsession`              | 在 zellij/tmux/herdr 会话间 fzf 切换（绑定到 `Alt+z`）      |
| `kssh.sh`                | kubectl：通过 xpanes 批量 exec 进入匹配的 pods/node         |
| `process_monitor.sh`     | 按名称/PID 监控进程，进程结束时执行命令                     |
| `update_all.sh`          | topgrade 驱动的包/运行时/插件更新                           |

## 更新

* `~/bin/update_all.sh` — topgrade 驱动，更新 brew/gem/npm/pip/cargo/…
  以及 mise 运行时、rustup、zsh 插件。加 `all` 参数会同时更新本仓库及子模块。
* 子模块（`.tmux`、cheat cheatsheets）视为上游管理。tmux 的覆盖请通过
  `.tmux.conf.local`，不要直接修改 `.tmux`。
* Neovim 插件采用滚动更新模型，`lazy-lock.json` 不做版本跟踪。
  每台机器按需执行 `:Lazy update` / `:Lazy restore`。

## 快捷键

统一快捷键方案（`Cmd` / `Alt` / `Ctrl+Alt`，覆盖 Ghostty、herdr、tmux、zellij）
见 [KEYBINDINGS.md](KEYBINDINGS.md)。
