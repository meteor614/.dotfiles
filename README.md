# dotfiles

我的全部 dotfiles，由 `setup.sh` 通过符号链接部署到 `$HOME`。

* neovim/lazyvim
* ghostty
* zellij/herdr/tuios/tmux/tmuxinator
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

`setup.sh` 支持四种模式：

| 模式      | 行为                                                    |
| --------- | ------------------------------------------------------- |
| `init`    | （默认）创建缺失的符号链接，然后安装依赖                 |
| `check`   | 只读：报告缺失/不匹配的链接（含指向本仓库但源已删除的死链） |
| `repair`  | 备份并修复不匹配的链接                                   |
| `prune`   | 删除死链（指向本仓库、源已不存在）及过期 `*.zwc`          |

参数：

* `--bootstrap-nvim` — 在 `~/.config/nvim` 采用 LazyVim starter 树
  （会先备份已有的 nvim 目录）。
* `--dry-run` — 只打印将要执行的操作，不做任何写入。
* `--only SECTION` — 只运行指定段（逗号分隔）。**不会**自动拉取依赖：
  如 `--only packages` 需先确保 `runtimes`，`herdr` 需先跑 `links`。

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

> 版本控制为 **jj + git 共存** 的 colocated workspace：`.jj/` 由自身的
> `.jj/.gitignore`（`/*`）屏蔽，不进入 git 树；提交统一走 `jj`（见 `AGENTS.md`）。

完整的 shell 启动流程与编辑规范见 `AGENTS.md`。

## 退役配置清单

`setup.sh prune` 会**主动删除**指向本仓库但源文件已不存在的死链。以下配置已从
本仓库退役，机器上残留的旧链接会在下次 `setup.sh prune` 时被移除
（`check` 会报告它们，`repair` 不会删除死链），属于预期行为，不是“配置丢了”：

| 配置                 | 现状                         |
| -------------------- | ---------------------------- |
| alacritty            | 已退役（改用 ghostty）       |
| lvim（LunarVim）     | 已退役（改用 lazyvim/nvim）  |
| coc-settings.json    | 已退役（coc.nvim → 原生 LSP）|
| yazi `plugins/`、`package.toml` | 由 `ya pack` 管理，不入库 |
| `bin/generate_tags.sh` | 已退役（改用 gtags/ctags 流程）|
| `.claude-internal/hooks/` | herdr 集成已改为 `~/.claude` |

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

配置入口 `.config/tuios/config.toml` → `~/.config/tuios/config.toml`（daemon 与 client 共用）。
以下口径核对于 **tuios 0.8.5**；`config.toml` 顶部只留「本文件是 diff / 删行=还原默认 /
路径是符号链接」这几条就地提示，其余说明以本节为准——两处各写一份必然漂移。

* **文件里只写偏离默认值的项**。默认值对照：标量项用 `tuios list-options --json`
  （196 项，不含 keybindings），键位用 `tuios keybinds list-custom`。删掉一行等于
  交还给下次启动时的默认值，所以瘦身不改变语义，不是“配置丢了”。
* **凡是 tuios 自己写回 config 的入口都会重写整份文件**：设置页（`ctrl+b ,`）、
  `tuios config edit`、`tuios keybinds free|unbind`。它们重新钉回全部默认值，并把
  文件里缺失的行写成结构体零值，而零值不总等于默认值（如 `window_title_position`
  默认 `'top'` 会被写成 `''`、`zoom_size` 的 `95` 写成 `0`）。已实测：在一次性
  `XDG_CONFIG_HOME` 下跑 `tuios keybinds unbind snap_fullscreen f`，写出的是整份
  模板。**所以改键位/外观一律手改这个文件**，这些命令只当只读诊断用；用过写回
  入口后 `git diff` 这里并重新瘦身。
* **写回可能把符号链接换成普通文件**。tuios 是原地改写 `~/.config/tuios/config.toml`
  这条指向仓库的链接；一旦它被替换成普通文件，仓库里那份就再也不会更新。
  `setup.sh check` 会报 `link mismatch`，`repair` 会备份并重链——前提是你想起来跑。
* **热重载只覆盖 appearance，且要求 inode 不变**；temp+rename 的写入（`sed -i`、
  多数编辑器、`git`/`jj` checkout）会让 watcher 失效，而 `[keybindings]` 本来就只在
  client attach 时读取。改完这里：`ctrl+b d` detach 再 attach。`tuios config apply`
  两者都不重载。
* **leader 是内建的 `ctrl+b`，不可配置**（`tuios keybinds explain ctrl+b` 会说明这一点，
  所以 `keybindings.leader_key` 这类行纯属噪音）。自定义的 11 条键位见
  [KEYBINDINGS.md](KEYBINDINGS.md)；复核口径要注意：`tuios keybinds list-custom` 只列
  **替换了默认键**的 8 条，新增键（`alt+f`、`ctrl+alt+t`/`alt+n`、`ctrl+alt+z`）不计数，
  要用 `tuios keybinds doctor` 或 `keybinds explain <key>` 确认。瘦身时只按
  `list-custom` 对账会丢掉新增键，这是一个已经踩过的坑。
* **OSC 133 命令标记由 `.config/shell/common.sh` 提供**（`A`/`B`/`C`/`D;<status>`）。
  daemon 自己 fork pane 的 shell，Ghostty 注入的 shell integration 到不了这一层；
  没有标记时 `tuios run` 会以 `no_shell_integration` 直接拒绝。验证用
  `tuios doctor shell`，且只对新开的 pane 生效——shell 在 pane 创建时 fork，
  detach/attach 不会重建它。
* `~/.config/tuios/themes/` 由 daemon 创建，**不入库**：`setup.sh` 逐子项链接
  `.config/*`，这个目录既不会被 link，`check`/`prune` 也不管它；`import-theme`
  导入的主题 json 属于本机状态。
* **agent 状态接入**：tuios 每个 pane 都注入 herdr 兼容环境（`HERDR_ENV=1`、
  `HERDR_SOCKET_PATH` 等），所以 herdr 的 hook 在 tuios 里本来就能打通；但原生
  `tuios agent-hook` 提供更细的状态（done 带末行摘要、needs_input 分类、activity
  ring）。为避免两条通道竞争写同一 pane，`herdr-agent-state.sh`（reasonix /
  codebuddy）在 `TUIOS_ENV=1` 时自行退出，改由 settings.json 里新增的
  `tuios agent-hook claude-code` 通道上报（reasonix / codebuddy 是 Claude fork，
  tuios 无官方集成，直接透传 hook payload，事件名与 claude-code 同名）。
  claude-code / qoder / pi 用官方条目，由 `setup.sh --only tuios` 执行
  `tuios integration install` 写入（`check` 模式只读跑 `integration status`）；
  卸载用 `tuios integration uninstall`，它只删自己带版本标记的条目。

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
  以及 mise 运行时、rustup、zsh 插件。加 `all` 参数会同时更新本仓库及子模块。
* 子模块（`.tmux`、cheat cheatsheets）视为上游管理。tmux 的覆盖请通过
  `.tmux.conf.local`，不要直接修改 `.tmux`。
* Neovim 插件采用滚动更新模型，`lazy-lock.json` 不做版本跟踪。
  每台机器按需执行 `:Lazy update` / `:Lazy restore`。

## 快捷键

统一快捷键方案（`Cmd` / `Alt` / `Ctrl+Alt`，覆盖 Ghostty、herdr、tmux、zellij）
见 [KEYBINDINGS.md](KEYBINDINGS.md)。
