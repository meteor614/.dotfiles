-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
local silent = { silent = true }
local nosilent = { silent = false }

local function with_desc(desc, base)
  return vim.tbl_extend("force", base or {}, { desc = desc })
end

map("n", ";", ":", with_desc("Command-line", nosilent))
map("v", ";", ":", with_desc("Command-line", nosilent))
map("n", "：", ":", with_desc("Command-line (CN)", nosilent))
map("v", "：", ":", with_desc("Command-line (CN)", nosilent))
map("n", "、", "/", with_desc("Search forward (CN)", nosilent))
map("n", "？", "?", with_desc("Search backward (CN)", nosilent))
map("n", "。", ".", with_desc("Repeat last change (CN)", nosilent))
map("n", "【【", "[[", with_desc("Prev section (CN)", nosilent))
map("n", "】】", "]]", with_desc("Next section (CN)", nosilent))

--map("n", "n", "nzz", silent)
--map("n", "N", "Nzz", silent)
map("n", "*", "*zz", with_desc("Search word forward centered", silent))
map("n", "#", "#zz", with_desc("Search word backward centered", silent))
map("n", "g*", "g*zz", with_desc("Search word (partial) centered", silent))
map("n", "g;", "g;zz", with_desc("Next change centered", silent))
map("n", "g,", "g,zz", with_desc("Prev change centered", silent))

map("i", "<C-s>", "<C-O>:update<cr>", with_desc("Save file", nosilent))
map("n", "<C-s>", ":update<cr>", with_desc("Save file", nosilent))

map("i", "<C-h>", "<C-o>h", with_desc("Move left (insert)", nosilent))
map("i", "<C-l>", "<C-o>l", with_desc("Move right (insert)", nosilent))
map("i", "<C-^>", "<C-o><C-^>", with_desc("Switch alternate file (insert)", nosilent))

--map("n", "<c-j>", "15gj", nosilent)
--map("n", "<c-k>", "15gk", nosilent)
--map("v", "<c-j>", "15gj", nosilent)
--map("v", "<c-k>", "15gk", nosilent)

map("c", "<c-a>", "<home>", with_desc("Cmdline start", nosilent))
map("c", "<c-e>", "<end>", with_desc("Cmdline end", nosilent))

map("", "-", ":m+<cr>", with_desc("Move line down", silent))
map("", "<c-_>", ":m-2<cr>", with_desc("Move line up", silent))
map("v", "-", ":m '>+1<cr>gv=gv", with_desc("Move selection down", silent))
map("v", "<c-_>", ":m '>-2<cr>gv=gv", with_desc("Move selection up", silent))

map("v", "p", '"0p', with_desc("Paste without yanking", silent))
map("v", "P", '"0P', with_desc("Paste before without yanking", silent))

map("n", "zc", "za", with_desc("Toggle fold", silent))
map("n", "zo", "za", with_desc("Toggle fold", silent))
map("n", "zr", "zR", with_desc("Open all folds", silent))

-- map("t", "<esc>", "<c-\\><c-n>", with_desc("Exit terminal mode", nosilent))
-- map("t", "<c-w>", "<c-\\><c-n><c-w>", with_desc("Terminal window cmd", nosilent))

map("v", "<", "<gv", with_desc("Indent left", silent))
map("v", ">", ">gv", with_desc("Indent right", silent))

map("n", "<leader>o", "<leader>cs", with_desc("Toggle Outline", { remap = true, silent = true }))
map("v", "<leader>/", "gc", with_desc("Comment selection", { remap = true, silent = true }))
map("n", "<leader>j", function()
  vim.diagnostic.goto_next()
end, with_desc("Next diagnostic", silent))
map("n", "<leader>k", function()
  vim.diagnostic.goto_prev()
end, with_desc("Prev diagnostic", silent))
map("n", "<leader>gj", function()
  require("gitsigns").next_hunk()
end, with_desc("Next git hunk", silent))
map("n", "<leader>gk", function()
  require("gitsigns").prev_hunk()
end, with_desc("Prev git hunk", silent))

map("n", "<C-p>", require("lazyvim.util").pick("files"), with_desc("Find files", silent))

map({ "n", "t" }, "<A-b>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root(), count = 1, win = { position = "bottom" } })
end, with_desc("Terminal (Root Dir, Bottom)", silent))

map({ "n", "t" }, "<A-v>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root(), count = 2, win = { position = "right" } })
end, with_desc("Terminal (Root Dir, Right)", silent))

map("n", "<Tab>", ":bnext<CR>", with_desc("Next buffer", nosilent))
map("n", "<S-Tab>", ":bprevious<CR>", with_desc("Prev buffer", nosilent))
