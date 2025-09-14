return {
  'mrjones2014/smart-splits.nvim',
  lazy = true,
  keys = {
    -- Window navigation (seamless with tmux if configured)
    { '<C-h>',             function() require('smart-splits').move_cursor_left() end,  desc = 'Move to left window' },
    { '<C-j>',             function() require('smart-splits').move_cursor_down() end,  desc = 'Move to window below' },
    { '<C-k>',             function() require('smart-splits').move_cursor_up() end,    desc = 'Move to window above' },
    { '<C-l>',             function() require('smart-splits').move_cursor_right() end, desc = 'Move to right window' },

    -- Window resizing using hjkl (manual control)
    { '<A-h>',             function() require('smart-splits').resize_left() end,       desc = 'Resize window left' },
    { '<A-j>',             function() require('smart-splits').resize_down() end,       desc = 'Resize window down' },
    { '<A-k>',             function() require('smart-splits').resize_up() end,         desc = 'Resize window up' },
    { '<A-l>',             function() require('smart-splits').resize_right() end,      desc = 'Resize window right' },

    -- Window swapping (move windows around)
    { '<leader><leader>h', function() require('smart-splits').swap_buf_left() end,     desc = 'Swap buffer left' },
    { '<leader><leader>j', function() require('smart-splits').swap_buf_down() end,     desc = 'Swap buffer down' },
    { '<leader><leader>k', function() require('smart-splits').swap_buf_up() end,       desc = 'Swap buffer up' },
    { '<leader><leader>l', function() require('smart-splits').swap_buf_right() end,    desc = 'Swap buffer right' },

    -- Window creation (split creation) - Missing from original implementation
    { '<leader>v',         '<cmd>vsplit<cr>',                                               desc = 'Create vertical split' },
    { '<leader>h',         '<cmd>split<cr>',                                                desc = 'Create horizontal split' },
    { '<leader>-',         '<cmd>split<cr>',                                                desc = 'Create horizontal split (alt)' },
    { '<leader>|',         '<cmd>vsplit<cr>',                                               desc = 'Create vertical split (alt)' },

    -- Auto-resize toggle (F4 as specified in migration plan)
    {
      '<F4>',
      function()
        local splits = require('smart-splits')
        -- Toggle between auto-resize and manual mode
        if vim.g.smart_splits_auto_resize then
          splits.stop_resize_mode()
          vim.g.smart_splits_auto_resize = false
          vim.notify("Smart-splits: Auto-resize disabled", vim.log.levels.INFO)
        else
          splits.start_resize_mode()
          vim.g.smart_splits_auto_resize = true
          vim.notify("Smart-splits: Auto-resize enabled", vim.log.levels.INFO)
        end
      end,
      desc = 'Toggle auto-resize mode'
    },
  },
  config = function()
    require('smart-splits').setup({
      -- Ignored filetypes (won't resize windows)
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

      -- Ignored buffer types
      ignored_buftypes = {
        'terminal',
        'nofile',
        'quickfix',
        'prompt',
      },

      -- When moving cursor between splits left or right,
      -- place the cursor on the closest word boundary
      move_cursor_same_row = true,

      -- Resize mode settings
      resize_mode = {
        -- Enable resize mode for interactive resizing
        quit_key = '<ESC>',
        -- Use hjkl keys for resizing in resize mode
        resize_keys = { 'h', 'j', 'k', 'l' },
        -- Silent notifications
        silent = false,
        -- Hooks for resize mode
        hooks = {
          on_enter = function()
            vim.notify('Entering resize mode (ESC to exit)', vim.log.levels.INFO)
          end,
          on_leave = function()
            vim.notify('Exiting resize mode', vim.log.levels.INFO)
          end,
        },
      },

      -- Default resize amount (can be overridden)
      default_amount = 3,

      -- At edge behavior - what to do when you try to move past the edge
      at_edge = 'stop', -- or 'wrap' to go to opposite side

      -- Cursor follows when swapping buffers
      cursor_follows_swapped_bufs = true,

      -- Log level for debugging (set to 'info' or 'debug' if needed)
      log_level = 'warn',
    })

    -- Initialize auto-resize state
    vim.g.smart_splits_auto_resize = false

    -- Auto-command to handle window events for better UX
    vim.api.nvim_create_autocmd({ 'WinEnter', 'WinNew' }, {
      group = vim.api.nvim_create_augroup('SmartSplitsEnhance', { clear = true }),
      callback = function()
        -- Optional: Add any window-specific enhancements here
        -- For example, highlighting the active window differently
        if vim.g.smart_splits_auto_resize then
          -- If auto-resize is enabled, ensure the current window gets focus behavior
          vim.defer_fn(function()
            -- Optional: Add subtle visual feedback for active window
          end, 10)
        end
      end,
    })
  end,
}

