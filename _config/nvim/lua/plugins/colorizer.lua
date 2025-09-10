return {
  'norcalli/nvim-colorizer.lua',
  ft = { 'html', 'css', 'scss', 'less', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  config = function()
    require('colorizer').setup({
      -- Filetypes to enable colorizer
      '*',
      css = {
        rgb_fn = true,    -- Enable parsing rgb() functions in CSS
        hsl_fn = true,    -- Enable parsing hsl() functions
        css = true,       -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true,    -- Enable parsing CSS functions
      },
      html = {
        mode = 'background', -- Set the display mode for HTML
      },
      -- Exclude certain filetypes
      exclude_ft = { 'markdown' }
    })
  end,
}