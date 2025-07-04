-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

--- Correct spell ---
vim.cmd([[
    cab Qa qa
    cab W w
    cab Wq wq
    cab Wa wa
    cab X x
    set shortmess=atI
]])
-- cmd "cmap w!! w !sudo tee >/dev/null %"

-- keymappings
lvim.leader = "space"

-- general
lvim.format_on_save = false
lvim.lint_on_save = true
lvim.transparent_window = true
lvim.auto_close_tree = 0
lvim.colorscheme = "tokyonight"

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
-- vim.o.cscopetag = true
-- vim.o.cscopetagorder = 1
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
vim.o.inccommand = 'split'


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
local opt_tf = { noremap = true, silent = false }
local opt_tt = { noremap = true, silent = true }

vim.api.nvim_set_keymap("n", ";", ":", opt_tf)
vim.api.nvim_set_keymap("v", ";", ":", opt_tf)
vim.api.nvim_set_keymap("n", "：", ":", opt_tf)
vim.api.nvim_set_keymap("v", "：", ":", opt_tf)
vim.api.nvim_set_keymap("n", "、", "/", opt_tf)
vim.api.nvim_set_keymap("n", "？", "?", opt_tf)
vim.api.nvim_set_keymap("n", "。", ".", opt_tf)
vim.api.nvim_set_keymap("n", "【【", "[[", opt_tf)
vim.api.nvim_set_keymap("n", "】】", "]]", opt_tf)

 -- Keep search pattern at the center of the screen.
vim.api.nvim_set_keymap("n", "n", "nzz", opt_tt)
vim.api.nvim_set_keymap("n", "N", "Nzz", opt_tt)
vim.api.nvim_set_keymap("n", "*", "*zz", opt_tt)
vim.api.nvim_set_keymap("n", "#", "#zz", opt_tt)
vim.api.nvim_set_keymap("n", "g*", "g*zz", opt_tt)
vim.api.nvim_set_keymap("n", "g;", "g;zz", opt_tt)
vim.api.nvim_set_keymap("n", "g,", "g,zz", opt_tt)

-- 去掉上次搜索高亮
--vim.api.nvim_set_keymap("n", "<leader>/", ":nohls", opt_tt)

-- files
vim.api.nvim_set_keymap("i", "<C-s>", "<C-O>:update<cr>", opt_tf)
vim.api.nvim_set_keymap("n", "<C-s>", ":update<cr>", opt_tf)

-- Navigate buffers
vim.api.nvim_set_keymap("n", '<Tab>', ':bnext<CR>', opt_tf)
vim.api.nvim_set_keymap("n", '<S-Tab>', ':bprevious<CR>', opt_tf)

-- Movement in insert mode
vim.api.nvim_set_keymap("i", "<C-h>", "<C-o>h", opt_tf)
vim.api.nvim_set_keymap("i", "<C-l>", "<C-o>l", opt_tf)
vim.api.nvim_set_keymap("i", "<C-^>", "<C-o><C-^>", opt_tf)

-- jump
vim.api.nvim_set_keymap("n", "<c-j>", "15gj", opt_tf)
vim.api.nvim_set_keymap("n", "<c-k>", "15gk", opt_tf)
vim.api.nvim_set_keymap("v", "<c-j>", "15gj", opt_tf)
vim.api.nvim_set_keymap("v", "<c-k>", "15gk", opt_tf)

-- Quickfix
vim.api.nvim_set_keymap("n", "]q", ":cnext<cr>zz", opt_tf)
vim.api.nvim_set_keymap("n", "[q", ":cprev<cr>zz", opt_tf)
vim.api.nvim_set_keymap("n", "]l", ":lnext<cr>zz", opt_tf)
vim.api.nvim_set_keymap("n", "[l", ":lprev<cr>zz", opt_tf)

-- Buffers
vim.api.nvim_set_keymap("n", "]b", ":bnext<cr>", opt_tf)
vim.api.nvim_set_keymap("n", "[b", ":bprev<cr>", opt_tf)

-- Tabs
vim.api.nvim_set_keymap("n", "]t", ":tabn<cr>", opt_tf)
vim.api.nvim_set_keymap("n", "[t", ":tabp<cr>", opt_tf)

