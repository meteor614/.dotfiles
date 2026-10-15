# tuios

tuios 是日常主力复用器（agent sidebar + 可脚本化的 pane）。本文记录其配置文件
`.config/tuios/config.toml` 的维护口径；自定义键位见 [KEYBINDINGS.md](KEYBINDINGS.md)。

配置入口 `.config/tuios/config.toml` → `~/.config/tuios/config.toml`（daemon 与 client 共用）。
以下口径核对于 **tuios 0.9.1**。

* **`config.toml` 是 tuios 写回的文件，本仓库只审阅、不逐行手写**。设置页
  （`ctrl+b ,`）、`tuios set-config`、`tuios keybinds free|unbind` 都会写它；0.8.x
  的写回会重写整份模板并钉回全部默认值，**0.9.1 起改为行级改写**——实测对全量模板跑
  `set-config appearance.gap 3`，diff 只有 `gap` 那一行，手写注释原样保留，符号链接
  不受影响。整份重写只剩错误路径（`tuios cannot change the lines of …` /
  `tuios cannot remove … without writing the whole file again`）。
* **瘦身用 `tuios config prune`，它是收敛的**。删掉值等于默认值的键，保留注释、保留
  `[startup]`、保留符号链接；之后日常 `set-config` / `keybinds` 改写不会把它撑回去
  （实测 653 → 193 行，连续改 appearance / theme / 键位后仍停在 197 行）。改动前先跑
  `--dry-run` 看清单。默认值对照：标量项 `tuios list-options --json`（216 项，不含
  keybindings），键位 `tuios keybinds list-custom`。
* **但 prune 不删「值不等于默认值」的行**，其中有一批是写回时填的结构体零值：
  `appearance.selection.*` 的七个颜色、`window_title_position = ''`（默认 `'top'`）、
  `startup.layout = ''`（默认 `'bsp'`）、`tiling_scheme = ''`（默认 `'spiral'`）、
  `master_position = ''` / `master_count = 0`、`zoom_size = 0`（默认 `95`）、
  `kitty_placeholders = ''`（默认 `'auto'`）、`sidebar.file_delete` / `folder_click` /
  `agent_rest_fold = ''`。这些键的「合法值」集合里没有空串，所以 `set-config` 写不进
  空串、只有整份模板才会带上它们。已实测非法值不会让整份文件被拒绝（同文件的
  `show_clock` 照样生效），文件头注释里「does not apply a file that has an error」
  对标量选项不成立。**尚未验证空串在运行时是否回落到默认值**——要在真机上确认 copy
  mode 选区有没有底色；确认回落则这批行纯属噪音，删不删都不改语义。
* **`tuios get-config` 不能用来审计这个文件**。它对所有键都报 `source = default` 并
  返回内置默认值，哪怕 daemon 明显在用配置里的值（实测 `show_ram = true` 时 dock 画出
  RAM，而 `get-config` 仍报 `false` / `default`）。查某键由哪个文件设置要用
  `tuios config origin <key>`，或直接读文件。
* **`[dock] left` 是刻意写出的默认顺序**：Dock 顶端的当前模式由内建 `mode` 组件显示
  （窗口管理 / terminal / copy / sidebar / hints / tiling 及其下一个分割方向），它
  默认就在 `left` 首位。显式写是为了抗住后续手动增删——region 列表是整份替换，不写就
  会退回默认顺序。`center` 故意留空，跟默认。
* **写回可能把符号链接换成普通文件**。tuios 改写的是 `~/.config/tuios/config.toml`
  这条指向仓库的链接；一旦它被替换成普通文件，仓库里那份就再也不会更新。
  `setup.sh check` 会报 `link mismatch`，`repair` 会备份并重链——前提是你想起来跑。
  （实测 0.9.1 的 `prune` / `set-config` / `keybinds` 都不破坏链接，但别把它当保证。）
* **热重载只覆盖 appearance，且要求 inode 不变**；temp+rename 的写入（`sed -i`、
  多数编辑器、`git`/`jj` checkout）会让 watcher 失效，而 `[keybindings]` 本来就只在
  client attach 时读取。改完这里：`ctrl+b d` detach 再 attach。`tuios config apply`
  两者都不重载。
* **leader 是内建的 `ctrl+b`，不可配置**（`tuios keybinds explain ctrl+b` 会说明这一点，
  所以 `keybindings.leader_key` 这类行纯属噪音）。自定义的 15 条键位见
  [KEYBINDINGS.md](KEYBINDINGS.md)；复核口径要注意：`tuios keybinds list-custom` 只列
  **替换了默认键**的 8 条，新增键（`alt+f`、`ctrl+alt+t`/`alt+n`、`ctrl+alt+z`、`alt+o`、`alt+v`、`alt+/`、`alt+i`）不计数，
  要用 `tuios keybinds doctor` 或 `keybinds explain <key>` 确认。瘦身时只按
  `list-custom` 对账会丢掉新增键，这是一个已经踩过的坑。准确总数用「空配置的
  `tuios keybinds list --json`」对比「当前配置的同名输出」，按 `(scope, action)` 配对。
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
