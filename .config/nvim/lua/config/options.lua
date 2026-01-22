-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.cmd([[
  cab Qa qa
  cab W w
  cab Wq wq
  cab Wa wa
  cab X x
]])

vim.opt.shortmess:append("atI")

vim.opt.errorbells = false
vim.opt.visualbell = false

vim.opt.wrap = true
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.cinoptions = ":0g0"
vim.opt.smarttab = true
vim.opt.shiftround = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.fileencodings = {
  "ucs-bom",
  "utf-8",
  "cp936",
  "gb18030",
  "big5",
  "euc-jp",
  "euc-kr",
  "latin1",
}

vim.opt.gdefault = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.fileignorecase = true
vim.opt.showcmd = true

vim.opt.ruler = true
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 300

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.mouse = "a"
vim.opt.mousemodel = "popup_setpos"

vim.opt.undolevels = 1000

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 100

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.helplang = "cn"
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.virtualedit = "block"
vim.opt.wildmenu = true
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.title = true
vim.opt.autoread = true
vim.opt.clipboard = { "unnamedplus", "unnamed" }
vim.opt.history = 1000
vim.opt.maxmempattern = 2000000
vim.opt.pumheight = 50
vim.opt.timeoutlen = 100
vim.opt.inccommand = "split"

vim.g.autoformat = false