-- CTRL+A moves to start of line in command mode
vim.api.nvim_set_keymap("c", "<c-a>", "<home>", opt_tf)
-- CTRL+E moves to end of line in command mode
vim.api.nvim_set_keymap("c", "<c-e>", "<end>", opt_tf)

-- move current line down
vim.api.nvim_set_keymap("", "-", ":m+<cr>", opt_tt)
-- move current line up
vim.api.nvim_set_keymap("", "<c-_>", ":m-2<cr>", opt_tt)
-- move visual selection down
vim.api.nvim_set_keymap("v", "-", ":m '>+1<cr>gv=gv", opt_tt)
-- move visual selection up
vim.api.nvim_set_keymap("v", "<c-_>", ":m '>-2<cr>gv=gv", opt_tt)

vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opt_tt)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opt_tt)

vim.api.nvim_set_keymap('v', 'p', '"0p', opt_tt)
vim.api.nvim_set_keymap('v', 'P', '"0P', opt_tt)

-- fold
vim.api.nvim_set_keymap('n', 'zc', "@=((foldclosed(line('.')) < 0) ? 'zc' :'zo')<CR>", opt_tt)
vim.api.nvim_set_keymap('n', 'zo', "@=((foldclosed(line('.')) < 0) ? 'zc' :'zo')<CR>", opt_tt)
vim.api.nvim_set_keymap('n', 'zr', 'zR', opt_tt)

-- terminal
vim.api.nvim_set_keymap('t', '<esc>', '<c-\\><c-n>', opt_tf)
vim.api.nvim_set_keymap("t", "<c-w>", "<c-\\><c-n><c-w>", opt_tf)

-- better indenting
vim.api.nvim_set_keymap("v", "<", "<gv", opt_tt)
vim.api.nvim_set_keymap("v", ">", ">gv", opt_tt)

vim.api.nvim_set_keymap("n", "<c-p>", "<cmd>lua require('telescope.builtin').find_files()<cr>", opt_tt)
vim.api.nvim_set_keymap("n", "<c-t>", '<cmd>exe v:count1 . "ToggleTerm direction=float"<cr>', opt_tt)
vim.api.nvim_set_keymap("t", "<c-t>", '<cmd>exe v:count1 . "ToggleTerm direction=float"<cr>', opt_tt)
vim.api.nvim_set_keymap("n", "<A-i>", "<c-t>", { noremap = false, silent = true })
vim.api.nvim_set_keymap("t", "<A-i>", "<c-t>", { noremap = false, silent = true })
vim.api.nvim_set_keymap("n", "<A-f>", '<cmd>exe v:count1 . "ToggleTerm direction=float"<cr>', opt_tt)
vim.api.nvim_set_keymap("t", "<A-f>", '<cmd>exe v:count1 . "ToggleTerm direction=float"<cr>', opt_tt)
vim.api.nvim_set_keymap("n", "<A-b>", '<cmd>exe v:count1 . "ToggleTerm size=20 direction=horizontal"<cr>', opt_tt)
vim.api.nvim_set_keymap("t", "<A-b>", '<cmd>exe v:count1 . "ToggleTerm size=20 direction=horizontal"<cr>', opt_tt)
vim.api.nvim_set_keymap("n", "<A-v>", '<cmd>exe v:count1 . "ToggleTerm size=60 direction=vertical"<cr>', opt_tt)
vim.api.nvim_set_keymap("t", "<A-v>", '<cmd>exe v:count1 . "ToggleTerm size=60 direction=vertical"<cr>', opt_tt)

-- disable deprecated message
vim.deprecate = function() end

if lvim.builtin.alpha ~= nil then
    lvim.builtin.alpha.active = false
end
lvim.builtin.terminal.active = true
lvim.builtin.which_key.active = true

-- if lvim.builtin.nvimtree ~= nil then
--     lvim.builtin.nvimtree.setup.auto_open = 0
--     lvim.builtin.nvimtree.setup.side = "left"
--     lvim.builtin.nvimtree.setup.disable_window_picker = 1
--     lvim.builtin.nvimtree.setup.hide_dotfiles = 0
-- end

