-- Configure diagnostic display
vim.diagnostic.config({
  -- Show diagnostic messages as virtual text
  virtual_text = {
    prefix = '●', -- Could be '●', '▎', '◦', etc.
    source = "if_many",
    spacing = 2,
  },

  -- Show diagnostic signs in the gutter with custom icons
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "⚠",
      [vim.diagnostic.severity.HINT] = "💡",
      [vim.diagnostic.severity.INFO] = "ℹ",
    },
  },

  -- Underline diagnostics
  underline = true,

  -- Update diagnostics while typing
  update_in_insert = false,

  -- Sort by severity (errors first)
  severity_sort = true,

  -- Floating window config
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
    suffix = '',
  },
})

-- Note: Diagnostic signs are now configured directly in vim.diagnostic.config()
-- above, instead of using the deprecated vim.fn.sign_define() function

-- Keymaps for diagnostic navigation (if not already set elsewhere)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })

