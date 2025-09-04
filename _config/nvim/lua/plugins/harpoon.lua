return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>ha', function()
        local harpoon = require('harpoon')
        harpoon:list():add()
        vim.notify('Added to Harpoon', vim.log.levels.INFO)
      end,
      desc = 'Add file to Harpoon'
    },
    { '<leader>hd', function()
        local harpoon = require('harpoon')
        harpoon:list():remove()
        vim.notify('Removed from Harpoon', vim.log.levels.INFO)
      end,
      desc = 'Remove file from Harpoon'
    },
    { '<leader>hc', function()
        local harpoon = require('harpoon')
        harpoon:list():clear()
        vim.notify('Cleared all Harpoon marks', vim.log.levels.INFO)
      end,
      desc = 'Clear all Harpoon marks'
    },
    { '<leader>hh', function()
        -- Use Telescope instead of the default menu
        local harpoon = require('harpoon')
        local conf = require('telescope.config').values
        local themes = require('telescope.themes')
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')

        local function generate_finder()
          local paths = {}
          local list = harpoon:list()
          for idx, item in ipairs(list.items) do
            -- Add index number for display
            local display = string.format("%d. %s", idx, item.value)
            paths[idx] = {
              idx = idx,
              value = item.value,
              display = display,
            }
          end
          return paths
        end

        pickers.new({
          prompt_title = 'Harpoon',
          initial_mode = 'normal',
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              preview_width = 0.55,
              results_width = 0.8,
            },
            width = 0.85,
            height = 0.80,
            preview_cutoff = 120,
          },
          sorting_strategy = 'ascending',
        }, {
          finder = finders.new_table({
            results = generate_finder(),
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.display,
                ordinal = entry.display,
                path = entry.value,
              }
            end,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            -- Select file on enter
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                harpoon:list():select(selection.value.idx)
              end
            end)

            -- Delete with 'd' or 'dd' in normal mode
            map('n', 'd', function()
              local selection = action_state.get_selected_entry()
              if selection then
                local list = harpoon:list()
                -- Directly remove the item at the index without selecting it
                local item_to_remove = list.items[selection.value.idx]
                if item_to_remove then
                  -- Remove the item from the list
                  table.remove(list.items, selection.value.idx)
                  vim.notify('Removed from Harpoon: ' .. selection.value.value, vim.log.levels.INFO)
                end

                -- Refresh the picker
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker:refresh(finders.new_table({
                  results = generate_finder(),
                  entry_maker = function(entry)
                    return {
                      value = entry,
                      display = entry.display,
                      ordinal = entry.display,
                      path = entry.value,
                    }
                  end,
                }), {})
              end
            end)

            -- Move up with 'K'
            map('n', 'K', function()
              local selection = action_state.get_selected_entry()
              if selection and selection.value.idx > 1 then
                local list = harpoon:list()
                local idx = selection.value.idx
                -- Swap items
                list.items[idx], list.items[idx - 1] = list.items[idx - 1], list.items[idx]

                -- Refresh the picker
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker:refresh(finders.new_table({
                  results = generate_finder(),
                  entry_maker = function(entry)
                    return {
                      value = entry,
                      display = entry.display,
                      ordinal = entry.display,
                      path = entry.value,
                    }
                  end,
                }), {})

                -- Move cursor up
                actions.move_selection_previous(prompt_bufnr)
              end
            end)

            -- Move down with 'J'
            map('n', 'J', function()
              local selection = action_state.get_selected_entry()
              local list = harpoon:list()
              if selection and selection.value.idx < #list.items then
                local idx = selection.value.idx
                -- Swap items
                list.items[idx], list.items[idx + 1] = list.items[idx + 1], list.items[idx]

                -- Refresh the picker
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker:refresh(finders.new_table({
                  results = generate_finder(),
                  entry_maker = function(entry)
                    return {
                      value = entry,
                      display = entry.display,
                      ordinal = entry.display,
                      path = entry.value,
                    }
                  end,
                }), {})

                -- Move cursor down
                actions.move_selection_next(prompt_bufnr)
              end
            end)

            -- Clear all with 'C'
            map('n', 'C', function()
              harpoon:list():clear()
              vim.notify('Cleared all Harpoon marks', vim.log.levels.INFO)
              actions.close(prompt_bufnr)
            end)

            -- Show help with '?'
            map('n', '?', function()
              local help = {
                'Harpoon Telescope Commands:',
                '',
                'Enter  - Jump to file',
                'd      - Delete current item',
                'J      - Move item down',
                'K      - Move item up', 
                'C      - Clear all marks',
                'j/k    - Navigate list',
                '?      - Show this help',
                'q/Esc  - Close',
              }
              vim.notify(table.concat(help, '\n'), vim.log.levels.INFO)
            end)

            return true
          end,
        }):find()
      end,
      desc = 'Open Harpoon in Telescope'
    },
    { '<leader>1', function()
        local harpoon = require('harpoon')
        harpoon:list():select(1)
      end,
      desc = 'Jump to Harpoon file 1'
    },
    { '<leader>2', function()
        local harpoon = require('harpoon')
        harpoon:list():select(2)
      end,
      desc = 'Jump to Harpoon file 2'
    },
    { '<leader>3', function()
        local harpoon = require('harpoon')
        harpoon:list():select(3)
      end,
      desc = 'Jump to Harpoon file 3'
    },
    { '<leader>4', function()
        local harpoon = require('harpoon')
        harpoon:list():select(4)
      end,
      desc = 'Jump to Harpoon file 4'
    },
    -- Optional: Add next/prev navigation
    { '<leader>hn', function()
        local harpoon = require('harpoon')
        harpoon:list():next()
      end,
      desc = 'Next Harpoon file'
    },
    { '<leader>hp', function()
        local harpoon = require('harpoon')
        harpoon:list():prev()
      end,
      desc = 'Previous Harpoon file'
    },
  },
  config = function()
    local harpoon = require('harpoon')

    harpoon:setup({
      settings = {
        -- Save on toggle/add/remove
        save_on_toggle = true,
        sync_on_ui_close = true,

        -- Key to save manually in menu
        key = function()
          return vim.loop.cwd()
        end,
      },
    })

    -- Add autocmd to show current file in harpoon list indicator
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('HarpoonIndicator', { clear = true }),
      callback = function()
        local current_file = vim.fn.expand('%:p')
        local harpoon_list = harpoon:list()

        for idx, item in ipairs(harpoon_list.items) do
          local absolute_path = vim.fn.fnamemodify(item.value, ':p')
          if absolute_path == current_file then
            -- Optional: Set a variable that can be used in statusline
            vim.b.harpoon_index = idx
            return
          end
        end
        vim.b.harpoon_index = nil
      end,
    })

  end,
}
