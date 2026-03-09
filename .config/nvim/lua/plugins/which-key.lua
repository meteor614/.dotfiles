return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    local added_groups = false

    for _, spec in ipairs(opts.spec or {}) do
      if type(spec) == "table" then
        for i = #spec, 1, -1 do
          local item = spec[i]
          if type(item) == "table" and (
            (item[1] == "gs" and item.group == "surround") or
            (item[1] == "<leader>q" and item.group == "quit/session") or
            (item[1] == "<leader>w" and item.group == "windows")
          ) then
            table.remove(spec, i)
          end
        end

        if not added_groups then
          table.insert(spec, {
            "<leader>Q",
            group = "quit/session",
          })
          table.insert(spec, {
            "<leader>W",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          })
          added_groups = true
        end
      end
    end
  end,
}
