return {
  'nvim-tree/nvim-tree.lua',
  lazy = true,
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- for file icons
  },
  keys = {
    { '<F2>', function()
        local api = require('nvim-tree.api')
        local tree = require('nvim-tree.view')

        -- If tree is visible and focused, close it and return to previous window
        if tree.is_visible() then
          local current_win = vim.api.nvim_get_current_win()
          local tree_win = tree.get_winnr()

          -- If we're in the tree, switch to previous window before closing
          if tree_win and current_win == vim.api.nvim_get_current_win() then
            vim.cmd('wincmd p')  -- Go to previous window
          end
          api.tree.close()
        else
          -- Open tree but keep focus on current buffer
          api.tree.open()
          vim.cmd('wincmd p')  -- Return to previous window
        end
      end,
      desc = 'Toggle file tree'
    },
    { '<F3>', function()
        local api = require('nvim-tree.api')
        local tree = require('nvim-tree.view')

        if tree.is_visible() then
          -- If tree is visible, close it and return focus to previous window
          local current_win = vim.api.nvim_get_current_win()
          local tree_win = tree.get_winnr()

          if tree_win and current_win == vim.api.nvim_get_current_win() then
            vim.cmd('wincmd p')
          end
          api.tree.close()
        else
          -- Open tree and find current file
          api.tree.find_file({ open = true, focus = true })
        end
      end,
      desc = 'Toggle tree and find current file'
    },
  },
  config = function()
    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true

    require('nvim-tree').setup({
      sort = {
        sorter = 'case_sensitive',
      },
      view = {
        width = 30,
        number = true,
        relativenumber = false,
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
            folder_arrow = true,
          },
        },
      },
      filters = {
        dotfiles = false, -- show hidden files
        custom = { '^.git$', '^.DS_Store$' }, -- but hide these
      },
      git = {
        enable = true,
        ignore = false, -- show files ignored by git
      },
      actions = {
        open_file = {
          quit_on_open = false, -- keep tree open after opening file
          resize_window = true,
        },
        remove_file = {
          close_window = false, -- don't close tree when removing file
        },
      },
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- additional custom keymaps can be added here if needed
        -- vim.keymap.set('n', 'custom_key', api.some_function, opts('Description'))
      end,
    })

    -- Better buffer management when deleting files
    vim.api.nvim_create_autocmd('User', {
      pattern = 'NvimTreeRemoveFile',
      callback = function(args)
        local deleted_bufnr = vim.fn.bufnr(args.data.fname)
        if deleted_bufnr ~= -1 and vim.api.nvim_buf_is_loaded(deleted_bufnr) then
          -- Try to switch to alternate buffer first
          local alt_bufnr = vim.fn.bufnr('#')
          if alt_bufnr ~= -1 and alt_bufnr ~= deleted_bufnr and vim.api.nvim_buf_is_valid(alt_bufnr) then
            vim.cmd('buffer ' .. alt_bufnr)
          else
            -- Find another valid buffer
            local found_buffer = false
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if buf ~= deleted_bufnr and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
                vim.cmd('buffer ' .. buf)
                found_buffer = true
                break
              end
            end
            -- If no other buffer, create a new one
            if not found_buffer then
              vim.cmd('enew')
            end
          end
          -- Now delete the buffer of the deleted file
          vim.cmd('bdelete! ' .. deleted_bufnr)
        end
      end
    })

    -- Auto close nvim-tree only if it's truly the last window
    vim.api.nvim_create_autocmd('QuitPre', {
      callback = function()
        local tree_wins = {}
        local wins = vim.api.nvim_list_wins()
        for _, w in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(w)
          local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
          if ft == 'NvimTree' then
            table.insert(tree_wins, w)
          end
        end

        if #wins == 1 and #tree_wins == 1 then
          -- Only the tree is left, close it
          vim.cmd 'quit'
        end
      end
    })
  end,
}
