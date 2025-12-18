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
-- vim.o.foldmethod = "indent"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
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

lvim.autocommands = {
  {
    "FileType",
    {
      pattern = "python",
      callback = function()
        vim.opt_local.foldmethod = "indent"
        vim.opt_local.foldlevel = 99  -- 打开文件时默认不折叠
      end,
    },
  },
}

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
local opts = { silent = true }
local opts_ns = { silent = false }

vim.keymap.set("n", ";", ":", opts_ns)
vim.keymap.set("v", ";", ":", opts_ns)
vim.keymap.set("n", "：", ":", opts_ns)
vim.keymap.set("v", "：", ":", opts_ns)
vim.keymap.set("n", "、", "/", opts_ns)
vim.keymap.set("n", "？", "?", opts_ns)
vim.keymap.set("n", "。", ".", opts_ns)
vim.keymap.set("n", "【【", "[[", opts_ns)
vim.keymap.set("n", "】】", "]]", opts_ns)

 -- Keep search pattern at the center of the screen.
vim.keymap.set("n", "n", "nzz", opts)
vim.keymap.set("n", "N", "Nzz", opts)
vim.keymap.set("n", "*", "*zz", opts)
vim.keymap.set("n", "#", "#zz", opts)
vim.keymap.set("n", "g*", "g*zz", opts)
vim.keymap.set("n", "g;", "g;zz", opts)
vim.keymap.set("n", "g,", "g,zz", opts)

-- 去掉上次搜索高亮
--vim.keymap.set("n", "<leader>/", ":nohls", opts)

-- files
vim.keymap.set("i", "<C-s>", "<C-O>:update<cr>", opts_ns)
vim.keymap.set("n", "<C-s>", ":update<cr>", opts_ns)

-- Navigate buffers (use ]b/[b for buffer navigation)

-- Movement in insert mode
vim.keymap.set("i", "<C-h>", "<C-o>h", opts_ns)
vim.keymap.set("i", "<C-l>", "<C-o>l", opts_ns)
vim.keymap.set("i", "<C-^>", "<C-o><C-^>", opts_ns)

-- jump
vim.keymap.set("n", "<c-j>", "15gj", opts_ns)
vim.keymap.set("n", "<c-k>", "15gk", opts_ns)
vim.keymap.set("v", "<c-j>", "15gj", opts_ns)
vim.keymap.set("v", "<c-k>", "15gk", opts_ns)

-- Quickfix
vim.keymap.set("n", "]q", ":cnext<cr>zz", opts_ns)
vim.keymap.set("n", "[q", ":cprev<cr>zz", opts_ns)
vim.keymap.set("n", "]l", ":lnext<cr>zz", opts_ns)
vim.keymap.set("n", "[l", ":lprev<cr>zz", opts_ns)

-- Buffers
vim.keymap.set("n", "]b", ":bnext<cr>", opts_ns)
vim.keymap.set("n", "[b", ":bprev<cr>", opts_ns)

-- Tabs
vim.keymap.set("n", "]t", ":tabn<cr>", opts_ns)
vim.keymap.set("n", "[t", ":tabp<cr>", opts_ns)

-- CTRL+A moves to start of line in command mode
vim.keymap.set("c", "<c-a>", "<home>", opts_ns)
-- CTRL+E moves to end of line in command mode
vim.keymap.set("c", "<c-e>", "<end>", opts_ns)

-- move current line down
vim.keymap.set("", "-", ":m+<cr>", opts)
-- move current line up
vim.keymap.set("", "<c-_>", ":m-2<cr>", opts)
-- move visual selection down
vim.keymap.set("v", "-", ":m '>+1<cr>gv=gv", opts)
-- move visual selection up
vim.keymap.set("v", "<c-_>", ":m '>-2<cr>gv=gv", opts)

vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts)

vim.keymap.set('v', 'p', '"0p', opts)
vim.keymap.set('v', 'P', '"0P', opts)

-- fold (toggle fold with za)
vim.keymap.set('n', 'zc', 'za', opts)
vim.keymap.set('n', 'zo', 'za', opts)
vim.keymap.set('n', 'zr', 'zR', opts)

-- terminal
vim.keymap.set('t', '<esc>', '<c-\\><c-n>', opts_ns)
vim.keymap.set("t", "<c-w>", "<c-\\><c-n><c-w>", opts_ns)

-- better indenting
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

vim.keymap.set("n", "<c-p>", function() require('telescope.builtin').find_files() end, opts)
vim.keymap.set("n", "<c-t>", '<cmd>exe v:count1 . "ToggleTerm direction=float"<cr>', opts)
vim.keymap.set("t", "<c-t>", '<cmd>exe v:count1 . "ToggleTerm direction=float"<cr>', opts)
vim.keymap.set("n", "<A-i>", "<c-t>", { remap = true, silent = true })
vim.keymap.set("t", "<A-i>", "<c-t>", { remap = true, silent = true })
vim.keymap.set("n", "<A-f>", '<cmd>exe v:count1 . "ToggleTerm direction=float"<cr>', opts)
vim.keymap.set("t", "<A-f>", '<cmd>exe v:count1 . "ToggleTerm direction=float"<cr>', opts)
vim.keymap.set("n", "<A-b>", '<cmd>exe v:count1 . "ToggleTerm size=20 direction=horizontal"<cr>', opts)
vim.keymap.set("t", "<A-b>", '<cmd>exe v:count1 . "ToggleTerm size=20 direction=horizontal"<cr>', opts)
vim.keymap.set("n", "<A-v>", '<cmd>exe v:count1 . "ToggleTerm size=60 direction=vertical"<cr>', opts)
vim.keymap.set("t", "<A-v>", '<cmd>exe v:count1 . "ToggleTerm size=60 direction=vertical"<cr>', opts)

