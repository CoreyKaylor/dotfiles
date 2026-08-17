-- Seamless Ctrl-hjkl between Neovim and tmux.
-- Disabled inside herdr (herdr-splits owns navigation there).
if vim.env.HERDR_ENV == '1' then
  return {}
end

return {
  'christoomey/vim-tmux-navigator',
  lazy = false,
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<cr>',  desc = 'Navigate left (tmux-aware)' },
    { '<C-j>', '<cmd>TmuxNavigateDown<cr>',  desc = 'Navigate down (tmux-aware)' },
    { '<C-k>', '<cmd>TmuxNavigateUp<cr>',    desc = 'Navigate up (tmux-aware)' },
    { '<C-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate right (tmux-aware)' },
  },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
    vim.g.tmux_navigator_save_on_switch = 0
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
}
