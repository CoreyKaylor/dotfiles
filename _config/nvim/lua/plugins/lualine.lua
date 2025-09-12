return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      options = {
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str)
              return str:sub(1,1)
            end
          }
        },
        lualine_b = {
          {
            'branch',
            icons_enabled = true,
            icon = '',
          },
          {
            'diff',
            colored = true,
            diff_color = {
              added    = 'DiffAdd',
              modified = 'DiffChange', 
              removed  = 'DiffDelete',
            },
            symbols = {added = '+', modified = '~', removed = '-'},
          }
        },
        lualine_c = {
          {
            'filename',
            file_status = true,
            newfile_status = false,
            path = 1, -- 0: Just the filename, 1: Relative path, 2: Absolute path, 3: Absolute path with ~ for home
            shorting_target = 40,
            symbols = {
              modified = '[+]',
              readonly = '[RO]',
              unnamed = '[No Name]',
              newfile = '[New]',
            }
          }
        },
        lualine_x = {
          {
            'diagnostics',
            sources = { 'nvim_diagnostic', 'nvim_lsp' },
            sections = { 'error', 'warn', 'info', 'hint' },
            diagnostics_color = {
              error = 'DiagnosticError',
              warn  = 'DiagnosticWarn',
              info  = 'DiagnosticInfo',
              hint  = 'DiagnosticHint',
            },
            symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'},
            colored = true,
            update_in_insert = false,
            always_visible = false,
          },
          {
            -- Show attached LSP server names
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then
                return ''
              end
              
              local names = {}
              for _, client in ipairs(clients) do
                table.insert(names, client.name)
              end
              return '[' .. table.concat(names, ',') .. ']'
            end,
            icon = '',
            color = { fg = '#a6adc8' }, -- catppuccin text color
          },
          'encoding',
          'fileformat',
          'filetype'
        },
        lualine_y = {
          'progress'
        },
        lualine_z = {
          {
            'location',
            fmt = function(str)
              return str .. ' ☰ %L'
            end
          }
        }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { 'nvim-tree', 'aerial', 'trouble', 'fugitive' }
    })
  end,
}