-- disable deprecated message
vim.deprecate = function() end

-- vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
--   if result and result.message and result.message:match('position_encoding') then
--     return  -- 直接丢弃这条消息
--   end
--   return vim.lsp.handlers['window/showMessage'](_, result, ctx)
-- end


if lvim.builtin.alpha then
    lvim.builtin.alpha.active = false
end
lvim.builtin.terminal.active = true
lvim.builtin.which_key.active = true

lvim.builtin.bigfile.config = {
    filesize = 4,
}

-- if lvim.builtin.nvimtree then
--     lvim.builtin.nvimtree.setup.auto_open = 0
--     lvim.builtin.nvimtree.setup.side = "left"
--     lvim.builtin.nvimtree.setup.disable_window_picker = 1
--     lvim.builtin.nvimtree.setup.hide_dotfiles = 0
-- end

-- if you don't want all the parsers change this to a table of the ones you want
if lvim.builtin.treesitter then
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

if lvim.builtin.compe then
    lvim.builtin.compe.autocomplete = true
    lvim.builtin.compe.source.nvim_lua = true
end

if lvim.lazy.opts then
    lvim.lazy.opts.git = {
        timeout = 900,  -- 设置为 15 分钟，默认值可能为 60 秒
        retries = 3,    -- 可选：失败重试次数
        -- url_format = "https://gitclone.com/github.com/%s.git", -- GitHub 国内镜像
    }
end

if lvim.builtin.telescope then
    lvim.builtin.telescope.defaults.initial_mode = "insert"
    lvim.builtin.telescope.defaults.path_display = { "smart" }
    lvim.builtin.telescope.defaults.mappings = lvim.builtin.telescope.defaults.mappings or { i = {}, n = {} }
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

    local image_preview = require("image_preview")
    local image_extensions = { "png", "jpg", "jpeg", "gif", "bmp", "svg", "webp" }
    lvim.builtin.telescope.defaults.preview = {
        mime_hook = function(filepath, bufnr, opts)
            -- 支持的图片格式
            -- local image_extensions = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'svg', 'webp'}
            local ext = vim.fn.fnamemodify(filepath, ":e"):lower()

            if vim.tbl_contains(image_extensions, ext) then
                -- 关键：调用 image_preview 显示图片
                -- 这会直接在 WezTerm 中渲染图像
                image_preview.PreviewImage(filepath)

                -- 阻止 Telescope 默认预览（避免乱码）
                return false
            end

            -- 非图片文件使用默认预览
            return true
        end,

        -- 其他预览优化配置
        filesize_limit = 10,  -- 限制预览文件大小(MB)
        timeout = 200,        -- 预览超时时间(ms)
    }
end

if lvim.builtin.project then
    lvim.builtin.project.patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", ".venv" }
end

require('telescope').load_extension('projects')

if lvim.builtin.nvimtree then
    lvim.builtin.nvimtree.setup.view.width = 40
end

-- generic LSP settings
lvim.lsp.default_keybinds = false
lvim.lsp.installer.setup.automatic_installation.enable = true
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
vim.keymap.set("n", "gl", function() vim.diagnostic.open_float({ border = "single" }) end, opts)
vim.keymap.set("n", "gp", function() require('lsp').PeekDefinition() end, opts)
vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
-- vim.keymap.set("n", "<a-j>", function() vim.diagnostic.goto_next({float = {border = lvim.lsp.popup_border}}) end, opts)
-- vim.keymap.set("n", "<a-k>", function() vim.diagnostic.goto_prev({float = {border = lvim.lsp.popup_border}}) end, opts)
vim.cmd 'command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()'

-- 屏蔽 warning
local original_notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match("multiple different client offset_encodings") then
    return
  end
  original_notify(msg, ...)
end

-- Additional Plugins
lvim.plugins = {
    { "HiPhish/rainbow-delimiters.nvim" },
    {
        'stevearc/aerial.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
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
    },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require("lsp_signature").on_attach()
        end,
        event = "InsertEnter",
    },
    {
        "phaazon/hop.nvim",
        event = "BufRead",
        config = function()
            require("hop").setup()
        end,
    },
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
    { "nvim-telescope/telescope-media-files.nvim" },
    {
        'adelarsq/image_preview.nvim',
        event = 'VeryLazy',
        config = function()
            require("image_preview").setup({
                -- 可选：调整预览窗口大小
                max_width = 512,
                max_height = 512,
            })
        end
    },
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        vim.opt_local.tags:append("~/cpp_tags")
    end,
})

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
        java = head .. "java -cp " .. string.gsub(string.gsub(vim.fn.expand("%:r"), 'src/main/java/', 'target/classes '), 'src/test/java/', 'target/classes ') .. tail,
        html = ":!open %",
    }
    if vim.fn.exists(":MarkdownPreview") then
        cs.markdown = ":MarkdownPreview"
    elseif vim.fn.exists(":Xmark") then
        cs.markdown = ":Xmark"
    end
    local ft = vim.bo[0].filetype
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
-- lvim.builtin.which_key.mappings["y"] = { ":call system('nc -c localhost 8377', @0)<cr>", "send last-yanked text to clipper" }
local clip_cmd = vim.fn.executable('socat') == 1 and 'socat - tcp:localhost:8377' or 'nc -c localhost 8377'
lvim.builtin.which_key.mappings["y"] = { ":call system('" .. clip_cmd .. "', @0)<cr>", "send last-yanked text to clipper" }
lvim.builtin.which_key.setup.plugins.presets.z = true

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
