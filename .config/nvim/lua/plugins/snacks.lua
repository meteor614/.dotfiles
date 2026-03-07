local uv = vim.uv or vim.loop
local preview_state = {
  pane_id = nil,
  source = nil,
}

local function in_zellij()
  return vim.env.ZELLIJ ~= nil or vim.env.ZELLIJ_SESSION_NAME ~= nil
end

local function in_tmux()
  return vim.env.TMUX ~= nil
end

local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
end

local function cache_key(path, suffix)
  local stat = uv.fs_stat(path) or {}
  local mtime = stat.mtime and (stat.mtime.sec or stat.mtime) or 0
  return vim.fn.sha256(table.concat({
    path,
    tostring(stat.size or 0),
    tostring(mtime),
    suffix,
  }, ":"))
end

local function run(cmd)
  vim.fn.system(cmd)
  return vim.v.shell_error == 0
end

local function cache_file()
  return vim.fn.stdpath("cache") .. "/snacks-wezterm-preview-pane"
end

local function read_pane_id()
  if preview_state.pane_id then
    return preview_state.pane_id
  end
  local path = cache_file()
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  local lines = vim.fn.readfile(path)
  local pane_id = tonumber(lines[1])
  preview_state.pane_id = pane_id
  return pane_id
end

local function write_pane_id(pane_id)
  preview_state.pane_id = pane_id
  vim.fn.writefile({ tostring(pane_id) }, cache_file())
end

local function clear_pane_id()
  preview_state.pane_id = nil
  preview_state.source = nil
  local path = cache_file()
  if vim.fn.filereadable(path) == 1 then
    vim.fn.delete(path)
  end
end

local function pane_exists(pane_id)
  if not pane_id then
    return false
  end
  local out = vim.fn.system({ "wezterm", "cli", "list", "--format", "json" })
  if vim.v.shell_error ~= 0 then
    return false
  end
  local ok, panes = pcall(vim.json.decode, out)
  if not ok or type(panes) ~= "table" then
    return false
  end
  for _, pane in ipairs(panes) do
    if tonumber(pane.pane_id) == tonumber(pane_id) then
      return true
    end
  end
  return false
end

local function can_use_wezterm_preview()
  return in_zellij() and vim.env.WEZTERM_PANE ~= nil and vim.fn.executable("wezterm") == 1
end

local function current_wezterm_pane_id()
  return tonumber(vim.env.WEZTERM_PANE)
end

local function focus_wezterm_pane(pane_id)
  if not pane_id then
    return false
  end

  vim.fn.system({
    "wezterm",
    "cli",
    "activate-pane",
    "--pane-id",
    tostring(pane_id),
  })
  return vim.v.shell_error == 0
end

local function ensure_wezterm_preview_pane(cwd)
  local pane_id = read_pane_id()
  if pane_exists(pane_id) then
    return pane_id
  end

  local source_pane_id = current_wezterm_pane_id()
  local cmd = {
    "wezterm",
    "cli",
    "split-pane",
  }
  if source_pane_id then
    vim.list_extend(cmd, {
      "--pane-id",
      tostring(source_pane_id),
    })
  end
  vim.list_extend(cmd, {
    "--right",
    "--percent",
    "35",
    "--cwd",
    cwd or vim.fn.getcwd(),
    "zsh",
    "-i",
  })
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return nil
  end

  pane_id = tonumber(vim.trim(out))
  if pane_id then
    write_pane_id(pane_id)
    focus_wezterm_pane(source_pane_id)
    vim.wait(150)
  end
  return pane_id
end

local function wezterm_send(pane_id, text)
  vim.fn.system({
    "wezterm",
    "cli",
    "send-text",
    "--pane-id",
    tostring(pane_id),
    "--no-paste",
    text,
  })
  return vim.v.shell_error == 0
end

local function clear_wezterm_preview()
  local pane_id = read_pane_id()
  if not pane_exists(pane_id) then
    clear_pane_id()
    return
  end
  wezterm_send(pane_id, "\003clear\n")
  preview_state.source = nil
end

local function close_wezterm_preview()
  local pane_id = read_pane_id()
  if pane_exists(pane_id) then
    vim.fn.system({ "wezterm", "cli", "kill-pane", "--pane-id", tostring(pane_id) })
  end
  clear_pane_id()
end

local function renderer()
  if vim.fn.executable("chafa") == 1 then
    return "chafa"
  elseif vim.fn.executable("viu") == 1 then
    return "viu"
  end
end

local function has_image_converter()
  return vim.fn.executable("magick") == 1 or vim.fn.executable("convert") == 1
end

local function render_png(path, out, width, height)
  if vim.fn.executable("magick") == 0 then
    return nil
  end

  local px_w = math.max(width * 12, 240)
  local px_h = math.max(height * 24, 240)
  local ok = run({
    "magick",
    path .. "[0]",
    "-auto-orient",
    "-thumbnail",
    ("%dx%d>"):format(px_w, px_h),
    out,
  })
  return ok and uv.fs_stat(out) and out or nil
end

local function render_pdf(path, out, width, height)
  local px_w = math.max(width * 12, 240)
  local px_h = math.max(height * 24, 240)
  local prefix = out:gsub("%.png$", "")
  local scale_to = math.max(px_w, px_h)

  local ok = run({
    "pdftoppm",
    "-q",
    "-f",
    "1",
    "-l",
    "1",
    "-singlefile",
    "-png",
    "-scale-to",
    tostring(scale_to),
    path,
    prefix,
  })
  if ok and uv.fs_stat(out) then
    return out
  end

  return render_png(path, out, width, height)
