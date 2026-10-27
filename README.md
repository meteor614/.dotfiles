# dotfiles

我的全部 dotfiles，由 `setup.sh` 通过符号链接部署到 `$HOME`。

* neovim/lazyvim
* ghostty/noctty/alacritty
* tuios/herdr/zellij/tmux/tmuxinator
* zsh/bash
* claude/codex/codebuddy/reasonix/kimi
* starship/yazi/atuin/direnv
* git/lazygit
* gdb/lldb
* karabiner
* CLI 工具速览（[CLI_TOOLS.md](CLI_TOOLS.md)）
* brew/go/npm/gem/pip/conda 源镜像
* 脚本

## 新机器初始化

1. 安装前置依赖：`git`、`curl`（macOS：`brew install git zsh`；
   Debian/Ubuntu：`sudo apt-get install -y git curl`）。Linux 上的 `zsh` 由
   `setup.sh` 的 `apt` 段安装。
2. 将本仓库克隆到 `~/.dotfiles`。
3. 运行安装器：

   ```sh
   ~/.dotfiles/setup.sh init
   ```

   在 macOS 上会安装 Homebrew（若缺失）、安装缺失的 formulae/casks、配置国内镜像、安装语言包与 zsh 插件。
   在 WSL 上会先跑 Debian/Ubuntu 的 `apt` 段，再按 macOS 的逻辑安装
   Homebrew on Linux（Linuxbrew），用它补齐 apt 没有的工具（`gotags`、
   `rust`）；字体不走路 cask（Homebrew 的 cask JSON 会把目标写死到
   macOS 的 `~/Library/Fonts`），而是由 `fonts` 段把 Hack Nerd Font 与
   Sarasa Mono SC 直接装到 `~/.local/share/fonts`。不想装 Linuxbrew 可设
   `DOTFILES_INSTALL_LINUXBREW=0`。
   在 Debian/Ubuntu 上会通过 `apt` 安装常用软件包（并补齐 `bat`/`fd` 的
   命令别名），再把 Neovim（官方 release，装到 `~/.local/opt`）以及 `jj`、
   `mise`、`herdr`、`tuios`、`starship`、`atuin`、`lazygit`、`zellij`、`yazi`、
   `ouch`、`procs`、`broot`、`glow`、`btm`、`ast-grep`、`yq`、`bookokrat`
   等 release 工具装好，最后用 `mise` 安装 node/python/go 运行时。部分工具
   依赖 GitHub API 解析最新版本；若报 rate limit，设置 `GITHUB_TOKEN` 后重跑。
   在 Synology DSM 上会安装 Entware 软件包，并把 GitHub release 工具装到 `~/bin`。
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

`setup.sh` 支持四种模式：

| 模式      | 行为                                                    |
| --------- | ------------------------------------------------------- |
| `init`    | （默认）创建缺失的符号链接，然后安装依赖                 |
| `check`   | 只读：报告缺失/不匹配的链接（含指向本仓库但源已删除的死链） |
| `repair`  | 备份并修复不匹配的链接、合并受管理配置、补 `~/.gitconfig` 的 `[include]`；不安装软件或删除死链 |
| `prune`   | 删除死链（指向本仓库、源已不存在）及过期 `*.zwc`          |

参数：

* `--bootstrap-nvim` — 在 `~/.config/nvim` 采用 LazyVim starter 树
  （会先备份已有的 nvim 目录），只在 `init` 模式执行。
* `--dry-run` — 只打印将要执行的操作，不做任何写入。
* `--only SECTION` — 只运行指定段（逗号分隔）。**不会**自动拉取依赖：
  如 `--only packages` 需先确保 `runtimes`，`herdr` 需先跑 `links`。
  Linux 上装软件包通常用 `--only apt,releases,runtimes,packages`（`apt` 段
  含 Neovim）；WSL 再加上 `brew,fonts`（Linuxbrew + 字体）。
* `DOTFILES_RELEASES_REFRESH=1` — 把 `releases` 段从「只装缺失」改成
  「刷新过期」：逐个比对 `~/bin`（及 `~/.local/bin`）里已装二进制与最新
  release tag，只重下落后于上游的；apt/brew/Entware 装的副本不碰。
  `update_all.sh` 就是用这个模式跑的。

按 OS 区分的安装行为：

* macOS → Homebrew（formulae/casks）。
* WSL → `apt` + Homebrew on Linux（Linuxbrew）+ `fonts` 段。Linuxbrew 段
  对齐 macOS，复用同一套 Homebrew 镜像配置；公式列表是面向 Linux 的精简集
  （apt/releases 已覆盖的不重复安装）。字体由 `fonts` 段直接从上游取
  （Hack Nerd Font + Sarasa Mono SC）。终端侧 `TERM=xterm-ghostty` 需要
  noctty 侧转发 + 发行版内装好 terminfo 条目，见下文 noctty 条目。
  另外 WSL 建议在 `/etc/wsl.conf` 里设 `[interop] appendWindowsPath = false`：
  注入的 Windows PATH 会带来几十个 `/mnt/*` 目录，每次命令查找未命中都要付
  一次 9p 往返（实测单次 45–70ms），是 shell 启动变慢的主因（实测约
  0.8s → 0.1s）。关掉后 `.config/shell/common.sh` 只显式 append 真正需要的
  几个 Windows 目录（`system32`、`PowerShell/v1.0`、`Windows`），`.exe` 仍可经
  binfmt_misc 直接执行。该文件不在仓库内，内容如下（改完需 `wsl --shutdown`
  才生效）：

  ```ini
  [interop]
  appendWindowsPath=false
  ```
