-- Seamless Ctrl-hjkl / Alt-hjkl between Neovim and herdr panes.
-- Only active inside a herdr-managed pane (HERDR_ENV=1).
if vim.env.HERDR_ENV ~= '1' then
  return {}
end

return {
  'lmilojevicc/herdr-splits.nvim',
  lazy = false,
  config = function()
    require('herdr-splits').setup({
      default_amount = 0.03,
      neovim_amount = 3,
      at_edge = 'stop',
      nav_at_edge = 'stop',
      unzoom_on_nav = true,
      auto_sync_herdr = true,
      move_cursor_same_row = true,
      nav_keys = { left = '<C-h>', down = '<C-j>', up = '<C-k>', right = '<C-l>' },
      resize_keys = { left = '<M-h>', down = '<M-j>', up = '<M-k>', right = '<M-l>' },
      ignored_filetypes = {
        'NvimTree',
        'neo-tree',
        'aerial',
        'Trouble',
        'quickfix',
        'notify',
      },
      ignored_buftypes = {
        'terminal',
        'nofile',
        'quickfix',
        'prompt',
      },
    })
  end,
  keys = {
    { '<C-h>', function() require('herdr-splits').move_cursor_left() end,  desc = 'Navigate left (herdr)' },
    { '<C-j>', function() require('herdr-splits').move_cursor_down() end,  desc = 'Navigate down (herdr)' },
    { '<C-k>', function() require('herdr-splits').move_cursor_up() end,    desc = 'Navigate up (herdr)' },
    { '<C-l>', function() require('herdr-splits').move_cursor_right() end, desc = 'Navigate right (herdr)' },
    { '<M-h>', function() require('herdr-splits').resize_left() end,  desc = 'Resize left (herdr)' },
    { '<M-j>', function() require('herdr-splits').resize_down() end,  desc = 'Resize down (herdr)' },
    { '<M-k>', function() require('herdr-splits').resize_up() end,    desc = 'Resize up (herdr)' },
    { '<M-l>', function() require('herdr-splits').resize_right() end, desc = 'Resize right (herdr)' },
  },
}
