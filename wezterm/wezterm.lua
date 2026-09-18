local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.default_prog = {
  'C:\\Users\\Rdepa29\\AppData\\Local\\Programs\\Git\\bin\\bash.exe',
  '--login',
  '-i',
  '-c',
  'exec /usr/bin/fish'
}

config.keys = {
  {
    key = 'v',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard',
  },
}

config.window_decorations = 'RESIZE'

config.window_background_opacity = 0.85
config.win32_system_backdrop = 'Acrylic'
config.win32_acrylic_accent_color = '#11111b'

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.cursor_thickness = '2px'

config.colors = {
  foreground = '#cdd6f4',
  background = '#1e1e2e',
  cursor_bg = '#f5e0dc',
  cursor_border = '#f5e0dc',
  cursor_fg = '#1e1e2e',
  selection_bg = '#585b70',
  selection_fg = '#cdd6f4',
  ansi = {
    '#45475a', '#f38ba8', '#a6e3a1', '#f9e2af',
    '#89b4fa', '#f5c2e7', '#94e2d5', '#bac2de',
  },
  brights = {
    '#585b70', '#f38ba8', '#a6e3a1', '#f9e2af',
    '#89b4fa', '#f5c2e7', '#94e2d5', '#a6adc8',
  },
  indexed = { [16] = '#fab387', [17] = '#cba6f7' },
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

config.enable_kitty_keyboard = false

return config
