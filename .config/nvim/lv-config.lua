--[[
O is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]

---  HELPERS  ---
local cmd = vim.cmd
local opt = vim.opt

-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

--- Correct spell ---
cmd "cab Qa qa"
cmd "cab W w"
cmd "cab Wq wq"
cmd "cab Wa wa"
cmd "cab X x"
-- cmd "cmap w!! w !sudo tee >/dev/null %"

-- keymapping
-- fix
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true, silent = false })
vim.api.nvim_set_keymap("v", ";", ":", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "：", ":", { noremap = true, silent = false })
vim.api.nvim_set_keymap("v", "：", ":", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "、", "/", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "？", "?", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "。", ".", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "【【", "[[", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "】】", "]]", { noremap = true, silent = false })


 -- Keep search pattern at the center of the screen.
vim.api.nvim_set_keymap("n", "n", "nzz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "N", "Nzz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "*", "*zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "#", "#zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "g*", "g*zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "g;", "g;zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "g,", "g,zz", { noremap = true, silent = true })

-- 去掉上次搜索高亮
--vim.api.nvim_set_keymap("n", "<leader>/", ":nohls", { noremap = true, silent = true })

-- files
vim.api.nvim_set_keymap("i", "<C-s>", "<C-O>:update<cr>", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<C-s>", ":update<cr>", { noremap = true, silent = false })
-- nnoremap <leader>qa :qa<cr>
-- nnoremap <leader>w :w<cr>
-- nnoremap <leader>wq :wq<cr>
-- nnoremap <leader>v :e ~/.vimrc<cr>
-- nnoremap <leader>cd :cd %:p:h<cr>

-- vim.api.nvim_set_keymap("n", "<leader>n", ":bn<cr>", { noremap = true, silent = false })
-- vim.api.nvim_set_keymap("n", "<leader>p", ":bp<cr>", { noremap = true, silent = false })

-- Movement in insert mode
vim.api.nvim_set_keymap("i", "<C-h>", "<C-o>h", { noremap = true, silent = false })
vim.api.nvim_set_keymap("i", "<C-l>", "<C-o>l", { noremap = true, silent = false })
-- <c-j> and <c-k> map in compe plugins
-- vim.api.nvim_set_keymap("i", "<C-j>", "<C-o>j", { noremap = true, silent = false })
-- vim.api.nvim_set_keymap("i", "<C-k>", "<C-o>k", { noremap = true, silent = false })
vim.api.nvim_set_keymap("i", "<C-^>", "<C-o><C-^>", { noremap = true, silent = false })

-- jump
vim.api.nvim_set_keymap("n", "<c-j>", "15gj", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<c-k>", "15gk", { noremap = true, silent = false })
vim.api.nvim_set_keymap("v", "<c-j>", "15gj", { noremap = true, silent = false })
vim.api.nvim_set_keymap("v", "<c-k>", "15gk", { noremap = true, silent = false })

-- Quickfix
vim.api.nvim_set_keymap("n", "]q", ":cnext<cr>zz", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "[q", ":cprev<cr>zz", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "]l", ":lnext<cr>zz", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "[l", ":lprev<cr>zz", { noremap = true, silent = false })

-- Buffers
vim.api.nvim_set_keymap("n", "]b", ":bnext<cr>", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "[b", ":bprev<cr>", { noremap = true, silent = false })

-- Tabs
vim.api.nvim_set_keymap("n", "]t", ":tabn<cr>", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "[t", ":tabp<cr>", { noremap = true, silent = false })

-- CTRL+A moves to start of line in command mode
vim.api.nvim_set_keymap("c", "<c-a>", "<home>", { noremap = true, silent = false })
-- CTRL+E moves to end of line in command mode
vim.api.nvim_set_keymap("c", "<c-e>", "<end>", { noremap = true, silent = false })

-- move current line down
vim.api.nvim_set_keymap("", "-", ":m+<cr>", { noremap = true, silent = true })
-- move current line up
vim.api.nvim_set_keymap("", "<c-_>", ":m-2<cr>", { noremap = true, silent = true })
-- move visual selection down
vim.api.nvim_set_keymap("v", "-", ":m '>+1<cr>gv=gv", { noremap = true, silent = true })
-- move visual selection up
vim.api.nvim_set_keymap("v", "<c-_>", ":m '>-2<cr>gv=gv", { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', { noremap=true, silent=true })
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', { noremap=true, silent=true })

-- replace word under cursor
-- vim.api.nvim_set_keymap("n", "<leader>;", ":%s/<<c-r><c-w>>//<left>", { noremap = true, silent = false })

-- switch between last two files
-- vim.api.nvim_set_keymap("n", "<leader><tab>", "<c-^>", { noremap = true, silent = false })

vim.api.nvim_set_keymap('v', 'p', '"0p', {silent = true})
vim.api.nvim_set_keymap('v', 'P', '"0P', {silent = true})

-- fold
vim.api.nvim_set_keymap('n', 'zc', "@=((foldclosed(line('.')) < 0) ? 'zc' :'zo')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'zo', "@=((foldclosed(line('.')) < 0) ? 'zc' :'zo')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'zr', 'zR', {noremap = true, silent = true})

-- terminal
vim.api.nvim_set_keymap('t', '<esc>', '<c-\\><c-n>', { noremap = true, silent = false })

-- better indenting
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true, silent = true })


-- general
O.colorscheme = "tokyonight"
-- O.colorscheme = "dark_plus"
-- O.colorscheme = "spacegray"

O.format_on_save = true
O.completion.autocomplete = true
O.auto_close_tree = 0

--- No surround sound ---
O.default_options.errorbells = false
O.default_options.visualbell = false

-- For index
O.default_options.wrap = true
O.default_options.autoindent = true
O.default_options.copyindent = true
O.default_options.smartindent = true
O.default_options.cindent = true
O.default_options.cinoptions = ":0g0"
O.default_options.smarttab = true
O.default_options.shiftround = true

--- Format ---
O.default_options.tabstop = 4
O.default_options.shiftwidth = 4
O.default_options.softtabstop = 4
O.default_options.expandtab = true

--- Encoding setting ---
O.default_options.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"

--- Search and Case ---
O.default_options.gdefault = true
O.default_options.ignorecase = true
O.default_options.smartcase = true
O.default_options.hlsearch = true
O.default_options.incsearch = true
O.default_options.fileignorecase = true
O.default_options.showcmd = true

--- Rule the define ---
O.default_options.ruler = true
O.default_options.cursorline = true
O.default_options.number = true

--- always show signcolumns ---
O.default_options.signcolumn = "yes"

--- faster completion ---
O.default_options.updatetime = 300

--- No back up files ---
O.default_options.swapfile = false
O.default_options.backup = false
O.default_options.writebackup = false

--- Mouse ---
O.default_options.mouse = "a"
O.default_options.mousemodel = "popup_setpos"

--- Undo ---
O.default_options.undolevels = 1000

--- Fold ---
O.default_options.foldmethod = "indent"
O.default_options.foldlevel = 100

--- split ---
O.default_options.splitbelow = true -- force all horizontal splits to go below current window
O.default_options.splitright = true -- force all vertical splits to go to the right of current window

--- Other ---
O.default_options.helplang = "cn"
O.default_options.backspace = 'indent,eol,start'
O.default_options.cscopetag = true
O.default_options.cscopetagorder = 1
O.default_options.virtualedit = 'block'
O.default_options.wildmenu = true
O.default_options.showmatch = true
O.default_options.matchtime = 2
O.default_options.title = true
O.default_options.autoread = true
O.default_options.clipboard = "unnamedplus,unnamed"
O.default_options.history = 1000
O.default_options.maxmempattern = 2000000
O.default_options.pumheight = 50
O.default_options.timeoutlen = 100

O.leader_key = " "

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
O.plugin.dashboard.active = true
O.plugin.floatterm.active = true
O.plugin.zen.active = false
O.plugin.zen.window.height = 0.90

-- if you don't want all the parsers change this to a table of the ones you want
O.treesitter.ensure_installed = { }
O.treesitter.ignore_install = { "haskell" }
O.treesitter.highlight.enable = true
O.treesitter.rainbow.enable = true
O.treesitter.playground.enable = true
O.treesitter.matchup.enable = true
O.treesitter.autotag.enable = true

O.completion.source.tabnine = { kind = "   (TabNine)", max_line = 1000, max_num_results = 6, priority = 5000, sort = false, show_prediction_strength = true, ignore_pattern = "" }

O.plugin.telescope.defaults.path_display = { "smart" }
O.plugin.telescope.defaults.mappings.i["<esc>"] = require("telescope.actions").close

-- python
-- O.lang.python.linter = 'flake8'
O.lang.python.isort = true
O.lang.python.diagnostics.virtual_text = true
O.lang.python.analysis.use_library_code_types = true
-- to change default formatter from yapf to black
-- O.lang.python.formatter.exe = "black"
-- O.lang.python.formatter.args = {"-"}

-- go
-- to change default formatter from gofmt to goimports
-- O.lang.formatter.go.exe = "goimports"

-- javascript
O.lang.tsserver.linter = nil

-- rust
-- O.lang.rust.formatter = {
--   exe = "rustfmt",
--   args = {"--emit=stdout", "--edition=2018"},
-- }

-- latex
-- O.lang.latex.auto_save = false
-- O.lang.latex.ignore_errors = { }

-- Additional Plugins
O.user_plugins = {
    { "p00f/nvim-ts-rainbow", disable = false },
    { 'tzachar/compe-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-compe' },
    {
        "simrat39/symbols-outline.nvim",
        cmd = "SymbolsOutline",
        disable = false,
    },
    -- Diffview
    -- :DiffviewOpen [git rev] [args] [ -- {paths...}]
    -- :DiffviewOpen
    -- :DiffviewOpen HEAD~2
    -- :DiffviewOpen HEAD~4..HEAD~2
    -- :DiffviewOpen d4a7b0d
    -- :DiffviewOpen d4a7b0d..519b30e
    {
        "sindrets/diffview.nvim",
        cmd = "DiffviewOpen",
        disable = false,
    },
    -- { "overcache/NeoSolarized" },
    { "folke/tokyonight.nvim", disable = false },
    -- { "dunstontc/vim-vscode-theme", disable = false },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require("lsp_signature").on_attach()
        end,
        event = "InsertEnter",
    },
    {
        "unblevable/quick-scope",
        config = function()
            vim.cmd [[
            let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
            ]]
        end,
    },
    {
        "phaazon/hop.nvim",
        event = "BufRead",
        config = function()
            require("hop").setup()
        end,
    },
    {
        "andymass/vim-matchup",
        event = "CursorMoved",
        config = function()
            vim.g.loaded_matchit = 1
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        disable = true,
    },
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({ "*" }, {
                RGB = true, -- #RGB hex codes
                RRGGBB = true, -- #RRGGBB hex codes
                RRGGBBAA = true, -- #RRGGBBAA hex codes
                rgb_fn = true, -- CSS rgb() and rgba() functions
                hsl_fn = true, -- CSS hsl() and hsla() functions
                css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
            })
        end,
    },
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- O.user_autocommands = {{ "BufWinEnter", "*", "echo \"hi again\""}}
vim.api.nvim_command("autocmd FileType cpp set tags+=~/cpp_tags")
vim.api.nvim_command("autocmd FileType vim nmap <buffer> <space>r :source %<cr>")
vim.api.nvim_command("autocmd FileType sh nmap <buffer> <space>r :!bash %<cr>")
vim.api.nvim_command("autocmd FileType zsh nmap <buffer> <space>r :!zsh %<cr>")
vim.api.nvim_command("autocmd FileType perl nmap <buffer> <space>r :!perl %<cr>")
vim.api.nvim_command("autocmd FileType java nmap <buffer> <space>r :!echo %:r\\|awk -F'src/main/java/' '{print \"echo launch java \"$2\"...\\n java -cp \"$1\"target/classes \"$2}'\\|bash<cr>")
vim.api.nvim_command("autocmd FileType python nmap <buffer> <space>r :!python3 %<cr>")
vim.api.nvim_command("autocmd FileType ruby nmap <buffer> <space>r :!ruby %<cr>")
vim.api.nvim_command("autocmd FileType javascript nmap <buffer> <space>r :!node %<cr>")
vim.api.nvim_command("autocmd FileType markdown nmap <buffer> <space>r :Xmark<cr>")
-- vim自动打开跳到上次的光标位置
vim.api.nvim_command("autocmd BufReadPost * if line(\"'\\\"\") > 0|if line(\"'\\\"\") <= line(\"$\")|exe(\"norm '\\\"\")|else|exe \"norm $\"|endif|endif")

-- Additional Leader bindings for WhichKey
O.user_which_key = {
    ["<TAB>"] = { "<c-^>", "Switch Last Files" },
    [";"] = { ":%s/\\<<c-r><c-w>\\>//<left>", "Replace Word", silent = false },
    q = { "<cmd>qa<CR>", "Quit" },
    v = { "<cmd>e ~/.config/nvim/lv-config.lua<cr>", "Open lv-config.lua" },
    o = { "<cmd>SymbolsOutline<CR>", "Symbols Outline" },
    j = { "<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {border = O.lsp.popup_border}})<cr>", "Next Diagnostic" },
    k = { "<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = O.lsp.popup_border}})<cr>", "Prev Diagnostic" },
    s = {
        w = { ":lua require('telescope.builtin').grep_string({search='<c-r><c-w>'})<cr>", "Grep Current Word"}
    },
    ["<leader>"] = {
        name = "Hop Motions",
        w = { "<cmd>HopWord<cr>", "Word Mode" },
        l = { "<cmd>HopLine<cr>", "Line Mode" },
        c = { "<cmd>HopChar1<cr>", "1-Char Mode" },
        d = { "<cmd>HopChar2<cr>", "2-Char Mode" },
        p = { "<cmd>HopPattern<cr>", "Pattern Mode" },
    },
    -- A = {
    --     name = "+Custom Leader Keys",
    --     a = { "<cmd>echo 'first custom command'<cr>", "Description for a" },
    --     b = { "<cmd>echo 'second custom command'<cr>", "Description for b" },
    -- },
}


vim.api.nvim_command("autocmd BufReadPost * noremap <c-p> :lua require('telescope.builtin').find_files()<cr>")
vim.api.nvim_set_keymap("n", "<c-p>", "<cmd>lua require('telescope.builtin').find_files()<cr>", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("i", "<Tab>", "compe#confirm('<C-n>')", { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap("n", "<A-;>", "<CMD>lua _G.__fterm_lazygit()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-;>", "<C-\\><C-n><CMD>lua _G.__fterm_lazygit()<CR>", { noremap = true, silent = true })