-- if you don't want all the parsers change this to a table of the ones you want
if lvim.builtin.treesitter ~= nil then
    -- lvim.builtin.treesitter.ensure_installed = "maintained"
    -- lvim.builtin.treesitter.ensure_installed = { "lua", "vimdoc", "awk", "bash", "cmake", "c", "cpp", "css", "dockerfile", "diff", "gitcommit", "go", "html", "http", "java", "javascript", "jq", "json", "json5", "make", "markdown", "perl", "python", "typescript", "vim", "yaml"}
    lvim.builtin.treesitter.ensure_installed = { "lua", "vimdoc", "awk", "bash", "cmake", "c", "cpp", "css", "dockerfile", "diff", "gitcommit", "go", "http", "java", "javascript", "jq", "json", "json5", "make", "markdown", "perl", "python", "typescript", "vim", "yaml"}
    lvim.builtin.treesitter.ignore_install = { "haskell", "html" }
    lvim.builtin.treesitter.highlight.enable = true
    lvim.builtin.treesitter.rainbow.enable = true
    lvim.builtin.treesitter.rainbow.extended_mode = true
    lvim.builtin.treesitter.rainbow.max_file_lines = nil
    lvim.builtin.treesitter.matchup.enable = true
    lvim.builtin.treesitter.autotag.enable = true
end

if lvim.builtin.compe ~= nil then
    lvim.builtin.compe.autocomplete = true
    lvim.builtin.compe.source.nvim_lua = true
    lvim.builtin.compe.source.tabnine = {
        kind = "   (TabNine)",
        max_line = 1000,
        max_num_results = 6,
        priority = 5000,
        sort = false,
        show_prediction_strength = true,
        ignore_pattern = ""
    }
end

