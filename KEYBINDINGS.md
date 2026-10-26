# 统一快捷键方案

三层修饰键体系，在 Ghostty、herdr、tuios、tmux、zellij 之间保持一致的肌肉记忆。

| 层级 | 修饰键 | 作用域 | 示例 |
| ------ | -------- | -------- | ------ |
| **终端原生** | `Cmd` | 终端应用自身的标签页/分屏 | `Cmd+t` 新建标签页 |
| **复用器侧** | `Alt` | 复用器模式切换与面板焦点 | `Alt+1..9` 切换窗口/标签 |
| **扩展复用** | `Ctrl+Alt` | 结构性/破坏性复用器操作 | `Ctrl+Alt+w` 关闭窗口 |

---

## Cmd — 终端原生操作（Ghostty）

这些键由终端模拟器在到达 tmux/zellij 之前截获。
Ghostty 将 Cmd 绑定到自身的原生标签页和分屏。

| 快捷键 | Ghostty |
| -------- | -------- |
| `Cmd+t` | `new_tab` |
| `Cmd+n` | `new_window` |
| `Cmd+w` | `close_surface` |
| `Cmd+d` | `new_split:right` |
| `Cmd+Shift+d` | `new_split:down` |
| `Cmd+h/j/k/l` | `goto_split:left/bottom/top/right` |
| `Cmd+方向键` | `resize_split:方向,20` |
| `Cmd+[/]` | `previous_tab`/`next_tab` |
| `Cmd+Shift+[/]` | `goto_split:previous`/`goto_split:next` |
| `Alt+Enter` | `toggle_fullscreen` |

> **Ghostty + tuios/herdr/tmux/zellij**：Cmd 键操作的是 Ghostty 自身的标签页/分屏，
> 而非复用器。请使用下方的 `Alt` / `Ctrl+Alt` 键来驱动复用器。

---

## 使用边界

- **Ghostty**：窗口级操作和临时本地分屏。`Cmd` 键只控制 Ghostty 自身，不进入 tuios/herdr/tmux/zellij。
- **tuios**：日常主力复用器，负责项目/session、pane/window、agent sidebar 与可脚本化 pane。
  `Ctrl+Alt+h/j/k/l` 与 `Ctrl+Alt+z` 的语义对齐 herdr；方向键和 `Alt+[`/`Alt+]` 的含义见下方 tuios 一节。
- **herdr**：兼容复用器 / agent 状态集成层。tuios 会向每个 pane 注入 herdr 兼容环境
  （`HERDR_ENV`、`HERDR_SOCKET_PATH` 等），herdr 的 hook 在 tuios 内仍可用。
- **zellij**：远程 SSH 兼容复用器（tuios 缺失时回退），也保留一套与 herdr/tmux 接近的 `Alt` / `Ctrl+Alt` 肌肉记忆。
- **tmux**：远程兼容与嵌套会话 fallback，尽量通过 `.tmux.conf.local` 覆盖，不改 submodule。

---

## Prefix — herdr 操作

herdr 使用 `Ctrl+b` 作为 prefix，和 tmux 默认一致（tuios 的 leader 同为内建 `Ctrl+b`，键位见下方 tuios 一节）。嵌套 tmux 时按两次 `Ctrl+b`
可透传到内层。常用快捷键同时保留 `Alt` / `Ctrl+Alt` 直达路径，减少 prefix 次数。

| 快捷键 | herdr |
| -------- | -------- |
| `Ctrl+b c` | 新建 tab |
| `Ctrl+b 1..9` | 切换第 N 个 tab |
| `Ctrl+b d` / `Alt+n` | 向右分 pane |
| `Ctrl+b Shift+d` / `Alt+N` | 向下分 pane |
| `Ctrl+b h/j/k/l` | 聚焦左/下/上/右 pane |
| `Ctrl+Alt+h/j/k/l` | 聚焦左/下/上/右 pane |
| `Ctrl+b Tab` / `Alt+]` | 下一个 pane |
| `Ctrl+b Shift+Tab` / `Alt+[` | 上一个 pane |
| `Ctrl+b ;` | 上一个 pane（tmux 同款） |
| `Ctrl+b b` | 显示/隐藏 sidebar |
| `Ctrl+b z` / `Ctrl+Alt+z` | 缩放（最大化）当前 pane，再按一次还原 |
| `Ctrl+b f` / `Alt+f` | 切换 floating pane |
| `Ctrl+b r` / `Alt+m` | 进入 resize mode |
| `Ctrl+b e` / `Alt+s` | 编辑 scrollback |
| `Ctrl+b [` / `Ctrl+b ]` | 上/下一个 workspace |
| `Ctrl+Alt+1..9` | 切换第 N 个 workspace |
| `Ctrl+b g` / `Alt+g` | goto |
| `Alt+1..9` | 聚焦第 N 个 agent |
| `Ctrl+b Alt+g` | popup 浮层打开 lazygit |
| `Ctrl+b Alt+d` | popup 浮层打开 lazydocker |
| `Ctrl+b Alt+y` | popup 浮层打开 yazi |

