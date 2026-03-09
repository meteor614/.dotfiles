return {
  "folke/persistence.nvim",
  keys = {
    { "<leader>qs", false },
    { "<leader>qS", false },
    { "<leader>ql", false },
    { "<leader>qd", false },
    { "<leader>Qs", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>QS", function() require("persistence").select() end, desc = "Select Session" },
    { "<leader>Ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>Qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  },
}
