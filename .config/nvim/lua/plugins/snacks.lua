local uv = vim.uv or vim.loop

local function in_zellij()
  return vim.env.ZELLIJ ~= nil or vim.env.ZELLIJ_SESSION_NAME ~= nil
end

local function in_tmux()
  return vim.env.TMUX ~= nil
end

local function is_remote_session()
  return vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
end

local function can_open_with_macos()
  return not is_remote_session()
    and uv.os_uname().sysname == "Darwin"
    and vim.fn.executable("open") == 1
end

local function in_ghostty()
  -- 环境变量可能因 zellij session 复用而过时，
  -- 额外检查 TERM 是否包含 ghostty
  if vim.env.TERM_PROGRAM == "ghostty" or vim.env.GHOSTTY_RESOURCES_DIR ~= nil then
    return true
  end
  if vim.env.TERM and vim.env.TERM:find("ghostty") then
    return true
  end
  return false
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
    return require("snacks.picker.preview").file(ctx)
  end

  local width = math.max(10, vim.api.nvim_win_get_width(ctx.win) - 2)
  local height = math.max(5, vim.api.nvim_win_get_height(ctx.win) - 2)
  local source = preview_source(path, width, height)
  if not source then
    return require("snacks.picker.preview").file(ctx)
  end

  -- Ghostty + Zellij: zellij 不支持图形协议透传，chafa 太慢且模糊。
  -- 本地 macOS 可按 gx 用 Quick Look 预览；远程只显示文件信息。
  if in_ghostty() then
    local buf = ctx.preview:scratch()
    ctx.preview:set_title(vim.fn.fnamemodify(path, ":t"))
    vim.bo[buf].modifiable = true
    vim.bo[buf].filetype = "markdown"
    local stat = (vim.uv or vim.loop).fs_stat(path)
    local size = stat and string.format("%.1f KB", stat.size / 1024) or "unknown"
    local lines = {
      "# " .. vim.fn.fnamemodify(path, ":t"),
      "",
      "- **path**: `" .. path .. "`",
      "- **size**: " .. size,
      "",
      "_zellij does not support image passthrough_",
      "",
    }
    if can_open_with_macos() then
      table.insert(lines, "Press `gx` to open with Quick Look")
    else
      table.insert(lines, "Quick Look is disabled outside local macOS sessions")
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    if can_open_with_macos() then
      vim.keymap.set("n", "gx", function()
        vim.fn.jobstart({ "open", path }, { detach = true })
      end, { buffer = buf, desc = "Open image with Quick Look" })
    end
    return
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

local function git_diff_preview_size(ctx)
  local width = math.max(40, vim.api.nvim_win_get_width(ctx.win) - 2)
  local height = math.max(10, vim.api.nvim_win_get_height(ctx.win) - 2)
  return width, height
end

local function delta_diff_cmd(width)
  return {
    "delta",
    "--" .. vim.o.background,
    "--paging=never",
    "--side-by-side",
    "--line-numbers",
    "--navigate",
    "--line-fill-method=spaces",
    "--width=" .. tostring(width),
  }
end

local function git_diff_preview(ctx)
  local width, height = git_diff_preview_size(ctx)
  local preview = require("snacks.picker.preview")
  return preview.cmd(delta_diff_cmd(width), ctx, {
    input = ctx.item.diff or "",
    env = {
      COLUMNS = tostring(width),
      LINES = tostring(height),
    },
  })
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
        -- zellij 不支持 kitty 图形协议透传，必须禁用原生 image
        enabled = not in_zellij(),
      })
      opts.picker = opts.picker or {}
      opts.picker.layouts = vim.tbl_deep_extend("force", opts.picker.layouts or {}, {
        git_diff_wide = {
          layout = {
            box = "horizontal",
            width = 0.92,
            min_width = 160,
            height = 0.9,
            {
              box = "vertical",
              border = true,
              title = "{title} {live} {flags}",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
            { win = "preview", title = "{preview}", border = true, width = 0.70 },
          },
        },
      })
      opts.picker.sources = vim.tbl_deep_extend("force", opts.picker.sources or {}, {
        files = {
          hidden = true,
        },
        git_diff = {
          layout = { preset = "git_diff_wide" },
          preview = git_diff_preview,
          win = {
            preview = {
              minimal = true,
            },
          },
        },
      })
      opts.picker.previewers = vim.tbl_deep_extend("force", opts.picker.previewers or {}, {
        diff = {
          style = "terminal",
          cmd = delta_diff_cmd(120),
        },
        git = {
          args = {
            "-c",
            "core.pager=delta",
            "-c",
            "delta.side-by-side=true",
            "-c",
            "delta.line-numbers=true",
            "-c",
            "delta.navigate=true",
            "-c",
            "delta.line-fill-method=spaces",
          },
        },
      })

      if in_zellij() then
        opts.picker.preview = zellij_image_preview
        return opts
      end

      if in_tmux() then
        opts.picker.preview = tmux_image_preview
      end

      return opts
    end,
  },
}
