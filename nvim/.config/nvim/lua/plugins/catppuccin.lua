return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "latte",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      integrations = {
        aerial = true,
        cmp = true,
        flash = true,
        gitsigns = false,
        lsp_trouble = true,
        native_lsp = {
          enabled = true,
        },
        notify = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
      },
    })

    vim.o.background = "light"
    vim.cmd.colorscheme("catppuccin-latte")
  end,
}
