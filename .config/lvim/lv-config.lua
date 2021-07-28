-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.format_on_save = true
lvim.lint_on_save = true
lvim.colorscheme = "spacegray"

--- Correct spell ---
vim.cmd "cab Qa qa"
vim.cmd "cab W w"
vim.cmd "cab Wq wq"
vim.cmd "cab Wa wa"
vim.cmd "cab X x"
-- cmd "cmap w!! w !sudo tee >/dev/null %"

-- keymappings
lvim.leader = "space"

-- general
lvim.colorscheme = "tokyonight"
-- lvim.colorscheme = "dark_plus"
-- lvim.colorscheme = "spacegray"

lvim.format_on_save = true
-- lvim.completion.autocomplete = true
lvim.builtin.compe.autocomplete = true
lvim.auto_close_tree = 0

--- No surround sound ---
vim.o.errorbells = false
vim.o.visualbell = false

-- For index
vim.o.wrap = true
vim.o.autoindent = true
vim.o.copyindent = true
vim.o.smartindent = true
vim.o.cindent = true
vim.o.cinoptions = ":0g0"
vim.o.smarttab = true
vim.o.shiftround = true

--- Format ---
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

--- Encoding setting ---
vim.o.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"

--- Search and Case ---
vim.o.gdefault = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.fileignorecase = true
vim.o.showcmd = true

--- Rule the define ---
vim.o.ruler = true
vim.o.cursorline = true
vim.o.number = true

--- always show signcolumns ---
vim.o.signcolumn = "yes"

--- faster completion ---
vim.o.updatetime = 300

--- No back up files ---
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

--- Mouse ---
vim.o.mouse = "a"
vim.o.mousemodel = "popup_setpos"

--- Undo ---
vim.o.undolevels = 1000

--- Fold ---
vim.o.foldmethod = "indent"
vim.o.foldlevel = 100

--- split ---
vim.o.splitbelow = true -- force all horizontal splits to go below current window
vim.o.splitright = true -- force all vertical splits to go to the right of current window

--- Other ---
vim.o.helplang = "cn"
vim.o.backspace = 'indent,eol,start'
vim.o.cscopetag = true
vim.o.cscopetagorder = 1
vim.o.virtualedit = 'block'
vim.o.wildmenu = true
vim.o.showmatch = true
vim.o.matchtime = 2
vim.o.title = true
vim.o.autoread = true
vim.o.clipboard = "unnamedplus,unnamed"
vim.o.history = 1000
vim.o.maxmempattern = 2000000
vim.o.pumheight = 50
vim.o.timeoutlen = 100


-- overwrite the key-mappings provided by LunarVim for any mode, or leave it empty to keep them
-- lvim.keys.normal_mode = {
--   Page down/up
--   {'[d', '<PageUp>'},
--   {']d', '<PageDown>'},
--
--   Navigate buffers
--   {'<Tab>', ':bnext<CR>'},
--   {'<S-Tab>', ':bprevious<CR>'},
-- }
-- if you just want to augment the existing ones then use the utility function
-- require("utils").add_keymap_insert_mode({ silent = true }, {
-- { "<C-s>", ":w<cr>" },
-- { "<C-c>", "<ESC>" },
-- })
-- you can also use the native vim way directly
-- vim.api.nvim_set_keymap("i", "<C-Space>", "compe#complete()", { noremap = true, silent = true, expr = true })

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

-- Navigate buffers
vim.api.nvim_set_keymap("n", '<Tab>', ':bnext<CR>', { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = false })

-- Movement in insert mode
vim.api.nvim_set_keymap("i", "<C-h>", "<C-o>h", { noremap = true, silent = false })
vim.api.nvim_set_keymap("i", "<C-l>", "<C-o>l", { noremap = true, silent = false })
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

vim.api.nvim_set_keymap("n", "<c-p>", "<cmd>lua require('telescope.builtin').find_files()<cr>", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("i", "<Tab>", "compe#confirm('<C-n>')", { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap("n", "<A-;>", "<CMD>lua _G.__fterm_lazygit()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-;>", "<C-\\><C-n><CMD>lua _G.__fterm_lazygit()<CR>", { noremap = true, silent = true })


-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0

lvim.builtin.which_key.active = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = { }
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.rainbow.enable = true
-- lvim.treesitter.playground.enable = true
lvim.builtin.treesitter.matchup.enable = true
lvim.builtin.treesitter.autotag.enable = true

lvim.builtin.compe.source.tabnine = { kind = "   (TabNine)", max_line = 1000, max_num_results = 6, priority = 5000, sort = false, show_prediction_strength = true, ignore_pattern = "" }

lvim.builtin.telescope.defaults.path_display = { "smart" }
lvim.builtin.telescope.defaults.mappings.i["<esc>"] = require("telescope.actions").close
-- lvim.plugin.telescope.defaults.mappings.i["<A-j>"] = require("telescope.actions").move_selection_next + require("telescope.actions").move_selection_next
-- lvim.plugin.telescope.defaults.mappings.i["<A-k>"] = require("telescope.actions").move_selection_previous + require("telescope.actions").move_selection_previous

-- generic LSP settings
lvim.lsp.default_keybinds = false
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gl", '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ show_header = false, border = "single" })<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "gp", "<cmd>lua require'lsp'.PeekDefinition()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "K", ":lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
vim.cmd 'command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()'
-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- Additional Plugins
lvim.plugins = {
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
        disable = false,
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
    {
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        ft = "markdown",
    },
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
function _G.__run_current_file()
    local ft = vim.api.nvim_buf_get_option(0, "filetype")
    local cs = {
        vim = ":source %",
        sh = "!bash %",
        zsh = "!zsh %",
        perl = "!perl %",
        python = ":!python3 %",
        ruby = ":!ruby %",
        javascript = ":!node %",
        -- markdown = ":MarkdownPreview",
        java = ":!echo %:r\\|awk -F'src/main/java/' '{print \"echo launch java \"$2\"...\\n java -cp \"$1\"target/classes \"$2}'\\|bash",
        html = ":!open %",
    }
    if vim.fn.exists(":MarkdownPreview") then
        cs.markdown = ":MarkdownPreview"
    elseif vim.fn.exists(":Xmark") then
        cs.markdown = ":Xmark"
    end
    if cs[ft] ~= nil then
        vim.cmd(cs[ft])
    else
        print("not supported filetype(" .. ft .. "), supported filetype:")
        for k, _ in pairs(cs) do
            print("  " .. k)
        end
    end
end

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
-- }
lvim.autocommands.custom_groups = {
    { "FileType", "cpp", "set tags+=~/cpp_tags" },
    -- vim自动打开跳到上次的光标位置
    { "BufReadPost", "*", "if line(\"'\\\"\") > 0|if line(\"'\\\"\") <= line(\"$\")|exe(\"norm '\\\"\")|else|exe \"norm $\"|endif|endif" },
}

-- Additional Leader bindings for WhichKey
lvim.builtin.which_key.mappings["<TAB>"] = { "<c-^>", "Switch Last Files" }
lvim.builtin.which_key.mappings[";"] = { ":%s/\\<<c-r><c-w>\\>//<left>", "Replace Word", silent = false }
lvim.builtin.which_key.mappings["q"] = { "<cmd>qa<CR>", "Quit" }
lvim.builtin.which_key.mappings["v"] = { "<cmd>e ~/.config/lvim/lv-config.lua<cr>", "Open lv-config.lua" }
lvim.builtin.which_key.mappings["o"] = { "<cmd>SymbolsOutline<CR>", "Symbols Outline" }
lvim.builtin.which_key.mappings["j"] = { "<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {border = lvim.lsp.popup_border}})<cr>", "Next Diagnostic" }
lvim.builtin.which_key.mappings["k"] = { "<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = lvim.lsp.popup_border}})<cr>", "Prev Diagnostic" }
lvim.builtin.which_key.mappings["s"]["w"] = { ":lua require('telescope.builtin').grep_string({search='<c-r><c-w>'})<cr>", "Grep Current Word"}
lvim.builtin.which_key.mappings["r"] = { ":lua _G.__run_current_file()<CR>", "Run Current File" }
lvim.builtin.which_key.mappings["<leader>"] = {
    name = "Hop Motions",
    w = { "<cmd>HopWord<cr>", "Word Mode" },
    n = { "<cmd>HopWordAC<cr>", "Word+ Mode" },
    p = { "<cmd>HopWordBC<cr>", "Word- Mode" },
    l = { "<cmd>HopLine<cr>", "Line Mode" },
    j = { "<cmd>HopLineAC<cr>", "Line+ Mode" },
    k = { "<cmd>HopLineBC<cr>", "Line- Mode" },
    c = { "<cmd>HopChar1<cr>", "1-Char Mode" },
    d = { "<cmd>HopChar2<cr>", "2-Char Mode" },
    ["/"] = { "<cmd>HopPattern<cr>", "Pattern Mode" },
}