---

## Alt — 复用器模式与快速导航（tmux & zellij）

这些键穿透终端直达复用器。tmux 和 zellij 共享相同的绑定，切换时无需重新记忆。

| 快捷键 | tmux | zellij |
| -------- | ------ | -------- |
| `Alt+1..9` | `select-window -t N` | `GoToTab N` |
| `Alt+[` | `select-pane -t -` | `FocusPreviousPane` |
| `Alt+]` | `select-pane -t +` | `FocusNextPane` |
| `Alt+p` | | 面板模式 |
| `Alt+t` | | 标签页模式 |
| `Alt+s` | | 滚动模式 |
| `Alt+m` | | 调整大小模式 |
| `Alt+h` | | 移动模式 |
| `Alt+o` | | 会话模式 |
| `Alt+z` | | 会话管理器（直接打开，按 Esc 关闭） |
| `Alt+g` | | 锁定模式 |
| `Alt+b` | | Tmux 兼容模式 |
| `Alt+n` | | 新建面板 |
| `Alt+f` | | 切换浮动面板 |
| `Alt+q` | | 退出 |
| `Alt+=`/`-` | | 放大/缩小 |

---

## Ctrl+Alt — 扩展复用器操作（tmux & zellij）

需要刻意按下的组合键，用于结构性和破坏性操作。

| 快捷键 | tmux | zellij |
| -------- | ------ | -------- |
| `Ctrl+Alt+t` | 新建窗口 | `NewTab` |
| `Ctrl+Alt+w` | 关闭窗口（需确认） | `CloseTab` |
| `Ctrl+Alt+d` | 水平分屏（向右） | `NewPane "Right"` |
| `Ctrl+Alt+Shift+d` | 垂直分屏（向下） | `NewPane "Down"` |
| `Ctrl+Alt+h/l` | | 左右移动焦点/切换标签 |
| `Ctrl+Alt+j/k` | | 上下移动焦点 |
| `Ctrl+Alt+y` | | 聚焦上一个面板 |
| `Ctrl+Alt+u` | | 聚焦下一个面板 |
| `Ctrl+Alt+Shift+y` | | 切换到上一个标签页 |
| `Ctrl+Alt+Shift+u` | | 切换到下一个标签页 |
| `Ctrl+Alt+i/o` | | 向左/右移动标签页 |
| `Ctrl+Alt+[/]` | | 上/下一个布局 |
| `Ctrl+Alt+p` | | 切换面板分组 |
| `Ctrl+Alt+Shift+方向键` | | 按方向扩大面板 |
| `Ctrl+Alt+F1..F9` | | 跳转到第 N 个标签（备用） |

---

## tmux 专有

| 快捷键 | 功能 |
| -------- | ------ |
| `Ctrl+Alt+a` | 切换嵌套 tmux（禁用/启用外层会话） |
| 鼠标滚轮 | copy-mode-vi 中每次滚动 3 行 |

---

## 嵌套 tmux 会话

`Ctrl+Alt+a` 禁用外层 tmux 的前缀键，使所有按键直达内层会话。
再按一次恢复。状态栏会在外层被禁用时显示 `OFF`。

---

## tuios