* Debian/Ubuntu（非 WSL）→ `apt` 安装发行版软件包；Neovim 用官方 release 压缩包
  （发行版的版本对 LazyVim 过旧）；`jj`/`mise`/`herdr`/`tuios`/`starship`/`atuin`/
  `lazygit`/`zellij`/`yazi`/`ouch`/`procs`/`broot`/`glow`/`btm`/`ast-grep`/
  `yq`/`bookokrat` 等用 GitHub release。
* Synology DSM → Entware（`opkg`）+ GitHub release 压缩包（装到 `~/bin`）。

镜像配置遵循 `USE_CN_MIRROR` / `DOTFILES_CONFIGURE_*` 覆盖项（Debian/Ubuntu
另可用 `DOTFILES_APT_MIRROR` 指定 apt 镜像）。

## 目录结构

* 顶层 dotfiles（`.zshrc`、`.bashrc` 等）→ 符号链接到 `~/`。
  **只有 `setup.sh` 里 `top_level_dotfiles` 白名单内的文件才会被链接**；
  顶层新增的隐藏文件默认不部署（`init` 时会打印 `note: … not linked`）。
  这样做是为了避免仓库里误留的 `.netrc` / `.api_key_env` 一类文件被自动铺到
  `$HOME`。新增顶层 dotfile 需要同时加入该白名单。
* `.gitconfig` — **例外，不符号链接**：`setup.sh` 在 `~/.gitconfig` 维护一个
  机器本地文件，用 `[include]` 引入本仓库的 `.gitconfig`（共享基线层），
  本地设置写在 include 之后因而生效。原因是 git 会穿透符号链接写入，
  `git config --global …`、`git lfs install`、credential helper 都会把机器状态
  直接改进仓库的 tracked 文件。`init` 会把旧的链接迁移成该文件并保留当前
  `user.name`/`user.email`（共享层设了 `useConfigOnly`，丢了会导致无法提交）；
  `check` 报告漂移，`repair` 补上/前置 `[include]`，`prune` 不会碰这个文件。
  注意据此不能靠 `$XDG_CONFIG_HOME/git/config` 分层：git 只在 `~/.gitconfig`
  缺失时才读它。
* `.config/*` → `~/.config/*`（文件符号链接；目录先创建再链接内容）。
* `.config/nvim` — 特例：LazyVim starter 树位于 `~/.config/nvim`，
  只有 `lua/config` 和 `lua/plugins` 来自本仓库。
* `bin/*` → `~/bin/*`。
* `tmuxinator/` → `~/.tmuxinator`。
* `noctty/config.ghostty` → `%LOCALAPPDATA%\noctty\config.ghostty`（Windows 终端
  noctty；不在 `$HOME` 下，由 `setup.sh` **复制**而非符号链接：WSL 走
  `cmd.exe`/`wslpath`，Git Bash 走 `%LOCALAPPDATA%`；首次覆盖会留一份
  `.dotfiles.bak` 备份）。
* noctty terminfo → `~/.terminfo/x/xterm-ghostty`：noctty 的 `term` 是
  `xterm-ghostty`，而 WSL 会话只有在发行版里有该条目时才会保留这个值
  （否则退回 `xterm-256color`；转发本身还需要 noctty ≥ 1.3.132）。`setup.sh`
  从 noctty 目录里的 `share/terminfo/ghostty.terminfo` 用 `tic -x` 编到用户级
  `~/.terminfo`（免 sudo），没有 `tic` 或找不到 noctty 目录时静默跳过；默认在
  `%LOCALAPPDATA%\Programs\noctty`、`%LOCALAPPDATA%\noctty`、
  `C:\Program Files\noctty` 依次查找，其他位置（Scoop、自选便携目录）用
  `DOTFILES_NOCTTY_DIR` 指定。`check` 把「缺失」和「比源文件旧」都算漂移
  （noctty 升级后条目过期属正常，`init`/`repair` 重编）。
* `.tmux.conf` — 自包含 tmux 配置（无子模块）。
* `CLI_TOOLS.md`、`KEYBINDINGS.md`、`TUIOS.md` — 顶层文档，不部署到 `$HOME`。

> 版本控制为 **jj + git 共存** 的 colocated workspace：`.jj/` 由自身的
> `.jj/.gitignore`（`/*`）屏蔽，不进入 git 树；提交统一走 `jj`（见 `AGENTS.md`）。

完整的 shell 启动流程与编辑规范见 `AGENTS.md`。

## 退役配置清单

`setup.sh prune` 会**主动删除**指向本仓库但源文件已不存在的死链。以下配置已从
本仓库退役，机器上残留的旧链接会在下次 `setup.sh prune` 时被移除
（`check` 会报告它们，`repair` 不会删除死链），属于预期行为，不是“配置丢了”：