if lvim.builtin.telescope ~= nil then
    lvim.builtin.telescope.defaults.initial_mode = "insert"
    lvim.builtin.telescope.defaults.path_display = { "smart" }
    if lvim.builtin.telescope.defaults.mappings == nil then
        lvim.builtin.telescope.defaults.mappings = {
            i = { }
        }
    end
    local actions = require "telescope.actions"
    lvim.builtin.telescope.defaults.mappings.i["<esc>"] = actions.close
    lvim.builtin.telescope.defaults.mappings.i["<C-j>"] = actions.move_selection_next
    lvim.builtin.telescope.defaults.mappings.i["<C-k>"] = actions.move_selection_previous
    lvim.builtin.telescope.defaults.mappings.n["<C-j>"] = actions.move_selection_next
    lvim.builtin.telescope.defaults.mappings.n["<C-k>"] = actions.move_selection_previous
    -- if lvim.builtin.telescope.pickers ~= nil then
    --     -- disable LunarVim's modifications, enable preview again
    --     lvim.builtin.telescope.pickers = nil
    -- end
    lvim.builtin.telescope.on_config_done = function(telescope)
        pcall(telescope.load_extension, "media_files")
    end
    lvim.builtin.telescope.defaults.preview = {
        check_mime_type = true,
        filesize_limit = 25,
        timeout = 250,
        msg_bg_fillchar = "╱",
        hide_on_startup = false,
        treesitter = true,
        mime_hook = function(filepath, bufnr, opts)
				local is_image = function(filepath1)
					-- local image_extensions = { "png", "jpg", "jpeg" } -- Supported image formats
					local image_extensions = { "png", "jpg", "jpeg", "webp", "gif" } -- Supported image formats
					local split_path = vim.split(filepath1:lower(), ".", { plain = true })
					local extension = split_path[#split_path]
					return vim.tbl_contains(image_extensions, extension)
				end
				if is_image(filepath) then
					local term = vim.api.nvim_open_term(bufnr, {})
					local function send_output(_, data, _)
						for _, d in ipairs(data) do
							vim.api.nvim_chan_send(term, d .. "\r\n")
						end
					end
					vim.fn.jobstart({
						-- "viu",
						"chafa",
						filepath,
					}, {
						on_stdout = send_output,
						stdout_buffered = true,
					})
				else
					require("telescope.previewers.utils").set_preview_message(
						bufnr,
						opts.winid,
						"Binary cannot be previewed"
					)
				end
			end
    }
end

if lvim.builtin.project ~= nil then
    lvim.builtin.project.patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", ".venv" }
end

require('telescope').load_extension('projects')

if lvim.builtin.nvimtree ~= nil then
    lvim.builtin.nvimtree.setup.view.width = 40
end

-- generic LSP settings
lvim.lsp.default_keybinds = false
lvim.lsp.installer.setup.automatic_installation = true
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opt_tt)
vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opt_tt)
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opt_tt)
vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opt_tt)
vim.api.nvim_set_keymap("n", "gl", '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ show_header = false, border = "single" })<CR>', opt_tt)
vim.api.nvim_set_keymap("n", "gp", "<cmd>lua require'lsp'.PeekDefinition()<CR>", opt_tt)
vim.api.nvim_set_keymap("n", "K", ":lua vim.lsp.buf.hover()<CR>", opt_tt)
-- vim.api.nvim_set_keymap("n", "<a-j>", "<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {border = lvim.lsp.popup_border}})<cr>", opt_tt)
-- vim.api.nvim_set_keymap("n", "<a-k>", "<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = lvim.lsp.popup_border}})<cr>", opt_tt)
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
    { "HiPhish/rainbow-delimiters.nvim" },
    -- {
    --     "tzachar/cmp-tabnine",
    --     build = "./install.sh",
    --     dependencies = "hrsh7th/nvim-cmp",
    --     event = "InsertEnter",
    -- },
    {
        'stevearc/aerial.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
    },
    -- {
    --     "simrat39/symbols-outline.nvim",
    --     config = function()
    --         require('symbols-outline').setup()
    --     end
    -- },
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
    },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require("lsp_signature").on_attach()
        end,
        event = "InsertEnter",
    },
    -- {
    --     "unblevable/quick-scope",
    --     config = function()
    --         vim.cmd [[ let g:qs_highlight_on_keys = ['f', 'F', 't', 'T'] ]]
    --     end,
    -- },
    {
        "phaazon/hop.nvim",
        event = "BufRead",
        config = function()
            require("hop").setup()
        end,
    },
    -- {
    --     "andymass/vim-matchup",
    --     event = "CursorMoved",
    --     config = function()
    --         vim.g.loaded_matchit = 1
    --         vim.g.matchup_matchparen_offscreen = { method = "popup" }
    --     end,
    -- },
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
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
    -- {
    --     "iamcco/markdown-preview.nvim",
    --     build = "cd app && npm install",
    --     ft = "markdown",
    -- },
    -- { "folke/trouble.nvim", cmd = "TroubleToggle" },
    -- { "metakirby5/codi.vim", cmd = "Codi", },
    -- {
    --     "gelguy/wilder.nvim",
    --     config = function ()
    --         -- vim.cmd("source $HOME/.config/lvim/lua/user/wilder.vim")
    --         vim.cmd([[
    --         call wilder#enable_cmdline_enter()
    --         set wildcharm=<Tab>
    --         cmap <expr> <Tab> wilder#in_context() ? wilder#next() : "\<Tab>"
    --         cmap <expr> <S-Tab> wilder#in_context() ? wilder#previous() : "\<S-Tab>"
    --         call wilder#set_option('modes', ['/', '?', ':'])
    --         call wilder#set_option('renderer', wilder#popupmenu_renderer({ 'highlighter': wilder#basic_highlighter(), }))
    --         ]])
    --     end
    -- },
    { "nvim-telescope/telescope-media-files.nvim" },
    -- {
    --     "folke/lsp-colors.nvim",
    --     event = "BufRead",
    -- },
    -- {
    --     dir = "~/qpilot-nvim-v0.3",
    --     event = "VeryLazy",
    --     config = function()
    --         require("qpilot").setup()
    --     end,
    --     dependencies = {
    --         "MunifTanjim/nui.nvim",
    --         "nvim-lua/plenary.nvim",
    --         "nvim-telescope/telescope.nvim"
    --     }
    -- },
}

-- require("symbols-outline").setup()

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--     { "FileType", "cpp", "set tags+=~/cpp_tags" },
--     { "BufReadPost", "*", "if line(\".\") <= 1 && line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif" },
-- }
vim.cmd([[
    autocmd FileType cpp set tags+=~/cpp_tags
    autocmd BufReadPost * if line(".") <= 1 && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
]])

