return {
  'folke/trouble.nvim',
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>cs',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>cl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
    {
      '<leader>xw',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Workspace Diagnostics (Trouble)',
    },
    {
      '<leader>xd',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Document Diagnostics (Trouble)',
    },
  },
  opts = {
    modes = {
      preview_float = {
        mode = "diagnostics",
        preview = {
          type = "float",
          relative = "editor",
          border = "rounded",
          title = "Preview",
          title_pos = "center",
          position = { 0, -2 },
          size = { width = 0.3, height = 0.3 },
          zindex = 200,
        },
      },
    },
    icons = {
      indent = {
        top           = "│ ",
        middle        = "├╴",
        last          = "└╴",
        fold_open     = " ",
        fold_closed   = " ",
        ws            = "  ",
      },
      folder_closed   = " ",
      folder_open     = " ",
      kinds = {
        Array         = " ",
        Boolean       = "󰨙 ",
        Class         = " ",
        Constant      = "󰏿 ",
        Constructor   = " ",
        Enum          = " ",
        EnumMember    = " ",
        Event         = " ",
        Field         = " ",
        File          = " ",
        Function      = "󰊕 ",
        Interface     = " ",
        Key           = " ",
        Method        = "󰊕 ",
        Module        = " ",
        Namespace     = "󰦮 ",
        Null          = " ",
        Number        = "󰎠 ",
        Object        = " ",
        Operator      = " ",
        Package       = " ",
        Property      = " ",
        String        = " ",
        Struct        = "󰆼 ",
        TypeParameter = " ",
        Variable      = "󰀫 ",
      },
    },
    -- Window configuration
    win = {
      size = {
        width = 0.3,
        height = 0.3,
      },
    },
    -- Auto refresh when diagnostics change
    auto_refresh = true,
    -- Use diagnostics from all sources
    multiline = true,
    -- Include source information
    include_declaration = true,
  },
  
  config = function(_, opts)
    require("trouble").setup(opts)
    
    -- Auto-open trouble window when there are diagnostics
    local trouble_group = vim.api.nvim_create_augroup("TroubleConfig", { clear = true })
    
    -- Optional: Auto-close trouble when no diagnostics
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
      group = trouble_group,
      callback = function()
        local trouble = require("trouble")
        -- Get current diagnostics count
        local diagnostics = vim.diagnostic.get()
        if #diagnostics == 0 then
          -- Check if trouble is open and close it
          if trouble.is_open() then
            trouble.close()
          end
        end
      end,
    })

    -- Set up keymaps for trouble window
    vim.api.nvim_create_autocmd("FileType", {
      group = trouble_group,
      pattern = "trouble",
      callback = function(event)
        local opts_local = { buffer = event.buf, silent = true }
        vim.keymap.set("n", "q", "<cmd>Trouble close<cr>", vim.tbl_extend("force", opts_local, { desc = "Close trouble" }))
        vim.keymap.set("n", "r", "<cmd>Trouble refresh<cr>", vim.tbl_extend("force", opts_local, { desc = "Refresh trouble" }))
        vim.keymap.set("n", "?", function()
          vim.notify("Trouble Keymaps:\nq - Close\nr - Refresh\n<CR> - Jump to item\no - Jump and close\n<C-x> - Jump split\n<C-v> - Jump vsplit\n<C-t> - Jump tab", vim.log.levels.INFO, { title = "Trouble Help" })
        end, vim.tbl_extend("force", opts_local, { desc = "Show help" }))
      end,
    })

    -- Custom user commands for convenience
    vim.api.nvim_create_user_command('TroubleWorkspace', function()
      require('trouble').toggle('diagnostics')
    end, { desc = 'Toggle workspace diagnostics' })

    vim.api.nvim_create_user_command('TroubleDocument', function()
      require('trouble').toggle('diagnostics', { filter = { buf = 0 } })
    end, { desc = 'Toggle document diagnostics' })

    vim.api.nvim_create_user_command('TroubleQuickfix', function()
      require('trouble').toggle('qflist')
    end, { desc = 'Toggle quickfix list' })

    vim.api.nvim_create_user_command('TroubleLoclist', function()
      require('trouble').toggle('loclist')
    end, { desc = 'Toggle location list' })
  end,

  dependencies = {
    "nvim-tree/nvim-web-devicons", -- For file icons
    "folke/which-key.nvim", -- For better keymap descriptions
  },
}