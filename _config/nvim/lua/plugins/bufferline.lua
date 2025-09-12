return {
  'akinsho/bufferline.nvim',
  version = "*",
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { "<S-Left>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
    { "<S-Right>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin/unpin buffer" },
    { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close non-pinned buffers" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
    { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to the right" },
    { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to the left" },
  },
  config = function()
    require('bufferline').setup({
      options = {
        mode = "buffers", -- set to "tabs" to only show tabpages instead
        style_preset = require('bufferline').style_preset.default,
        themable = true,
        numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = '▎',
          style = 'icon', -- | 'underline' | 'none',
        },
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 30,
        max_prefix_length = 30,
        truncate_names = true,
        tab_size = 21,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_update_on_event = true,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        -- NOTE: this will be called a lot so don't do any heavy processing here
        custom_filter = function(buf_number, buf_numbers)
          -- filter out filetypes you don't want to see
          if vim.bo[buf_number].filetype ~= "qf" and vim.bo[buf_number].filetype ~= "NeogitStatus" then
            return true
          end
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true
          },
          {
            filetype = "aerial",
            text = "Code Outline",
            text_align = "left",
            separator = true
          }
        },
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        duplicates_across_groups = true,
        persist_buffer_sort = true,
        move_wraps_at_ends = false,
        separator_style = "slant", -- | "slope" | "thick" | "thin" | { 'any', 'any' },
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        auto_toggle_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = {'close'}
        },
        sort_by = 'insert_after_current', -- |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
        
        -- Custom groups for better organization
        groups = {
          options = {
            toggle_hidden_on_enter = true
          },
          items = {
            {
              name = "Tests",
              highlight = {underline = true, sp = "blue"},
              priority = 2,
              icon = "",
              matcher = function(buf)
                return buf.name:match('%_test') or buf.name:match('%_spec') or buf.name:match('%.test%.') or buf.name:match('%.spec%.')
              end,
            },
            {
              name = "Docs",
              highlight = {undercurl = true, sp = "green"},
              auto_close = false,
              matcher = function(buf)
                return buf.name:match('%.md') or buf.name:match('%.txt') or buf.name:match('README')
              end,
            }
          }
        }
      },
      highlights = {}
    })
  end,
}