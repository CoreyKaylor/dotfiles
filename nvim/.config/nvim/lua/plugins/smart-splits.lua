-- smart-splits: resize / swap / split helpers.
-- Alt-hjkl resize is owned by herdr-splits inside herdr panes.
local in_herdr = vim.env.HERDR_ENV == '1'

local keys = {
  -- Window swapping (move windows around)
  { '<leader><leader>h', function() require('smart-splits').swap_buf_left() end,  desc = 'Swap buffer left' },
  { '<leader><leader>j', function() require('smart-splits').swap_buf_down() end,  desc = 'Swap buffer down' },
  { '<leader><leader>k', function() require('smart-splits').swap_buf_up() end,    desc = 'Swap buffer up' },
  { '<leader><leader>l', function() require('smart-splits').swap_buf_right() end, desc = 'Swap buffer right' },

  -- Window creation
  { '<leader>v', '<cmd>vsplit<cr>', desc = 'Create vertical split' },
  { '<leader>h', '<cmd>split<cr>',  desc = 'Create horizontal split' },
  { '<leader>-', '<cmd>split<cr>',  desc = 'Create horizontal split (alt)' },
  { '<leader>|', '<cmd>vsplit<cr>', desc = 'Create vertical split (alt)' },

  {
    '<F4>',
    function()
      local splits = require('smart-splits')
      if vim.g.smart_splits_auto_resize then
        splits.stop_resize_mode()
        vim.g.smart_splits_auto_resize = false
        vim.notify('Smart-splits: Auto-resize disabled', vim.log.levels.INFO)
      else
        splits.start_resize_mode()
        vim.g.smart_splits_auto_resize = true
        vim.notify('Smart-splits: Auto-resize enabled', vim.log.levels.INFO)
      end
    end,
    desc = 'Toggle auto-resize mode',
  },
}

if not in_herdr then
  vim.list_extend(keys, {
    { '<A-h>', function() require('smart-splits').resize_left() end,  desc = 'Resize window left' },
    { '<A-j>', function() require('smart-splits').resize_down() end,  desc = 'Resize window down' },
    { '<A-k>', function() require('smart-splits').resize_up() end,    desc = 'Resize window up' },
    { '<A-l>', function() require('smart-splits').resize_right() end, desc = 'Resize window right' },
  })
end

return {
  'mrjones2014/smart-splits.nvim',
  lazy = true,
  keys = keys,
  config = function()
    require('smart-splits').setup({
      multiplexer_integration = nil,

      ignored_filetypes = {
        'NvimTree',
        'neo-tree',
        'aerial',
        'trouble',
        'qf',
        'notify',
        'nofile',
        'quickfix',
      },

      ignored_buftypes = {
        'terminal',
        'nofile',
        'quickfix',
        'prompt',
      },

      move_cursor_same_row = true,

      resize_mode = {
        quit_key = '<ESC>',
        resize_keys = { 'h', 'j', 'k', 'l' },
        silent = false,
        hooks = {
          on_enter = function()
            vim.notify('Entering resize mode (ESC to exit)', vim.log.levels.INFO)
          end,
          on_leave = function()
            vim.notify('Exiting resize mode', vim.log.levels.INFO)
          end,
        },
      },

      default_amount = 3,
      at_edge = 'stop',
      cursor_follows_swapped_bufs = true,
      log_level = 'warn',
    })

    vim.g.smart_splits_auto_resize = false
  end,
}
