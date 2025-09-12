return { "catppuccin/nvim",
         name = "catppuccin",
         lazy = true,
         priority = 999, -- Lower priority than solarized
         config = function()
           require("catppuccin").setup({
             -- Keep catppuccin available but don't auto-apply
           })
         end,
}
