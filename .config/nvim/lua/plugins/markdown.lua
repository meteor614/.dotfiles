local function markdownlint_parser_without_line_length(output, bufnr)
  local diagnostics = require("lint.parser").from_errorformat("stdin:%l:%c %m,stdin:%l %m", {
    source = "markdownlint",
    severity = vim.diagnostic.severity.WARN,
  })(output, bufnr) or {}

  -- Keep markdownlint enabled for Markdown, but ignore MD013 and MD060 warnings.
  return vim.tbl_filter(function(diag)
    if type(diag.message) ~= "string" then
      return true
    end
    return not diag.message:match("MD013/line%-length") and not diag.message:match("MD060")
  end, diagnostics)
end

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters["markdownlint-cli2"] = vim.tbl_deep_extend(
        "force",
        opts.linters["markdownlint-cli2"] or {},
        {
          parser = markdownlint_parser_without_line_length,
        }
      )
    end,
  },
}
