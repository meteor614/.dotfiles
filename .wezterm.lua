-- ~/.wezterm.lua
local wezterm = require 'wezterm'
local act = wezterm.action

local function basename(path)
    if not path or path == '' then
        return nil
    end
    local normalized = path:gsub('\\', '/')
    return normalized:match('([^/]+)$') or normalized
end

local function normalize_mux(value)
    if not value or value == '' then
        return nil
    end

    value = value:lower()
    if value == 'tmux' or value == 'zellij' then
        return value
    end

    return nil
end

local function current_mux(pane)
    -- Prefer an explicit mux hint from the shell prompt. This survives
    -- ssh hops where the local foreground process is just `ssh`.
    local user_vars = pane:get_user_vars() or {}
    local mux = normalize_mux(user_vars.MUX or user_vars.mux)
    if mux then
        return mux
    end

    return normalize_mux(basename(pane:get_foreground_process_name()))
end

local function zellij_key_action(key, mods)
    return act.SendKey {
        key = key,
        mods = mods or 'CTRL|ALT',
    }
end

local function zellij_tab_number_action(index)
    local function_keys = { 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9' }
    return zellij_key_action(function_keys[index])
end

local function mux_action(actions)
    return wezterm.action_callback(function(window, pane)
        local action = actions[current_mux(pane)] or actions.other
        if action then
            window:perform_action(action, pane)
        end
    end)
end

local keys = {
    -- Alt 组合
    { key = 'f', mods = 'ALT', action = act.SendString '\x1bf' },
    { key = 'b', mods = 'ALT', action = act.SendString '\x1bb' },
    { key = 'v', mods = 'ALT', action = act.SendString '\x1bv' },
    { key = 'i', mods = 'ALT', action = act.SendString '\x1bi' },

    -- Alt-Return 全屏
    { key = 'Return', mods = 'ALT', action = act.ToggleFullScreen },

    { key = 'n', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },

    -- Cmd 组合（根据当前前台 multiplexer 自适应）
    { key = 'w', mods = 'CMD', action = mux_action {
        tmux = act.SendString '\x02&',
        zellij = zellij_key_action('w'),
        other = act.CloseCurrentTab { confirm = true },
    } },
    { key = 'd', mods = 'CMD', action = mux_action {
        tmux = act.SendString '\x02_',
        zellij = zellij_key_action('d'),
        other = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    } },
    { key = 'd', mods = 'CMD|SHIFT', action = mux_action {
        tmux = act.SendString '\x02-',
        zellij = zellij_key_action('d', 'CTRL|ALT|SHIFT'),
        other = act.SplitVertical { domain = 'CurrentPaneDomain' },
    } },
    { key = 't', mods = 'CMD', action = mux_action {
        tmux = act.SendString '\x02c',
        zellij = zellij_key_action('t'),
        other = act.SpawnTab 'CurrentPaneDomain',
    } },
    { key = ']', mods = 'CMD', action = mux_action {
        tmux = act.SendString '\x02o',
        zellij = zellij_key_action('u'),
    } },
    { key = '[', mods = 'CMD', action = mux_action {
        tmux = act.SendString '\x02;',
        zellij = zellij_key_action('y'),
    } },
    { key = ']', mods = 'CMD|SHIFT', action = mux_action {
        tmux = act.SendString '\x02\x0c',
        zellij = zellij_key_action('u', 'CTRL|ALT|SHIFT'),
        other = act.ActivateTabRelative(1),
    } },
    { key = '[', mods = 'CMD|SHIFT', action = mux_action {
        tmux = act.SendString '\x02\x08',
        zellij = zellij_key_action('y', 'CTRL|ALT|SHIFT'),
        other = act.ActivateTabRelative(-1),
    } },

    -- ALT
    { key = ']', mods = 'ALT', action = act.ActivateTabRelative(1) },
    { key = '[', mods = 'ALT', action = act.ActivateTabRelative(-1) },
    { key = '1', mods = 'ALT', action = act.ActivateTab(0) },
    { key = '2', mods = 'ALT', action = act.ActivateTab(1) },
    { key = '3', mods = 'ALT', action = act.ActivateTab(2) },
    { key = '4', mods = 'ALT', action = act.ActivateTab(3) },
    { key = '5', mods = 'ALT', action = act.ActivateTab(4) },
    { key = '6', mods = 'ALT', action = act.ActivateTab(5) },
    { key = '7', mods = 'ALT', action = act.ActivateTab(6) },
    { key = '8', mods = 'ALT', action = act.ActivateTab(7) },
    { key = '9', mods = 'ALT', action = act.ActivateTab(8) },

    -- Vi 模式
    { key = 'c', mods = 'CMD|SHIFT', action = act.ActivateCopyMode },
    { key = 'c', mods = 'CMD|SHIFT', mode = 'CopyMode', action = act.CopyMode 'Close' },

    -- CMD+Ctrl 组合（Ctrl-b 前缀 + 按键）
    { key = 't', mods = 'CMD|CTRL', action = act.SendString '\x02\x02c' },
    { key = 'h', mods = 'CMD|CTRL', action = act.SendString '\x02\x02h' },
    { key = 'j', mods = 'CMD|CTRL', action = act.SendString '\x02\x02j' },
    { key = 'k', mods = 'CMD|CTRL', action = act.SendString '\x02\x02k' },
    { key = 'l', mods = 'CMD|CTRL', action = act.SendString '\x02\x02l' },
    { key = 'LeftArrow',  mods = 'CMD|CTRL', action = act.SendString '\x02\x02H' },
    { key = 'DownArrow',  mods = 'CMD|CTRL', action = act.SendString '\x02\x02J' },
    { key = 'UpArrow',    mods = 'CMD|CTRL', action = act.SendString '\x02\x02K' },
    { key = 'RightArrow', mods = 'CMD|CTRL', action = act.SendString '\x02\x02L' },
    { key = ']', mods = 'CMD|CTRL', action = act.SendString '\x02\x02o' },
    { key = '[', mods = 'CMD|CTRL', action = act.SendString '\x02\x02;' },
}

for _, mapping in ipairs({
    { key = 'h', tmux = '\x02h', zellij = 'h', other = 'Left' },
    { key = 'j', tmux = '\x02j', zellij = 'j', other = 'Down' },
    { key = 'k', tmux = '\x02k', zellij = 'k', other = 'Up' },
    { key = 'l', tmux = '\x02l', zellij = 'l', other = 'Right' },
}) do
    table.insert(keys, {
        key = mapping.key,
        mods = 'CMD',
        action = mux_action {
            tmux = act.SendString(mapping.tmux),
            zellij = zellij_key_action(mapping.zellij),
            other = act.ActivatePaneDirection(mapping.other),
        },
    })
end

for _, mapping in ipairs({
    { key = 'LeftArrow', tmux = '\x02H', zellij = 'h', other = { 'Left', 2 } },
    { key = 'DownArrow', tmux = '\x02J', zellij = 'j', other = { 'Down', 2 } },
    { key = 'UpArrow', tmux = '\x02K', zellij = 'k', other = { 'Up', 2 } },
    { key = 'RightArrow', tmux = '\x02L', zellij = 'l', other = { 'Right', 2 } },
}) do
    table.insert(keys, {
        key = mapping.key,
        mods = 'CMD',
        action = mux_action {
            tmux = act.SendString(mapping.tmux),
            zellij = zellij_key_action(mapping.key, 'CTRL|ALT|SHIFT'),
            other = act.AdjustPaneSize(mapping.other),
        },
    })
end

for i = 1, 9 do
    table.insert(keys, {
        key = tostring(i),
        mods = 'CMD',
        action = mux_action {
            tmux = act.SendString('\x02' .. tostring(i)),
            zellij = zellij_tab_number_action(i),
            other = act.ActivateTab(i - 1),
        },
    })
    table.insert(keys, {
        key = tostring(i),
        mods = 'CMD|CTRL',
        action = act.SendString('\x02\x02' .. tostring(i)),
    })
end

return {
    -- image_cache_ttl = 3600,
    front_end = "WebGpu",
    webgpu_power_preference = "HighPerformance",
    enable_kitty_graphics = true,
    max_fps = 100,

    -- 性能优化
    enable_scroll_bar = false,
    check_for_updates = false,
    animation_fps = 60,                   -- 最小化动画（tab 切换/关闭的淡入淡出）

    -- 光标优化
    cursor_blink_rate = 800,               -- 关闭光标闪烁，省去定时重绘

    -- 更快的启动和关闭
    skip_close_confirmation_for_processes_named = {
        'bash', 'sh', 'zsh', 'fish', 'tmux', 'zellij', 'nvim', 'vim',
        'nu', 'ssh', 'ssh-agent',
    },
    clean_exit_codes = { 130 },          -- Ctrl-C 退出也视为正常，不弹确认

    -- 关闭窗口时不等待子进程
    exit_behavior = 'Close',
    window_close_confirmation = 'NeverPrompt',

    automatically_reload_config = true,

    scrollback_lines = 5000,

    -- set_environment_variables = { TERM_PROGRAM = 'alacritty' },
    -- color_scheme = 'AdventureTime',

    -- 字体
    font = wezterm.font_with_fallback {
        { family = 'Hack Nerd Font', weight = 'Regular' },
        -- { family = 'PingFang SC',    weight = 'Regular' },
        { family = 'Sarasa Mono SC', weight = 'Regular' },
    },
    font_size = 18,
    freetype_load_flags = "NO_HINTING",

    window_background_opacity = 1.0,
    -- macos_window_background_blur = 20,
    window_decorations = "RESIZE",
    native_macos_fullscreen_mode = true,

    audible_bell = 'Disabled',

    -- tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,    -- 禁用动画减少开销
    show_tab_index_in_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true, -- 单标签时自动隐藏
    color_scheme = 'Catppuccin Mocha',

    enable_kitty_keyboard = true,
    enable_csi_u_key_encoding = true,

    -- 键位映射
    keys = keys,
}
