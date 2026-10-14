local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.default_prog = {
    'C:\\msys64\\fish.cmd',
}

config.keys = {
  {
    key = 'v',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard',
  },
}

config.window_decorations = 'RESIZE'

-- Opacity and Backdrop Settings matching Everforest
config.window_background_opacity = 0.0
config.win32_system_backdrop = 'Acrylic'
config.win32_acrylic_accent_color = '#2d353b' -- Matches Everforest background base

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.cursor_thickness = '2px'

-- Everforest Dark Color Palette
config.colors = {
  foreground = '#d3c6aa',
  background = '#2d353b',
  cursor_bg = '#a7c080',
  cursor_border = '#a7c080',
  cursor_fg = '#2d353b',
  selection_bg = '#475258',
  selection_fg = '#d3c6aa',
  ansi = {
    '#343f44', '#e67e80', '#a7c080', '#dbbc7f',
    '#7fbbb3', '#d699b6', '#83c092', '#859289',
  },
  brights = {
    '#475258', '#e67e80', '#a7c080', '#dbbc7f',
    '#7fbbb3', '#d699b6', '#83c092', '#9da9a0',
  },
}

config.scrollback_lines = 100000
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'

config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.5cell',
  bottom = '0.5cell',
}

config.font = wezterm.font 'JetBrains Mono'
config.font_size = 11.0
config.line_height = 1.12
config.freetype_load_flags = 'NO_HINTING'

-- Modern terminal configurations for crisp inputs and animations
config.enable_kitty_keyboard = true
config.animation_fps = 120

return config
