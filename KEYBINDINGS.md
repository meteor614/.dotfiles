# 统一快捷键方案

三层修饰键体系，在 Ghostty、tmux、zellij 之间保持一致的肌肉记忆。

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

## 配置文件

| 文件 | 配置内容 |
| ------ | ---------- |
| `.config/ghostty/config` | Cmd 键（Ghostty 原生分屏） |
| `.tmux.conf.local` | Alt、Ctrl+Alt 键、鼠标、嵌套切换 |
| `.config/zellij/config.kdl` | Alt、Ctrl+Alt 键、模式切换 |
