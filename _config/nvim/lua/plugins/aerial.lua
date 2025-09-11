return {
  'stevearc/aerial.nvim',
  keys = {
    {
      '<F9>',
      '<cmd>AerialToggle<cr>',
      desc = 'Toggle code outline'
    }
  },
  opts = {
    -- Priority list of preferred backends for aerial.
    -- This can be a filetype map (see :help aerial-filetype-map)
    backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },

    layout = {
      -- These control the width of the aerial window.
      -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_width and max_width can be a list of mixed integer/float types.
      max_width = { 40, 0.2 },
      width = nil,
      min_width = 10,

      -- key-value pairs of window-local options for aerial window (e.g. winhl)
      win_opts = {},

      -- Determines the default direction to open the aerial window. The 'prefer'
      -- options will open the window in the other direction *if* there is a
      -- different buffer in the way of the preferred direction
      -- Enum: prefer_right, prefer_left, right, left, float
      default_direction = "prefer_right",

      -- Determines where the aerial window will be opened
      -- Enum: edge, group, window
      placement = "window",

      -- When the symbols change, resize the aerial window (within min/max constraints) to fit
      resize_to_content = true,

      -- Preserve window size equality with (:help CTRL-W_=)
      preserve_equality = false,
    },

    -- Determines how the aerial window decides which buffer to display symbols for
    -- Enum: global, tabpages, windows
    attach_mode = "window",

    -- List of enum values that configure when to auto-close the aerial window
    -- Enum: unfocus, switch_buffer, unsupported
    close_automatic_events = {},

    -- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
    -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
    -- Additionally, if it is a string that matches "actions.<name>",
    -- it will use the mapping at require("aerial.actions").<name>
    -- Set to `false` to remove a keymap
    keymaps = {
      ["?"] = "actions.show_help",
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.jump",
      ["<2-LeftMouse>"] = "actions.jump",
      ["<C-v>"] = "actions.jump_vsplit",
      ["<C-s>"] = "actions.jump_split",
      ["p"] = "actions.scroll",
      ["<C-j>"] = "actions.down_and_scroll",
      ["<C-k>"] = "actions.up_and_scroll",
      ["{"] = "actions.prev",
      ["}"] = "actions.next",
      ["[["] = "actions.prev_up",
      ["]]"] = "actions.next_up",
      ["q"] = "actions.close",
      ["o"] = "actions.tree_toggle",
      ["za"] = "actions.tree_toggle",
      ["O"] = "actions.tree_toggle_recursive",
      ["zA"] = "actions.tree_toggle_recursive",
      ["l"] = "actions.tree_open",
      ["zo"] = "actions.tree_open",
      ["L"] = "actions.tree_open_recursive",
      ["zO"] = "actions.tree_open_recursive",
      ["h"] = "actions.tree_close",
      ["zc"] = "actions.tree_close",
      ["H"] = "actions.tree_close_recursive",
      ["zC"] = "actions.tree_close_recursive",
      ["zr"] = "actions.tree_increase_fold_level",
      ["zR"] = "actions.tree_open_all",
      ["zm"] = "actions.tree_decrease_fold_level",
      ["zM"] = "actions.tree_close_all",
      ["zx"] = "actions.tree_sync_folds",
      ["zX"] = "actions.tree_sync_folds",
    },

    -- When true, don't load aerial until a command or function is called
    -- Defaults to true, unless `on_attach` is provided, then it defaults to false
    lazy_load = true,

    -- Disable aerial on files with this many lines
    disable_max_lines = 10000,

    -- Disable aerial on files this size or larger (in bytes)
    disable_max_size = 2000000, -- Default 2MB

    -- A list of all symbols to display. Set to false to display all symbols.
    -- This can be a filetype map (see :help aerial-filetype-map)
    -- To see all available values, see :help SymbolKind
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Module",
      "Method",
      "Struct",
    },

    -- Determines line highlighting mode when multiple splits are visible.
    -- split_width   Each open window will have its cursor location marked in the
    --               aerial buffer. Each line will only be partially highlighted
    --               to indicate which window is at that location.
    -- full_width    Each open window will have its cursor location marked as a
    --               full-width highlight in the aerial buffer.
    -- last          Only the most-recently focused window will have its location
    --               marked in the aerial buffer.
    -- none          Do not show the cursor locations in the aerial window.
    highlight_mode = "split_width",

    -- Highlight the closest symbol if the cursor is not exactly on one.
    highlight_closest = true,

    -- Highlight the symbol in the source buffer when cursor is in the aerial win
    highlight_on_hover = false,

    -- When jumping to a symbol, highlight the line for this many ms.
    -- Set to false to disable
    highlight_on_jump = 300,

    -- Jump to symbol in source window when the cursor moves
    autojump = false,

    -- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
    -- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
    -- default collapsed icon. The default icon set is determined by the
    -- "nerd_font" option below.
    -- If you have lspkind-nvim installed, it will be the default icon set.
    -- This can be a filetype map (see :help aerial-filetype-map)
    icons = {},

    -- Control which windows aerial will attach to
    -- Set to `false` to disable attaching
    -- attachment = {
    --   -- '<filetype>' = false to disable on that filetype
    -- },

    -- Call this function when aerial attaches to a buffer.
    on_attach = function(bufnr)
      -- Jump to the aerial window with '{' and '}'
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
    end,

    -- Call this function when aerial first sets symbols on a buffer.
    on_first_symbols = function(bufnr)
      -- nothing by default
    end,

    -- Enum: persist, auto, last, none
    -- Determines how to handle opening aerial when there is already an aerial buffer open
    manage_folds = false,

    -- Set to false to remove the default keybindings for the aerial buffer
    default_keymaps = true,

    -- Disable aerial on certain buffers
    ignore = {
      -- Ignore unlisted buffers. See :help buflisted
      unlisted_buffers = false,

      -- List of filetypes to ignore.
      filetypes = {},

      -- Ignored buftypes
      buftypes = "special",

      -- Ignored wintypes
      wintypes = "special",
    },

    -- Use symbol tree for folding. Set to true or false to enable/disable
    -- Set to "auto" to manage folds if your previous foldmethod was 'manual'
    -- This can be a filetype map (see :help aerial-filetype-map)
    manage_folds = false,

    -- When you fold code with za, zo, etc, update the aerial tree as well.
    -- Only works when manage_folds = true
    link_folds_to_tree = false,

    -- Fold code when you open/collapse symbols in the tree.
    -- Only works when manage_folds = true
    link_tree_to_folds = true,

    -- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
    -- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
    nerd_font = "auto",
  },

  config = function(_, opts)
    require("aerial").setup(opts)

    -- Optional: Add commands for convenience
    vim.api.nvim_create_user_command('AerialInfo', function()
      local aerial = require('aerial')
      local symbols = aerial.get_symbols()
      if #symbols == 0 then
        vim.notify('No symbols found in current buffer', vim.log.levels.WARN)
      else
        vim.notify(string.format('Found %d symbols in current buffer', #symbols), vim.log.levels.INFO)
      end
    end, { desc = 'Show aerial symbol info' })

    vim.api.nvim_create_user_command('AerialNavToggle', function()
      require('aerial').nav_toggle()
    end, { desc = 'Toggle aerial navigation mode' })
  end,

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- optional for icons
  },
}