| 配置                 | 现状                         |
| -------------------- | ---------------------------- |
| lvim（LunarVim）     | 已退役（改用 lazyvim/nvim）  |
| coc-settings.json    | 已退役（coc.nvim → 原生 LSP）|
| yazi `plugins/`、`package.toml` | 由 `ya pack` 管理，不入库 |
| `bin/generate_tags.sh` | 已退役（改用 gtags/ctags 流程）|
| `.claude-internal/hooks/` | herdr 集成已改为 `~/.claude` |
| `.codebuddy/hooks/`、`hooks-settings.json` | CodeBuddy 的 herdr/tuios hook 集成已退役（CodeBuddy CLI 自身配置仍留在机器上）|
| `.reasonix/hooks/`、`settings.json` | Reasonix 的 herdr hook 集成已退役；`config.toml` 仍保留并链接 |
| `cheat`、cheatsheets 子模块、`.config/cheat/conf.yml` | 已退役（速查内容见 `CLI_TOOLS.md`）|
| `.tmux` 子模块、`.tmux.conf.local` | 已退役（tmux 配置收敛为自包含的 `.tmux.conf`）|

自指的陈旧链接（如 `~/.zshrc.bak.*`、`~/.zshrc.pre-oh-my-zsh`）指向的源仍存在，
不会被自动清理；确认无用后可手动删除。

## Shell 启动流程

* `.zshenv` — 仅纯环境变量导出。
* `.zshrc` — zsh 框架部分：fpath/compinit、插件、缓存 init、PATH。
* `.bashrc` — 仅 bash 相关部分。
* `.config/shell/common.sh` — bash+zsh 共享环境、别名、运行时管理器激活、
  工具 init 缓存、跨 shell 辅助函数。
* `.zshrc.local` — zsh 交互覆盖（在本仓库中）；`.bashrc.local` — 机器本地覆盖（不在本仓库中）。

## tuios

tuios 是日常主力复用器。配置入口 `.config/tuios/config.toml` →
`~/.config/tuios/config.toml`（daemon 与 client 共用）；leader 是内建的 `Ctrl+b`。

**该文件由 tuios 写回**（设置页、`set-config`、`keybinds`），本仓库只审阅、不逐行手写。
维护口径见 [TUIOS.md](TUIOS.md)（含「0.11.0 复核」：Inbox 审批、subagent 行、bell 链路、
空串零值清理），自定义键位见 [KEYBINDINGS.md](KEYBINDINGS.md)。

## bin/ 脚本

| 脚本                     | 用途                                                       |
| ------------------------ | ---------------------------------------------------------- |
| `color.sh`               | 用循环 ANSI 颜色给 stdin 行上色                             |
| `find_duplicated.sh`     | 查找重复文件（大小 → 内容哈希；BSD/GNU 自适应，并行处理）    |
| `fzsession`              | 在 zellij/tmux/herdr/tuios 会话间 fzf 切换（绑定到 `Alt+z`） |
| `process_monitor.sh`     | 按名称/PID 监控进程，进程结束时执行命令                     |
| `update_all.sh`          | topgrade 驱动的包/运行时/插件更新                           |

## 更新

* `~/bin/update_all.sh` — topgrade 驱动，更新 brew/gem/npm/pip/cargo/…
  以及 mise 运行时、rustup、zsh 插件。加 `all` 参数会同时更新本仓库（以及未来可能重新引入的子模块）。
  仅当 topgrade 未安装时回退到手动更新；topgrade 失败后继续其他步骤，
  最后汇总失败项并返回非零状态。每次运行日志保存到
  `${XDG_CACHE_HOME:-~/.cache}/dotfiles/updates/`（需按需手动清理）。
* Linux/WSL/Synology 上另有两个 topgrade 覆盖不到的步骤：
  `tuios update` 自更新（macOS 由 brew 管，自动跳过），以及以
  `DOTFILES_RELEASES_REFRESH=1 setup.sh init --only releases` 重跑 `releases`
  段，把 starship/zoxide/lazygit/jj/zellij/yazi/mise/herdr 等 tarball 装的
  工具刷到最新（只重下过期的；apt/brew 副本不碰；版本号读不出来时跳过而不是
  反复重传）。tuios 自己的下载器有硬超时，慢网上会失败，随后由该段接手。
  tuios daemon 要重启后才换成新二进制。
* tmux 配置为自包含的 `.tmux.conf`（无子模块），直接修改即可；`.tmux.conf.local` 已退役。
* Neovim 插件采用滚动更新模型，`lazy-lock.json` 不做版本跟踪。
  每台机器按需执行 `:Lazy update` / `:Lazy restore`。

## 快捷键

统一快捷键方案（`Cmd` / `Alt` / `Ctrl+Alt`，覆盖 Ghostty、tuios、herdr、tmux、zellij）
见 [KEYBINDINGS.md](KEYBINDINGS.md)。常用 CLI 工具清单与命令片段见
[CLI_TOOLS.md](CLI_TOOLS.md)。
