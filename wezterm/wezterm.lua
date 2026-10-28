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

config.window_background_opacity = 1.0
config.win32_system_backdrop = 'Acrylic'
config.win32_acrylic_accent_color = '#1e1e2e'

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.cursor_thickness = '2px'

config.colors = {
  foreground = '#E6F2DE',
  background = '#1e1e2e',
  cursor_bg = '#C4FFB0',
  cursor_border = '#C4FFB0',
  cursor_fg = '#1e1e2e',
  selection_bg = '#3F4C3B',
  selection_fg = '#C4FFB0',
  ansi = {
    '#2F382C', '#FFB8B8', '#C4FFB0', '#FAF3B8',
    '#BCD3FF', '#E0CCFF', '#B8E8F0', '#E6F2DE',
  },
  brights = {
    '#7C8878', '#FFCECE', '#D6FFC8', '#FCF8D0',
    '#D2E0FF', '#EDDFFF', '#D6F2F8', '#F5F4EC',
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