leader 是内建的 `Ctrl+b`（不可配置），其余键位沿用上游默认。本仓库的改动见下表。
复核口径要注意：`tuios keybinds list-custom` 只列出**替换了默认键**的那几条，
新增键（`Alt+f`、`Ctrl+Alt+t`/`Alt+n`、`Ctrl+Alt+z`、`Alt+o`、`Alt+v`、`Alt+/`、`Alt+g`、`Alt+i`、`Ctrl+Alt+P`、prefix 的 `K`、prefix 的 `l`、copy mode 的 `p`）不计数，得用 `tuios keybinds doctor`
或 `tuios keybinds explain <key>` 看。全量模板下 `list-custom` 还会被 `opt+`/`alt+`
拼写别名行撑大（2026-10-23 实测 33 行，见 [TUIOS.md](TUIOS.md)「0.10.1 复核」），不能作对账依据。
准确差集用空配置的 `tuios keybinds list --json` 对比当前配置的同名输出，按
`(scope, action)` 配对、把 `opt+` 归一成 `alt+` 后取差集；2026-10-26 在 0.11.0 上实测 **20 条**
（旧口径的 17 条没算 `launcher = []` 与 `inbox_close` 追加的 `Alt+i`，所以别再用那个数字对账）。

| 快捷键 | 功能 | 与默认的差别 |
| -------- | ------ | ------------ |
| `Ctrl+Alt+h` / `Ctrl+Alt+l` | 左/右聚焦 pane | 替掉默认 `Alt+left` / `Alt+right`，把这两个键还给 shell（跳词） |
| `Ctrl+Alt+j` / `Ctrl+Alt+k` | 下/上聚焦 pane | 替掉默认 `Alt+down` / `Alt+up`，与 herdr 一致；`.zshrc.local` 的行首/行尾跳转因此可用 |
| `Alt+[` / `Alt+]` | 上/下一个 window（terminal 模式） | 默认用 `Alt+p` / `Alt+n`，这里换成 `Alt+[` / `Alt+]`；`Opt+Tab` / `Opt+Shift+Tab` 保留，`Alt+p` 因此空给 shell |
| `Ctrl+Alt+t` / `Alt+n` | 新建 window（global，两种模式都生效） | tuios 默认只在 leader 后绑 `n`，这里补上与 herdr/tmux/zellij 一致的 `Ctrl+Alt+t` |
| `Alt+f` | 显示/隐藏 scratch 终端 | tuios 没有浮动 pane，借用 herdr/zellij 的 `alt+f` 语义；prefix 的 `Ctrl+b g` 仍保留 |
| `Ctrl+Alt+z` | 全屏/最大化当前 pane（global，两种模式都生效） | tuios 默认只在 window 模式绑 `f`（prefix 的 `Ctrl+b z` 也保留）；这里补上与 herdr `zoom` 一致的 `Ctrl+Alt+z` |
| `Alt+o` | 跳到最老的需要你处理的项（global，两种模式都生效） | 对应 prefix 的 `Ctrl+b o`（next attention）；指向 agent 工作流的直达键，代价是 tuios 内 zsh 的 `Alt+o`（`cd ..`）失效 |
| `Alt+v` | 查看当前 pane 的改动（global，两种模式都生效） | 对应 prefix 的 `Ctrl+b v`；代价是 tuios 内 zsh 的 `Alt+v`（装了 `deer` 时）失效 |
| `Alt+/` | 在所有会话里查找 pane 并跳过去（global，两种模式都生效） | 对应 prefix 的 `Ctrl+b /`（choose_tree）；带预览的树形导航器 |
| `Alt+g` | 去任何地方：agent / session / workspace / pane 一张表（global，两种模式都生效） | 0.11.0 新动作 `goto_picker`（默认只有 `Ctrl+b G`）。与 `Alt+/` 的分工见下文 |
| `Alt+i` | 打开 Inbox；Inbox 已打开时再按一次关闭（global，两种模式都生效） | 对应 prefix 的 `Ctrl+b i`；指向 agent 工作流的直达键，inbox scope 里 `Alt+i` 绑到 `inbox_close`，实现开/关切换 |
| `Ctrl+Alt+P` | 打开命令面板（global，两种模式都生效） | 之前为保住 zsh 的 `Ctrl+P`（历史）解绑了面板；现按「Ctrl+Alt 结构层」语义绑到无冲突键，`Ctrl+P` 仍归 zsh |
| `Ctrl+b l` | 回到上一个 workspace（prefix） | tmux `l` 语义；`last_workspace` 无默认键，`l` 在 prefix 下空闲。`L` 被 layout 菜单占用，`last_session` 暂未绑 |
| copy mode `p` | 复制选区并压平换行后退出 copy mode（`copy_pipe`） | tmux `copy-pipe-and-cancel` 对应物，贴 LLM/聊天不乱版式；默认 `y` 仍按原格式复制 |
| `Ctrl+b K` | 清掉当前 pane 的 scrollback，提示符回到首行（prefix） | 0.11.0 新动作 `clear_scrollback`，**无默认键**。不走 `Super+k`：Ghostty 里 `super+k` 已绑 `goto_split:top`，为清屏拆掉分屏导航不划算；`K` 在 prefix 下空闲，且与 `Ctrl+b s`（scrollback 浏览器）、`Ctrl+b [`（copy mode）同类 |
| `Ctrl+p` | 不绑定 | 交回 zsh 的 `up-line-or-history`；命令面板改走 `Ctrl+Alt+P`（global）或 `Ctrl+b P` |
| `Alt+Space` | 不绑定 | zsh 里是 `expand-history`；launcher 改走 `Ctrl+b a` |

