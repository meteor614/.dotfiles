return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    for _, spec in ipairs(opts.spec or {}) do
      if type(spec) == "table" then
        for i = #spec, 1, -1 do
          local item = spec[i]
          if type(item) == "table" and item[1] == "gs" and item.group == "surround" then
            table.remove(spec, i)
          end
        end
      end
    end
  end,
}
