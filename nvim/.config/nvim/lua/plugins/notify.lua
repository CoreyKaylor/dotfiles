return {
  'rcarriga/nvim-notify',
  priority = 999, -- Load early to replace vim.notify
  lazy = false,
  config = function()
    local notify = require('notify')
    
    notify.setup({
      -- Animation style
      stages = 'fade_in_slide_out',
      
      -- Timeout for notifications (3 seconds)
      timeout = 3000,
      
      -- Background colour (use 'Normal' highlight group background)
      background_colour = 'Normal',
      
      -- Icons for different log levels
      icons = {
        ERROR = '',
        WARN = '',
        INFO = '',
        DEBUG = '',
        TRACE = '✎',
      },
      
      -- Minimum width and maximum width
      minimum_width = 50,
      maximum_width = 80,
      
      -- Level to display (show all levels)
      level = 'trace',
      
      -- Position notifications on screen
      -- Options: 'top_left', 'top_right', 'bottom_left', 'bottom_right'
      position = 'top_right',
      
      -- Render function (use default compact style)
      render = 'compact',
      
      -- Time format for timestamps
      time_formats = {
        notification_history = '%FT%T',
        notification = '%T',
      },
      
      -- Top down or bottom up notification order
      top_down = true,
      
      -- Maximum number of notifications to show at once
      max_open = 5,
      
      -- Notifications may contain markdown-like text. Keep these buffers plain
      -- so broken markdown parsers cannot crash the decoration provider.
      on_open = function(win)
        local bufnr = vim.api.nvim_win_get_buf(win)
        vim.bo[bufnr].filetype = 'text'
        pcall(vim.treesitter.stop, bufnr)
      end,
      on_close = nil,
    })
    
    -- Replace default vim.notify with nvim-notify
    vim.notify = notify
    
    -- Integration with telescope for notification history
    pcall(function()
      require('telescope').load_extension('notify')
    end)
  end,
  dependencies = {
    -- Optional telescope integration
    {
      'nvim-telescope/telescope.nvim',
      optional = true,
    }
  },
}
