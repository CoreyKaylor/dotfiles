return {
  'christoomey/vim-tmux-navigator',
  lazy = false, -- Load immediately for seamless navigation
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<cr>',  desc = 'Navigate left (tmux-aware)' },
    { '<C-j>', '<cmd>TmuxNavigateDown<cr>',  desc = 'Navigate down (tmux-aware)' },
    { '<C-k>', '<cmd>TmuxNavigateUp<cr>',    desc = 'Navigate up (tmux-aware)' },
    { '<C-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate right (tmux-aware)' },
  },
  init = function()
    -- Disable default mappings, we'll set our own
    vim.g.tmux_navigator_no_mappings = 1

    -- Don't save on switch (optional, set to 1 to auto-save)
    vim.g.tmux_navigator_save_on_switch = 0

    -- Disable when zoomed in tmux
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
}