function _G.__run_current_file()
    local head, tail = ":!", ""
    if vim.fn.exists(":TermExec") then
        head, tail = ":TermExec cmd='", "'<cr>ToggleTerm"
    end
    local cs = {
        vim = ":source %",
        sh = head .. "bash %" .. tail,
        zsh = head .. "zsh %" .. tail,
        perl = head .. "perl %" .. tail,
        python = head .. "python3 %" .. tail,
        ruby = head .. "ruby %" .. tail,
        javascript = head .. "node %" .. tail,
        -- markdown = ":MarkdownPreview",
        -- java = head .. "java -cp " .. string.gsub(string.gsub(vim.fn.expand("%:r", nil, nil), 'src/main/java/', 'target/classes '), 'src/test/java/', 'target/classes ') .. tail,
        java = head .. "java -cp " .. string.gsub(string.gsub(vim.fn.expand("%:r"), 'src/main/java/', 'target/classes '), 'src/test/java/', 'target/classes ') .. tail,
        html = ":!open %",
    }
    if vim.fn.exists(":MarkdownPreview") then
        cs.markdown = ":MarkdownPreview"
    elseif vim.fn.exists(":Xmark") then
        cs.markdown = ":Xmark"
    end
    local ft = vim.api.nvim_buf_get_option(0, "filetype")
    if cs[ft] ~= nil then
        vim.cmd(cs[ft])
    else
        print("not supported filetype(" .. ft .. "), supported filetype:")
        for k, _ in pairs(cs) do
            print("  " .. k)
        end
    end
end

-- Additional Leader bindings for WhichKey
lvim.builtin.which_key.mappings["<TAB>"] = { "<c-^>", "Switch Last Files" }
lvim.builtin.which_key.mappings[";"] = { ":%s/\\<<c-r><c-w>\\>//<left>", "Replace Word", silent = false }
lvim.builtin.which_key.mappings["；"] = lvim.builtin.which_key.mappings[";"]
lvim.builtin.which_key.mappings["q"] = { "<cmd>qa<CR>", "Quit" }
lvim.builtin.which_key.mappings["v"] = { "<cmd>e ~/.config/lvim/config.lua<cr>", "Open config.lua" }
-- lvim.builtin.which_key.mappings["o"] = { "<cmd>SymbolsOutline<CR>", "Symbols Outline" }
lvim.builtin.which_key.mappings["o"] = { "<cmd>AerialToggle<CR>", "Open or close the aerial window" }
lvim.builtin.which_key.mappings["n"] = { "<cmd>AerialNavToggle<CR>", "Open or close the aerial nav window" }
lvim.builtin.which_key.mappings["j"] = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" }
lvim.builtin.which_key.mappings["k"] = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" }
lvim.builtin.which_key.mappings["sw"] = { ":lua require('telescope.builtin').grep_string({search='<c-r><c-w>'})<cr>", "Grep Current Word" }
lvim.builtin.which_key.mappings["ss"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" }
lvim.builtin.which_key.mappings["sS"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" }
lvim.builtin.which_key.mappings["sl"] = { "<cmd>Telescope resume<cr>", "Last Search" }
lvim.builtin.which_key.mappings["r"] = { ":lua _G.__run_current_file()<CR>", "Run Current File" }
lvim.builtin.which_key.mappings["Tu"] = { ":TSUpdate<CR>", "Update" }
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
lvim.builtin.which_key.mappings["P"] = {
    name = "Qpilot",
    c = { "<cmd>QPCHAT<cr>", "open a qpilot chat window" },
    a = { "<cmd>QPCHATAS<cr>", "Awesome ChatGPT Prompts" },
    p = { "<cmd>QPCODE<cr>", "complete code" },
}
lvim.builtin.which_key.vmappings["<leader>"] = lvim.builtin.which_key.mappings["<leader>"]
-- Bind <leader>y to forward last-yanked text to Clipper
lvim.builtin.which_key.mappings["y"] = { ":call system('nc -c localhost 8377', @0)<cr>", "send last-yanked text to clipper" }

require('lspconfig').lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false, -- THIS IS THE IMPORTANT LINE TO ADD
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
