return {
  "maxmx03/solarized.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("solarized").setup({
      transparent = {
        enabled = false,
        pmenu = true,
        normal = true,
        normalfloat = true,
        neotree = true,
        nvimtree = true,
        whichkey = true,
        telescope = true,
        lazy = true,
        mason = true,
      },
      on_highlights = function(colors, colorscheme)
        local groups = {
          -- Customize specific highlight groups if needed
          Comment = { fg = colors.base01, italic = true },
          LineNr = { fg = colors.base01 },
          CursorLineNr = { fg = colors.orange, bold = true },
        }
        return groups
      end,
      on_colors = function(colors, colorscheme)
        -- Customize colors if needed
        return colors
      end,
      palette = "solarized", -- solarized | selenized
      variant = "autumn", -- spring | summer | autumn | winter
      styles = {
        comments = { italic = true },
        functions = { bold = false },
        keywords = { italic = false },
        variables = {},
      },
      plugins = {
        treesitter = true,
        lspconfig = true,
        nvimtree = true,
        telescope = true,
        trouble = true,
        which_key = true,
        mini = true,
        alpha = true,
        neo_tree = true,
        lazy = true,
        render_markdown = true,
        mason = true,
        flash = true,
        gitsigns = true,
        declare_highlight = true,
        bufferline = true,
        cmp = true,
        lualine = true,
        aerial = true,
        indent_blankline = true,
        notify = true,
      },
    })

    -- Set background and colorscheme
    vim.o.background = "light"
    vim.cmd.colorscheme("solarized")
  end,
}