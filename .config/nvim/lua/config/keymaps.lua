-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local silent = { silent = true }
local nosilent = { silent = false }

map("n", ";", ":", nosilent)
map("v", ";", ":", nosilent)
map("n", "：", ":", nosilent)
map("v", "：", ":", nosilent)
map("n", "、", "/", nosilent)
map("n", "？", "?", nosilent)
map("n", "。", ".", nosilent)
map("n", "【【", "[[", nosilent)
map("n", "】】", "]]", nosilent)

--map("n", "n", "nzz", silent)
--map("n", "N", "Nzz", silent)
map("n", "*", "*zz", silent)
map("n", "#", "#zz", silent)
map("n", "g*", "g*zz", silent)
map("n", "g;", "g;zz", silent)
map("n", "g,", "g,zz", silent)

map("i", "<C-s>", "<C-O>:update<cr>", nosilent)
map("n", "<C-s>", ":update<cr>", nosilent)

map("i", "<C-h>", "<C-o>h", nosilent)
map("i", "<C-l>", "<C-o>l", nosilent)
map("i", "<C-^>", "<C-o><C-^>", nosilent)

--map("n", "<c-j>", "15gj", nosilent)
--map("n", "<c-k>", "15gk", nosilent)
--map("v", "<c-j>", "15gj", nosilent)
--map("v", "<c-k>", "15gk", nosilent)

map("c", "<c-a>", "<home>", nosilent)
map("c", "<c-e>", "<end>", nosilent)

map("", "-", ":m+<cr>", silent)
map("", "<c-_>", ":m-2<cr>", silent)
map("v", "-", ":m '>+1<cr>gv=gv", silent)
map("v", "<c-_>", ":m '>-2<cr>gv=gv", silent)

map("v", "p", '"0p', silent)
map("v", "P", '"0P', silent)

map("n", "zc", "za", silent)
map("n", "zo", "za", silent)
map("n", "zr", "zR", silent)

map("t", "<esc>", "<c-\\><c-n>", nosilent)
map("t", "<c-w>", "<c-\\><c-n><c-w>", nosilent)

map("v", "<", "<gv", silent)
map("v", ">", ">gv", silent)

map("n", "<leader>o", "<leader>cs", { remap = true, silent = true })
map("v", "<leader>/", "gc", { remap = true, silent = true })

map("n", "<C-p>", require("lazyvim.util").pick("files"), silent)

map("n", "<Tab>", ":bnext<CR>", nosilent)
map("n", "<S-Tab>", ":bprevious<CR>", nosilent)
