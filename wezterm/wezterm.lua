local wezterm = require 'wezterm'
local act = wezterm.action

-- This holding object provides cleaner error messages for typos
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

-- Removes the Windows title bar/borders; uses a thin resize border instead
config.window_decorations = 'RESIZE'

-- Kitty-style translucent background with Acrylic blur behind the window
config.window_background_opacity = 0.85
config.win32_system_backdrop = 'Acrylic'
config.win32_acrylic_accent_color = '#11111b'

-- Smooth blinking bar cursor (Kitty-like)
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.cursor_thickness = '2px'

-- Catppuccin Mocha palette
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

-- Kitty-like behavior extras
config.scrollback_lines = 100000
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'

-- Automatically hides the top tab bar if you only have one tab open
config.hide_tab_bar_if_only_one_tab = true

-- Tightens up internal padding so text hugs the window edges gracefully
config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.5cell',
  bottom = '0.5cell',
}

-- Replaces standard Windows text rendering with a cleaner, softer look
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 11.0
config.line_height = 1.12
config.freetype_load_flags = 'NO_HINTING'

-- Kitty keyboard protocol is buggy in WezTerm on this setup (mangles shifted
-- printable chars like !@#$%^&*() :, capitals, etc. in fish), so keep it off
config.enable_kitty_keyboard = false

-- Returns the full config to WezTerm
return config
