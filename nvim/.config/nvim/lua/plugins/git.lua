return {
  -- Neogit - Modern Git interface
  {
    'NeogitOrg/neogit',
    lazy = true,
    cmd = { 'Neogit' },
    keys = {
      { '<leader>gs', '<cmd>Neogit<cr>', desc = 'Git status (Neogit)' },
      { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Git commit' },
      { '<leader>gp', '<cmd>Neogit push<cr>', desc = 'Git push' },
      { '<leader>gP', '<cmd>Neogit pull<cr>', desc = 'Git pull' },
      { '<leader>gf', '<cmd>Neogit fetch<cr>', desc = 'Git fetch' },
      { '<leader>gl', '<cmd>Neogit log<cr>', desc = 'Git log' },
      { '<leader>gb', '<cmd>Neogit branch<cr>', desc = 'Git branches' },
      { '<leader>gm', '<cmd>Neogit merge<cr>', desc = 'Git merge' },
      { '<leader>gr', '<cmd>Neogit rebase<cr>', desc = 'Git rebase' },
      { '<leader>gz', '<cmd>Neogit stash<cr>', desc = 'Git stash' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local neogit = require('neogit')
      neogit.setup({
        -- Basic configuration
        kind = 'tab',
        auto_refresh = true,
        disable_builtin_notifications = false,
        
        -- Integrations
        integrations = {
          diffview = true,
          telescope = true,
        },
        
        -- Sign configuration
        signs = {
          section = { '>', 'v' },
          item = { '>', 'v' },
          hunk = { '', '' },
        },
        
        -- No custom mappings - use defaults
      })
    end,
  },

  -- Diffview - Enhanced diff viewer
  {
    'sindrets/diffview.nvim',
    lazy = true,
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewRefresh', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Open diffview' },
      { '<leader>gD', '<cmd>DiffviewClose<cr>', desc = 'Close diffview' },
      { '<leader>gh', '<cmd>DiffviewFileHistory<cr>', desc = 'File history' },
      { '<leader>gH', '<cmd>DiffviewFileHistory %<cr>', desc = 'Current file history' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local actions = require('diffview.actions')
      
      require('diffview').setup({
        diff_binaries = false,
        enhanced_diff_hl = false,
        git_cmd = { 'git' },
        hg_cmd = { 'hg' },
        use_icons = true,
        show_help_hints = true,
        watch_index = true,
        icons = {
          folder_closed = '',
          folder_open = '',
        },
        signs = {
          fold_closed = '',
          fold_open = '',
          done = '✓',
        },
        view = {
          default = {
            layout = 'diff2_horizontal',
            winbar_info = false,
          },
          merge_tool = {
            layout = 'diff3_horizontal',
            disable_diagnostics = true,
            winbar_info = true,
          },
          file_history = {
            layout = 'diff2_horizontal',
            winbar_info = false,
          },
        },
        file_panel = {
          listing_style = 'tree',
          tree_options = {
            flatten_dirs = true,
            folder_statuses = 'only_folded',
          },
          win_config = {
            position = 'left',
            width = 35,
            win_opts = {}
          },
        },
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                diff_merges = 'combined',
              },
              multi_file = {
                diff_merges = 'first-parent',
              },
            },
            hg = {
              single_file = {},
              multi_file = {},
            },
          },
          win_config = {
            position = 'bottom',
            height = 16,
            win_opts = {}
          },
        },
        commit_log_panel = {
          win_config = {
            win_opts = {},
          }
        },
        default_args = {
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        hooks = {},
        keymaps = {
          disable_defaults = false,
          view = {
            -- Navigation
            ['<tab>']     = actions.select_next_entry,
            ['<s-tab>']   = actions.select_prev_entry,
            ['gf']        = actions.goto_file,
            ['<C-w><C-f>'] = actions.goto_file_split,
            ['<C-w>gf']   = actions.goto_file_tab,
            -- Focus file panel
            ['<leader>e'] = actions.focus_files,
            ['<leader>b'] = actions.toggle_files,
            -- Refresh
            ['g<C-r>']    = actions.refresh_files,
            -- Close
            ['<leader>q'] = '<cmd>DiffviewClose<cr>',
          },
          file_panel = {
            -- Navigation
            ['j']         = actions.next_entry,
            ['<down>']    = actions.next_entry,
            ['k']         = actions.prev_entry,
            ['<up>']      = actions.prev_entry,
            ['<cr>']      = actions.select_entry,
            ['o']         = actions.select_entry,
            ['<2-LeftMouse>'] = actions.select_entry,
            -- Folding
            ['-']         = actions.toggle_fold,
            -- Stage operations
            ['s']         = actions.stage_all,
            ['u']         = actions.unstage_all,
            ['X']         = actions.restore_entry,
            -- Refresh
            ['R']         = actions.refresh_files,
            -- Focus view
            ['<tab>']     = actions.select_next_entry,
            ['<s-tab>']   = actions.select_prev_entry,
            ['gf']        = actions.goto_file,
            ['<C-w><C-f>'] = actions.goto_file_split,
            ['<C-w>gf']   = actions.goto_file_tab,
            -- Focus view panel
            ['i']         = actions.listing_style,
            ['f']         = actions.toggle_flatten_dirs,
            -- Close
            ['<leader>q'] = '<cmd>DiffviewClose<cr>',
            ['q']         = '<cmd>DiffviewClose<cr>',
          },
          file_history_panel = {
            -- Navigation
            ['g!']        = actions.options,
            ['<C-A-d>']   = actions.open_in_diffview,
            -- Copy hash
            ['y']         = actions.copy_hash,
            -- Open commit
            ['L']         = actions.open_commit_log,
            -- Close
            ['<leader>q'] = '<cmd>DiffviewClose<cr>',
            ['q']         = '<cmd>DiffviewClose<cr>',
          },
          option_panel = {
            -- Navigation
            ['<tab>']     = actions.select_entry,
            ['q']         = actions.close,
          },
        },
      })
    end,
  },

  -- LazyGit integration
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
      { '<leader>gG', '<cmd>LazyGitCurrentFile<cr>', desc = 'LazyGit current file' },
      { '<leader>gF', '<cmd>LazyGitFilter<cr>', desc = 'LazyGit filter' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      -- LazyGit configuration
      vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
      vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
      vim.g.lazygit_floating_window_corner_chars = {'╭', '╮', '╰', '╯'} -- customize lazygit popup window corner characters
      vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
      vim.g.lazygit_use_neovim_remote = 1 -- use neovim remote for lazygit
    end,
  },
}