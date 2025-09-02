return {
  'nvim-telescope/telescope.nvim', tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope find w/ripgrep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope find buffers" },
    { "<leader>fh", "<cmd>Telescope buffers<cr>", desc = "Telescope help tags" },
  }
}
