local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo(
            {
                {
                    "Failed to clone lazy.nvim:\n",
                    "ErrorMsg"
                },
                {
                    out,
                    "WarningMsg"
                },
                {
                    "\nPress any key to exit..."
                },
            },
            true,
            {}
        )

        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.mousemoveevent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = false

vim.opt.list = true

-- let arrow keys cross line boundaries (VSCode/Zed-like); h/l left alone
vim.opt.whichwrap = "b,s,<,>"

-- shell
vim.opt.shell = 'C:\\msys64\\fish.cmd'
vim.opt.shellcmdflag = '-c'
vim.opt.shellquote = ''
vim.opt.shellxquote = ''

-- neovide
if vim.g.neovide then
    vim.g.neovide_window_blurred = true

    vim.g.neovide_opacity = 0.0
    vim.g.neovide_normal_opacity = 0.0

    vim.g.neovide_frameless_drag_region = true
end


-- tab/indentation settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- keybinds
-- save
vim.keymap.set({"", "i"}, "<C-s>", "<cmd>:w<CR><Esc>", { desc = "Save File" })

-- select all
vim.keymap.set({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all text" })
vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { desc = "Select all text" })

-- copy & paste
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection to clipboard" })

vim.keymap.set({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("i", "<C-v>", '<C-r>+', { desc = "Paste from clipboard in insert mode" })

-- undo & redo
vim.keymap.set({ "n", "v" }, "<C-z>", "u", { desc = "Undo change" })
vim.keymap.set("i", "<C-z>", "<Esc>ui", { desc = "Undo change" })

vim.keymap.set({ "n", "v" }, "<C-Z>", "<C-r>", { desc = "Redo change" })
vim.keymap.set("i", "<C-Z>", "<Esc><C-r>i", { desc = "Redo change" })

-- shift + cursor extends the selection, like VSCode/Zed
local shift_select = {
    { "<S-Right>", "<Right>" },
    { "<S-Left>",  "<Left>"  },
    { "<S-Down>",  "<Down>"  },
    { "<S-Up>",    "<Up>"    },
    { "<S-Home>",  "<Home>"  },
    { "<S-End>",   "<End>"   },
    { "<C-S-Right>", "e" },
    { "<C-S-Left>",  "b" },
}

for _, s in ipairs(shift_select) do
    local key, motion = s[1], s[2]
    vim.keymap.set("n", key, "v" .. motion, { desc = "Select " .. key })
    vim.keymap.set("x", key, motion, { desc = "Select " .. key })
    vim.keymap.set("i", key, "<C-\\><C-n>v" .. motion, { desc = "Select " .. key })
end

-- search
vim.keymap.set({ "n", "v" }, "<C-f>", "/", { desc = "Search forward" })
vim.keymap.set({ "n", "v" }, "<C-b>", "?", { desc = "Search backward" })

-- move / duplicate line
local function move_line(dir)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local last = vim.api.nvim_buf_line_count(0)
    if (dir > 0 and row >= last) or (dir < 0 and row <= 1) then return end
    local text = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})
    vim.api.nvim_buf_set_lines(0, row - 1 + dir, row - 1 + dir, false, text)
    vim.api.nvim_win_set_cursor(0, { row + dir, col })
end

local function duplicate_line(dir)
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local text = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    local at = dir > 0 and row or (row - 1)
    vim.api.nvim_buf_set_lines(0, at, at, false, text)
end

local function move_selection(dir)
    local s, e = vim.fn.getpos("v")[2], vim.fn.getpos(".")[2]
    if s > e then s, e = e, s end
    local last = vim.api.nvim_buf_line_count(0)
    if (dir > 0 and e >= last) or (dir < 0 and s <= 1) then return end
    vim.cmd(string.format("%d,%dm %d", s, e, dir > 0 and (e + 1) or (s - 2)))
    vim.cmd("normal! gv")
end

vim.keymap.set("n", "<A-Down>", function() move_line(1) end, { desc = "Move line down" })
vim.keymap.set("n", "<A-Up>", function() move_line(-1) end, { desc = "Move line up" })
vim.keymap.set("v", "<A-Down>", function() move_selection(1) end, { desc = "Move selection down" })
vim.keymap.set("v", "<A-Up>", function() move_selection(-1) end, { desc = "Move selection up" })
vim.keymap.set("n", "<S-A-Down>", function() duplicate_line(1) end, { desc = "Duplicate line down" })
vim.keymap.set("n", "<S-A-Up>", function() duplicate_line(-1) end, { desc = "Duplicate line up" })

-- delete line
vim.keymap.set({ "n", "v" }, "<C-S-k>", "<Cmd>normal! dd<CR>", { desc = "Delete line" })

-- comment
vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })

vim.keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })

-- new line
vim.keymap.set("n", "<C-CR>", "o", { desc = "Insert line below" })
vim.keymap.set("n", "<C-S-CR>", "O", { desc = "Insert line above" })
vim.keymap.set("i", "<C-CR>", "<Esc>o", { desc = "Insert line below" })
vim.keymap.set("i", "<C-S-CR>", "<Esc>O", { desc = "Insert line above" })

