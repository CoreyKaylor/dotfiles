return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").jump({ search = { forward = false } }) end, desc = "Flash Backward" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter() end, desc = "Treesitter Flash" },
    { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
  opts = {
    -- Labels to use for jump targets
    labels = "asdfghjklqwertyuiopzxcvbnm",
    
    -- Search configuration
    search = {
      -- Search mode. Exact is case-sensitive, search ignores case
      mode = "exact", -- exact | search | fuzzy
      -- When search.incremental is enabled, flash will show matches as you type
      incremental = true,
      -- Pattern to use for search
      exclude = {
        "notify",
        "cmp_menu",
        "noice",
        "flash_prompt",
        function(win)
          -- Exclude non-focusable windows
          return not vim.api.nvim_win_get_config(win).focusable
        end,
      },
      -- Trigger mode for auto jump. Always for jumping immediately when there's only one match
      trigger = "",
      -- Maximum number of matches to show  
      max_length = false, -- no limit
    },
    
    -- Jump configuration
    jump = {
      -- Save location in jumplist
      jumplist = true,
      -- Jump position
      pos = "start", -- start | end | range
      -- Add pattern to search history
      history = false,
      -- Clear highlight after jump
      register = false,
      -- Automatically jump when there is only one match
      nohlsearch = false,
      -- Wrap around file edges
      wrap = true,
      -- Show matches in non-current windows
      multi_window = true,
      -- Use default keymaps
      inclusive = nil, -- nil (default), true or false
      -- Smart offset jumps to the beginning of the line for better ergonomics
      offset = nil, -- nil (default) or function
    },
    
    -- Label configuration
    label = {
      -- Show labels on top of matches
      uppercase = true,
      -- Add extra labels if needed  
      exclude = "",
      -- Reuse labels across all matches
      reuse = "lowercase",
      -- Show distance to target
      distance = true,
      -- Minimum pattern length to show labels
      min_pattern_length = 0,
      -- Position of the label
      style = "overlay", -- overlay | eol | inline
      -- Show the label after the match
      after = true,
      -- Show the label before the match  
      before = false,
      -- Add a label to the first match
      rainbow = {
        enabled = false,
        -- Number between 1 and 9
        shade = 5,
      },
    },
    
    -- Highlight configuration  
    highlight = {
      -- Show a backdrop behind matches
      backdrop = true,
      -- Highlight the search matches
      matches = true,
      -- Extmark priority
      priority = 5000,
      -- Highlight groups
      groups = {
        match = "FlashMatch",
        current = "FlashCurrent", 
        backdrop = "FlashBackdrop",
        label = "FlashLabel"
      },
    },
    
    -- Action to perform when picking a label
    action = nil, -- function(match, state) end
    
    -- Pattern to use for matching
    pattern = "",
    
    -- Don't continue jumping after the first match
    continue = false,
    
    -- Set to false to disable the default config
    config = nil, -- function(opts) end
    
    -- Character to use for prompts
    prompt = {
      enabled = true,
      prefix = { { "⚡", "FlashPromptIcon" } },
      win_config = {
        relative = "editor",
        width = 1, -- when <=1 it's a percentage of the editor width
        height = 1,
        row = -1, -- when negative it's an offset from the bottom  
        col = 0, -- when negative it's an offset from the right
        zindex = 1000,
      },
    },
    
    -- Mode configurations
    modes = {
      -- Options used when flash is activated through `f`, `F`, `t`, `T`, `;` and `,` keys
      char = {
        enabled = true,
        -- dynamic configuration for ftFT motions
        config = function(opts)
          -- Autohide flash when in operator-pending mode
          opts.autohide = vim.fn.mode(true):find("o") and vim.v.operator == "y"
          
          -- disable jump labels when not after an operator  
          opts.jump_labels = opts.jump_labels and vim.v.count == 0 and vim.fn.reg_executing() == "" and vim.fn.reg_recording() == ""
          
          -- Show jump labels only when there are multiple matches
          if opts.jump_labels then
            opts.label.exclude = "hjkliardc"
          end
        end,
        -- Hide after timeout when char is not found
        autohide = false,
        -- Show jump labels
        jump_labels = false,
        -- Enable multi-line f, F, t, T
        multi_line = true,
        -- Show labels after or before the match
        label = { after = { 0, 1 } },
        -- character to use for the label
        keys = { "f", "F", "t", "T", ";", "," },
        ---@type number | fun(win: number): number 
        char_actions = function(motion)
          return {
            [motion:lower()] = "next",
            [motion:upper()] = "prev",  
            [";"] = "next",
            [","] = "prev",
          }
        end,
        -- Set to `false` to disable
        search = { wrap = false },
        -- highlight matches
        highlight = { backdrop = false },
        -- Automatically jump when there is only one match
        jump = { register = false },
      },
      
      -- Options used for `/` and `?`
      search = {
        -- When enabled, flash will be triggered during regular search with `/` and `?`
        -- This creates a more intrusive experience, so disabled by default
        enabled = false,
        highlight = { backdrop = false },  
        jump = { history = true, register = true, nohlsearch = true },
        search = {
          -- forward will be automatically set to the search direction
          -- mode is always set to `search`
          -- incremental is set to `true`
        },
      },
      
      -- Options used for Treesitter selections  
      treesitter = {
        labels = "abcdefghijklmnopqrstuvwxyz",
        jump = { pos = "range" },
        search = { incremental = false },
        label = { before = true, after = true, style = "inline" },
        highlight = {
          backdrop = false,
          matches = false,
        },
      },
      
      -- Treesitter search
      treesitter_search = {
        jump = { pos = "range" },
        search = { multi_window = true, wrap = true, incremental = false },
        remote_op = { restore = true },
        label = { before = true, after = true, style = "inline" },
      },
      
      -- Options used for remote flash
      remote = {
        remote_op = { restore = true, motion = true },
      },
    },
    
    -- Configuration for f, F, t, T, ; and , keys
    char = {
      jump_labels = false,
    },
  },
  
  config = function(_, opts)
    require("flash").setup(opts)
    
    -- Create user commands for convenience
    vim.api.nvim_create_user_command('FlashJump', function()
      require("flash").jump()
    end, { desc = 'Flash jump to location' })
    
    vim.api.nvim_create_user_command('FlashTreesitter', function()  
      require("flash").treesitter()
    end, { desc = 'Flash jump using Treesitter' })
    
    vim.api.nvim_create_user_command('FlashRemote', function()
      require("flash").remote()
    end, { desc = 'Flash remote operation' })
  end,
}