`auto_enter_terminal_on_focus = 'targeted'` 让编号选择和方向键在聚焦的同时把打字权
交给 pane，不会停在 window 模式。四个 `Alt+方向键` 全部不再被 tuios 占用，
分别落到 shell 的跳词（`←`/`→`）和行首/行尾（`↑`/`↓`）；`.config/zellij/config.kdl`
同步释放了这四个键，两个复用器现在一致。

`Alt+/` 与 `Alt+g` 是两条不同的路径，都保留：

| | `Alt+/`（`choose_tree`） | `Alt+g`（`goto_picker`） |
| --- | --- | --- |
| 列表形态 | 会话 → workspace → pane 的树，右半屏是**该 pane 的实时预览** | 扁平一页，行首标 `agent`/`session`/`workspace`/`pane` |
| 覆盖对象 | 只有 pane（含 `[hosts]` 里的机器） | agent、session、workspace、pane，**agent 是它独有的** |
| 搜索 | `/`，读名字/标题/目录/命令/会话/workspace + 每屏最后 40 行 | 边打边模糊搜，另支持 `harness:` `state:` `needs:you` `kind:` `ws:` 等选择器 |
| 空查询回车 | 无此语义 | 回到上次所在的位置（回跳） |
| 用法 | 靠画面认位置（"那条输出在哪个 pane"） | 盲跳 + agent 分流（"谁在等我"） |

另外两个 0.11.0 新默认键不用改配置就会生效：`Ctrl+b E`（把整个 scrollback 交给
`$EDITOR`，copy mode 里是 `Ctrl+g`）、`Ctrl+b A`（agent/approvals 设置页）。
中键粘贴已补回 `terminal_paste_host`（`middle`），与上游默认对齐。

`Ctrl+Alt+1..9` 是 0.11.0 新增的默认绑定（`send_to_workspace_N`：把 pane 送过去、人留在原地，
focus 落到本 workspace 的另一个 pane）。herdr 里同一个组合是"切到第 N 个 workspace"，
含义相反但恰好符合本仓库 `Ctrl+Alt` = 结构操作层的分层语义，所以保留默认、不再重绑；
切换仍走 `Alt+1..9`。

---

## 配置文件

| 文件 | 配置内容 |
| ------ | ---------- |
| `.config/ghostty/config` | Cmd 键（Ghostty 原生分屏） |
| `.config/alacritty/alacritty.toml` | 字体/字号对齐 noctty（Hack Nerd Font 12pt、无连字）；无原生分屏，Alt / Ctrl+Alt 原样透传给复用器（Windows/macOS 备选终端） |
| `.config/herdr/config.toml` | Prefix、Alt、Ctrl+Alt 键，agent/workspace/pane 行为 |
| `.tmux.conf.local` | Alt、Ctrl+Alt 键、鼠标、嵌套切换 |
| `.config/zellij/config.kdl` | Alt、Ctrl+Alt 键、模式切换 |
| `.config/tuios/config.toml` | 键位差集 20 条（替换/新增/解绑，逐条见上表）、Inbox 审批、sidebar/主题/startup；由 tuios 写回，本仓库只审阅（见 README「tuios」） |

