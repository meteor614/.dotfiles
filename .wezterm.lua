-- ~/.wezterm.lua
local wezterm = require 'wezterm'

return {
  image_cache_ttl = 3600,
  enable_kitty_graphics = true,
  max_fps = 100,

  automatically_reload_config = true,

  -- set_environment_variables = { TERM_PROGRAM = 'alacritty' },
  -- color_scheme = 'AdventureTime',

  -- 字体
  font = wezterm.font_with_fallback {
    { family = 'Hack Nerd Font', weight = 'Regular' },
    -- { family = 'PingFang SC',    weight = 'Regular' },
    { family = 'Sarasa Mono SC', weight = 'Regular' },
  },
  font_size = 18,

  window_background_opacity = 0.8,

  audible_bell = 'Disabled',

  -- 键位映射
  keys = {
    -- Alt 组合
    { key = 'f', mods = 'ALT', action = wezterm.action.SendString '\x1bf' },
    { key = 'b', mods = 'ALT', action = wezterm.action.SendString '\x1bb' },
    { key = 'v', mods = 'ALT', action = wezterm.action.SendString '\x1bv' },
    { key = 'i', mods = 'ALT', action = wezterm.action.SendString '\x1bi' },

    -- Alt-Return 全屏
    { key = 'Return', mods = 'ALT', action = wezterm.action.ToggleFullScreen },

    { key = 'n', mods = 'CMD', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
    -- Cmd 组合（tmux 前缀 Ctrl-b + 按键）
    { key = 'w', mods = 'CMD', action = wezterm.action.SendString '\x02&' },
    { key = 'd', mods = 'CMD', action = wezterm.action.SendString '\x02_' },
    { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SendString '\x02-' },
    { key = 't', mods = 'CMD', action = wezterm.action.SendString '\x02c' },
    { key = 'h', mods = 'CMD', action = wezterm.action.SendString '\x02h' },
    { key = 'j', mods = 'CMD', action = wezterm.action.SendString '\x02j' },
    { key = 'k', mods = 'CMD', action = wezterm.action.SendString '\x02k' },
    { key = 'l', mods = 'CMD', action = wezterm.action.SendString '\x02l' },
    { key = 'LeftArrow',  mods = 'CMD', action = wezterm.action.SendString '\x02H' },
    { key = 'DownArrow',  mods = 'CMD', action = wezterm.action.SendString '\x02J' },
    { key = 'UpArrow',    mods = 'CMD', action = wezterm.action.SendString '\x02K' },
    { key = 'RightArrow', mods = 'CMD', action = wezterm.action.SendString '\x02L' },
    { key = ']', mods = 'CMD', action = wezterm.action.SendString '\x02o' },
    { key = '[', mods = 'CMD', action = wezterm.action.SendString '\x02;' },
    { key = '1', mods = 'CMD', action = wezterm.action.SendString '\x021' },
    { key = '2', mods = 'CMD', action = wezterm.action.SendString '\x022' },
    { key = '3', mods = 'CMD', action = wezterm.action.SendString '\x023' },
    { key = '4', mods = 'CMD', action = wezterm.action.SendString '\x024' },
    { key = '5', mods = 'CMD', action = wezterm.action.SendString '\x025' },
    { key = '6', mods = 'CMD', action = wezterm.action.SendString '\x026' },
    { key = '7', mods = 'CMD', action = wezterm.action.SendString '\x027' },
    { key = '8', mods = 'CMD', action = wezterm.action.SendString '\x028' },
    { key = '9', mods = 'CMD', action = wezterm.action.SendString '\x029' },
    { key = ']', mods = 'CMD|SHIFT', action = wezterm.action.SendString '\x02\x0c' },
    { key = '[', mods = 'CMD|SHIFT', action = wezterm.action.SendString '\x02\x08' },

    -- ALT
    { key = ']', mods = 'ALT', action = wezterm.action.ActivateTabRelative(1) },
    { key = '[', mods = 'ALT', action = wezterm.action.ActivateTabRelative(-1) },
    { key = '1', mods = 'ALT', action = wezterm.action.ActivateTab(0) },
    { key = '2', mods = 'ALT', action = wezterm.action.ActivateTab(1) },
    { key = '3', mods = 'ALT', action = wezterm.action.ActivateTab(2) },
    { key = '4', mods = 'ALT', action = wezterm.action.ActivateTab(3) },
    { key = '5', mods = 'ALT', action = wezterm.action.ActivateTab(4) },
    { key = '6', mods = 'ALT', action = wezterm.action.ActivateTab(5) },
    { key = '7', mods = 'ALT', action = wezterm.action.ActivateTab(6) },
    { key = '8', mods = 'ALT', action = wezterm.action.ActivateTab(7) },
    { key = '9', mods = 'ALT', action = wezterm.action.ActivateTab(8) },


    -- Vi 模式
    { key = 'c', mods = 'CMD|SHIFT', action = wezterm.action.ActivateCopyMode },
    { key = 'c', mods = 'CMD|SHIFT', mode = 'CopyMode', action = wezterm.action.CopyMode 'Close' },

    -- CMD+Ctrl 组合（Ctrl-b 前缀 + 按键）
    { key = 't', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02c' },
    { key = 'h', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02h' },
    { key = 'j', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02j' },
    { key = 'k', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02k' },
    { key = 'l', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02l' },
    { key = 'LeftArrow',  mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02H' },
    { key = 'DownArrow',  mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02J' },
    { key = 'UpArrow',    mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02K' },
    { key = 'RightArrow', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02L' },
    { key = ']', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02o' },
    { key = '[', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x02;' },
    { key = '1', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x021' },
    { key = '2', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x022' },
    { key = '3', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x023' },
    { key = '4', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x024' },
    { key = '5', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x025' },
    { key = '6', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x026' },
    { key = '7', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x027' },
    { key = '8', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x028' },
    { key = '9', mods = 'CMD|CTRL', action = wezterm.action.SendString '\x02\x029' },
  },
}

