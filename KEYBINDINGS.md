# 统一快捷键方案

三层修饰键体系，在 WezTerm、Ghostty、tmux、zellij 之间保持一致的肌肉记忆。

| 层级 | 修饰键 | 作用域 | 示例 |
| ------ | -------- | -------- | ------ |
| **终端原生** | `Cmd` | 终端应用自身的标签页/分屏 | `Cmd+t` 新建标签页 |
| **复用器侧** | `Alt` | 复用器模式切换与面板焦点 | `Alt+1..9` 切换窗口/标签 |
| **扩展复用** | `Ctrl+Alt` | 结构性/破坏性复用器操作 | `Ctrl+Alt+w` 关闭窗口 |

---

## Cmd — 终端原生操作（WezTerm / Ghostty）

这些键由终端模拟器在到达 tmux/zellij 之前截获。
WezTerm 通过 `mux_action` 自动检测前台复用器，将 Cmd 键翻译为对应的复用器序列；
Ghostty 则将 Cmd 绑定到自身的原生分屏。

| 快捷键 | WezTerm（自适应复用器） | Ghostty（原生） |
| -------- | ------------------------ | ----------------- |
| `Cmd+t` | 新建标签页 | `new_tab` |
| `Cmd+n` | 新建 WezTerm 标签页 | `new_window` |
| `Cmd+w` | 关闭标签页/复用器窗口 | `close_surface` |
| `Cmd+d` | 向右分屏（水平） | `new_split:right` |
| `Cmd+Shift+d` | 向下分屏（垂直） | `new_split:down` |
| `Cmd+h/j/k/l` | 导航面板 | `goto_split:left/bottom/top/right` |
| `Cmd+方向键` | 调整面板大小 | `resize_split:方向,20` |
| `Cmd+[/]` | 上/下一个标签页 | `previous_tab`/`next_tab` |
| `Cmd+1..9` | 跳转到第 N 个标签页 | *（系统默认）* |
| `Cmd+Shift+c` | 复制模式（vi） | |
| `Alt+Enter` | 切换全屏 | `toggle_fullscreen` |

> **Ghostty + tmux/zellij**：Cmd 键操作的是 Ghostty 自身的标签页/分屏，
> 而非复用器。请使用下方的 `Alt` / `Ctrl+Alt` 键来驱动复用器。

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
| `prefix` + `Y` | 通过 clipper 发送到远程剪贴板（socat/nc） |
| 鼠标滚轮 | copy-mode-vi 中每次滚动 3 行 |

---

## 嵌套 tmux 会话

`Ctrl+Alt+a` 禁用外层 tmux 的前缀键，使所有按键直达内层会话。
再按一次恢复。状态栏会在外层被禁用时显示 `OFF`。

---

## WezTerm Cmd+Ctrl — 内层 tmux 透传

当 tmux 嵌套使用时（本地外层 + 远程内层），`Cmd+Ctrl` 通过双前缀
（`Ctrl-b Ctrl-b`）将按键发送到**内层** tmux。

| 快捷键 | 内层 tmux 操作 |
| -------- | --------------- |
| `Cmd+Ctrl+t` | 新建窗口 |
| `Cmd+Ctrl+h/j/k/l` | 导航面板 |
| `Cmd+Ctrl+方向键` | 调整面板大小 |
| `Cmd+Ctrl+[/]` | 上/下一个面板 |
| `Cmd+Ctrl+1..9` | 跳转到第 N 个窗口 |

---

## 配置文件

| 文件 | 配置内容 |
| ------ | ---------- |
| `.wezterm.lua` | Cmd 键、mux_action 自动检测 |
| `.config/ghostty/config` | Cmd 键（Ghostty 原生分屏） |
| `.tmux.conf.local` | Alt、Ctrl+Alt 键、鼠标、嵌套切换 |
| `.config/zellij/config.kdl` | Alt、Ctrl+Alt 键、模式切换 |