end

local function preview_source(path, width, height)
  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  local cache_dir = vim.fn.stdpath("cache") .. "/snacks-zellij-preview"
  ensure_dir(cache_dir)

  if ext == "pdf" then
    local out = cache_dir .. "/" .. cache_key(path, ("pdf:v2:%d:%d"):format(width, height)) .. ".png"
    return uv.fs_stat(out) and out or render_pdf(path, out, width, height)
  end

  if vim.tbl_contains({ "heic", "avif", "tiff", "svg", "icns" }, ext) then
    local out = cache_dir .. "/" .. cache_key(path, ("img:%d:%d"):format(width, height)) .. ".png"
    return uv.fs_stat(out) and out or render_png(path, out, width, height)
  end

  return path
end

local function render_terminal_image_preview(ctx, path, source)
  local buf = ctx.preview:scratch()
  ctx.preview:set_title(ctx.item.title or vim.fn.fnamemodify(path, ":t"))
  ctx.preview:minimal()
  local width = math.max(10, vim.api.nvim_win_get_width(ctx.win) - 2)
  local height = math.max(5, vim.api.nvim_win_get_height(ctx.win) - 2)

  local render = renderer()
  if not render then
    return require("snacks.picker.preview").file(ctx)
  end

  local cmd = render == "chafa" and {
    "chafa",
    "--probe=off",
    "--format",
    "symbols",
    "--colors",
    "full",
    "--animate",
    "off",
    "--optimize",
    "9",
    "--work",
    "9",
    "--preprocess",
    "on",
    "--polite",
    "on",
    "--size",
    ("%dx%d"):format(width, height),
    source,
  } or {
    "viu",
    "-b",
    "--static",
    "--width",
    tostring(width),
    "--height",
    tostring(height),
    source,
  }

  require("snacks.util.job").new(buf, cmd, {
    term = true,
    pty = true,
    cwd = ctx.item.cwd or ctx.picker.opts.cwd,
  })
end

local function zellij_image_preview(ctx)
  local path = Snacks.picker.util.path(ctx.item)
  if not path or not Snacks.image.supports_file(path) then
    if can_use_wezterm_preview() then
      close_wezterm_preview()
    end
    return require("snacks.picker.preview").file(ctx)
  end

  local width = math.max(10, vim.api.nvim_win_get_width(ctx.win) - 2)
  local height = math.max(5, vim.api.nvim_win_get_height(ctx.win) - 2)
  local source = preview_source(path, width, height)
  if not source then
    if can_use_wezterm_preview() then
      close_wezterm_preview()
    end
    return require("snacks.picker.preview").file(ctx)
  end

  if can_use_wezterm_preview() then
    local pane_id = ensure_wezterm_preview_pane(ctx.item.cwd or ctx.picker.opts.cwd)
    if pane_id then
      local buf = ctx.preview:scratch()
      local quoted = vim.fn.shellescape(source)
      if preview_state.source ~= source then
        wezterm_send(pane_id, "\003clear\nwezterm imgcat --width 100% --height 100% " .. quoted .. "\n")
        preview_state.source = source
      end
      vim.bo[buf].modifiable = true
      vim.bo[buf].filetype = "markdown"
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# WezTerm Preview",
        "",
        "- high-quality preview is shown in the right-side WezTerm pane",
        "- current file: `" .. path .. "`",
      })
      vim.bo[buf].modifiable = false
      vim.bo[buf].modified = false
      return
    end
  end

  return render_terminal_image_preview(ctx, path, source)
end

local function tmux_image_preview(ctx)
  local path = Snacks.picker.util.path(ctx.item)
  if not path or not Snacks.image.supports_file(path) then
    return require("snacks.picker.preview").file(ctx)
  end

  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  if ext == "png" or has_image_converter() then
    return require("snacks.picker.preview").image(ctx)
  end

  local width = math.max(10, vim.api.nvim_win_get_width(ctx.win) - 2)
  local height = math.max(5, vim.api.nvim_win_get_height(ctx.win) - 2)
  local source = preview_source(path, width, height)
  if not source then
    return require("snacks.picker.preview").file(ctx)
  end

  return render_terminal_image_preview(ctx, path, source)
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>/", false },
    },
    opts = function(_, opts)
      opts = opts or {}
      opts.image = vim.tbl_deep_extend("force", opts.image or {}, {
        enabled = not in_zellij(),
      })

      if in_zellij() then
        opts.picker = opts.picker or {}
        local on_close = opts.picker.on_close
        opts.picker.on_close = function(picker)
          close_wezterm_preview()
          if on_close then
            on_close(picker)
          end
        end
        opts.picker.preview = zellij_image_preview

        return opts
      end

      if in_tmux() then
        opts.picker = opts.picker or {}
        opts.picker.preview = tmux_image_preview
      end

      return opts
    end,
    init = function()
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = vim.api.nvim_create_augroup("snacks_wezterm_preview_cleanup", { clear = true }),
        callback = function()
          local pane_id = read_pane_id()
          if pane_exists(pane_id) then
            vim.fn.system({ "wezterm", "cli", "kill-pane", "--pane-id", tostring(pane_id) })
          end
          clear_pane_id()
        end,
      })
    end,
  },
}
