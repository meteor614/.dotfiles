-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- 高亮复制的内容
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- 保存时删除行尾空格
autocmd("BufWritePre", {
  group = augroup("trim_trailing_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    -- 排除某些文件类型和特殊 buffer
    local exclude_filetypes = { "markdown", "diff" }
    local exclude_buftypes = { "nofile", "prompt", "terminal", "quickfix", "help" }
    if vim.tbl_contains(exclude_filetypes, vim.bo.filetype) then
      return
    end
    if vim.tbl_contains(exclude_buftypes, vim.bo.buftype) then
      return
    end
    if vim.bo.binary or not vim.bo.modifiable or vim.bo.readonly then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keepjumps keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- 当窗口大小改变时自动调整分割窗口
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- 对于特定文件类型设置更短的更新时间和显示光标行
autocmd("FileType", {
  group = augroup("special_filetypes", { clear = true }),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
