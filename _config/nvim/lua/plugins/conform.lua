return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  keys = {
    {
      '<leader>f',
      function()
        -- Force refresh the formatter list before formatting
        local conform = require('conform')
        local result = conform.format({ 
          async = false, 
          lsp_fallback = true, 
          timeout_ms = 3000,
          quiet = false  -- Show errors if formatting fails
        })
        if result then
          vim.notify("Formatted file", vim.log.levels.INFO)
        end
      end,
      desc = 'Format buffer'
    }
  },
  opts = {
    formatters_by_ft = {
      kotlin = { 'ktfmt' },
    },
    format_on_save = { 
      timeout_ms = 500, 
      lsp_fallback = true
    },
    formatters = {
      ktfmt = {
        command = 'ktfmt',
        args = { '--kotlinlang-style', '-' },
        stdin = true,
      },
    },
  },
}