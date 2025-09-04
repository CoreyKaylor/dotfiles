return {
  'nvim-telescope/telescope.nvim', tag = '0.1.8',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
  },
  keys = {
    -- Unite-style mappings with space prefix
    { "<space><space>", function()
        -- Mixed files/buffers/MRU (like Unite mixed)
        local builtin = require('telescope.builtin')
        local themes = require('telescope.themes')
        builtin.find_files(themes.get_dropdown({
          previewer = false,
          prompt_title = "Files, Buffers & Recent",
          find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' },
        }))
      end,
      desc = "Mixed files/buffers/MRU"
    },
    { "<space>f", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<space>e", "<cmd>Telescope oldfiles<cr>", desc = "Recent files (MRU)" },
    { "<space>b", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<space>y", "<cmd>Telescope registers<cr>", desc = "Yank history (registers)" },
    { "<space>/", "<cmd>Telescope live_grep<cr>", desc = "Grep search" },
    { "<space>l", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Current buffer lines" },
    { "<space>s", function()
        require('telescope.builtin').buffers({
          sort_lastused = true,
          ignore_current_buffer = true,
          initial_mode = "normal",
        })
      end,
      desc = "Quick buffer switch"
    },
    { "<space>m", "<cmd>Telescope marks<cr>", desc = "Marks" },
    { "<space>h", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<space>c", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<space>k", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<space>o", "<cmd>Telescope vim_options<cr>", desc = "Vim options" },
    { "<space>r", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    telescope.setup({
      defaults = {
        -- Layout configuration
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            prompt_position = 'bottom',
            preview_width = 0.55,
            results_width = 0.8,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },

        -- Use ripgrep for better performance
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--glob', '!.git/*',
        },

        -- Mappings within telescope
        mappings = {
          i = {
            -- Unite-like mappings
            ["<esc>"] = actions.close,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
          n = {
            ["<esc>"] = actions.close,
            ["q"] = actions.close,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },

        -- Performance optimizations
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "dist/",
          "build/",
          "%.lock",
        },

        -- Better sorting and display
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        file_sorter = require('telescope.sorters').get_fuzzy_file,
        generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,

        -- Enable preview for most file types
        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

        -- Visual improvements
        prompt_prefix = "» ",
        selection_caret = "➜ ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        color_devicons = true,
        use_less = true,
        set_env = { ['COLORTERM'] = 'truecolor' },
      },

      pickers = {
        find_files = {
          find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' },
          hidden = true,
        },
        buffers = {
          show_all_buffers = true,
          sort_lastused = true,
          theme = "dropdown",
          previewer = false,
          mappings = {
            i = {
              ["<c-d>"] = actions.delete_buffer,
            },
            n = {
              ["dd"] = actions.delete_buffer,
            },
          },
        },
        oldfiles = {
          prompt_title = "Recent Files",
          cwd_only = false,
        },
        live_grep = {
          additional_args = function()
            return { "--hidden" }
          end,
        },
        current_buffer_fuzzy_find = {
          previewer = false,
          theme = "dropdown",
        },
      },

      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    -- Load extensions
    telescope.load_extension('fzf')

    -- Create command for quick access
    vim.api.nvim_create_user_command('Files', 'Telescope find_files', {})
    vim.api.nvim_create_user_command('Grep', 'Telescope live_grep', {})
    vim.api.nvim_create_user_command('Buffers', 'Telescope buffers', {})
    vim.api.nvim_create_user_command('History', 'Telescope oldfiles', {})
  end,
}