-- new terminals
local function recent_file_dir()
    local best, best_time = nil, 0
    for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        local name = info.name
        local lastused = info.lastused or 0
        if name ~= "" and vim.fn.isdirectory(vim.fn.fnamemodify(name, ":p:h")) == 1 then
            if lastused > best_time then
                best_time = lastused
                best = name
            end
        end
    end
    return best and vim.fn.fnamemodify(best, ":p:h") or (vim.uv.cwd() or ".")
end

local function pick_split_dir(dx, dy)
    if math.abs(dx) >= math.abs(dy) then
        return dx >= 0 and "right" or "left"
    end
    return dy >= 0 and "below" or "above"
end

-- dwindle window split
local function smart_split_dir()
    local pos = vim.api.nvim_win_get_position(0) -- {row, col}, 0-based screen cells
    local w = vim.api.nvim_win_get_width(0)
    local h = vim.api.nvim_win_get_height(0)

    local mp = vim.fn.getmousepos()
    if (mp.screenrow or 0) > 0 and (mp.screencol or 0) > 0 then
        local dx = ((mp.screencol - (pos[2] + 1)) / math.max(w - 1, 1)) - 0.5
        local dy = ((mp.screenrow - (pos[1] + 1)) / math.max(h - 1, 1)) - 0.5
        return pick_split_dir(dx, dy)
    end

    -- fall back to cursor pos
    local dx = ((vim.fn.wincol() - 1) / math.max(w - 1, 1)) - 0.5
    local dy = ((vim.fn.winline() - 1) / math.max(h - 1, 1)) - 0.5
    return pick_split_dir(dx, dy)
end

local function do_split(dir)
    local sr, sb = vim.o.splitright, vim.o.splitbelow
    vim.o.splitright = dir == "right"
    vim.o.splitbelow = dir == "below"

    if dir == "right" or dir == "left" then
        vim.cmd("vsplit")
    else
        vim.cmd("split")
    end

    vim.o.splitright, vim.o.splitbelow = sr, sb
end

local function open_terminal(dir)
    do_split(dir or smart_split_dir())
    vim.cmd("lcd " .. vim.fn.fnameescape(recent_file_dir()))
    vim.cmd("terminal")
end

vim.keymap.set("n", "<C-e>", function() open_terminal() end, { desc = "Open Terminal (smart split)" })
vim.keymap.set("n", "<C-S-e>", function() open_terminal("below") end, { desc = "Open Terminal (below)" })

-- windowing
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.keymap.set("", "<C-q>", "<cmd>:q<cr>", { desc = "Quit" })
vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:q<cr>", { desc = "Close terminal window" })

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("TerminalModifiable", { clear = true }),
    callback = function(args)
        vim.bo[args.buf].modifiable = true
    end,
})

-- config reload
vim.keymap.set(
    "n",
    "<C-R>",

    function()
        package.loaded["init"] = nil

        vim.cmd("source $MYVIMRC")
        print("Config successfully reloaded!")
    end,

    { desc = "Reload Neovim Config" }
)

-- lazy.nvim plugin reload
vim.keymap.set(
    "n",
    "<C-L>",

    function()
        vim.cmd("Lazy sync")
    end,

    { desc = "Sync and Reload Lazy.nvim" }
)

require("lazy").setup(
    {
        {
            "sainnhe/everforest",
            name = "everforest",
            lazy = false,
            priority = 1000,
            config = function()
                -- 0 = disabled, 1 = transparent background, 2 = transparent background + sign column/floating windows
                vim.g.everforest_transparent_background = 2

                -- 'hard', 'medium (default)', or 'soft'
                vim.g.everforest_background = 'hard'

                vim.cmd.colorscheme("everforest")
            end,
        },

        -- cursor
        {
            "sphamba/smear-cursor.nvim",
            cond = vim.g.neovide == nil,
            opts = {
                smear_between_buffers = true,
                smear_between_neighbor_lines = true,
                animation_stiffness = 0.1,
            },
        },

        -- smooth scrolling
        {
            "karb94/neoscroll.nvim",
            cond = vim.g.neovide == nil,
            config = function()
                require('neoscroll').setup({
                    mappings = { '<C-u>', '<C-d>', 'zt', 'zz', 'zb' },
                    hide_cursor = true,
                    stop_eof = true,
                    respect_scrolloff = false,
                    easing = 'linear',
                })
            end
        },

        -- whitespace
        {
            "mcauley-penney/visual-whitespace.nvim",
            opts = {
                enabled = true
            },
        },

        -- multicursor (ctrl+click)
        {
            "jake-stewart/multicursor.nvim",
            branch = "1.0",
            config = function()
                local mc = require("multicursor-nvim")
                mc.setup()

                local set = vim.keymap.set

                set("n", "<C-LeftMouse>", mc.handleMouse)
                set("n", "<C-LeftDrag>", mc.handleMouseDrag)
                set("n", "<C-LeftRelease>", mc.handleMouseRelease)

                set({ "n", "x" }, "<A-q>", mc.clearCursors)

                mc.addKeymapLayer(function(layerSet)
                    layerSet("n", "<Esc>", function()
                        if not mc.cursorsEnabled() then
                            mc.enableCursors()
                        else
                            mc.clearCursors()
                        end
                    end)
                end)
            end,
        },
    }
)
