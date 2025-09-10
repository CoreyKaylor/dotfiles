-- Create namespace for tidy diagnostics
local tidy_namespace = vim.api.nvim_create_namespace('tidy')

-- Load LSP configurations
local lsp_configs = {
  'lua_ls',
  'kotlin_lsp',
  'sqls',
  'csharp_lsp',
  'typescript_lsp',
  'golang_lsp',
  'python_lsp',
  'web_lsp',  -- This now contains html, css, and emmet configs
}

-- Add the lsp directory to the runtime path
vim.opt.runtimepath:append(vim.fn.stdpath('config'))

for _, lsp_name in ipairs(lsp_configs) do
  local config_path = vim.fn.stdpath('config') .. '/lsp/' .. lsp_name .. '.lua'
  local f = io.open(config_path, 'r')
  if f then
    f:close()
    local ok, config = pcall(dofile, config_path)
    if ok then
      -- Handle web_lsp which returns multiple configurations
      if lsp_name == 'web_lsp' and type(config) == 'table' and config.html then
        -- Load each web configuration separately
        for web_lsp_type, web_config in pairs(config) do
          local cmd = web_config.cmd and web_config.cmd[1]
          if cmd and vim.fn.executable(cmd) == 0 then
            vim.notify('Skipping web LSP ' .. web_lsp_type .. ' (missing executable: ' .. cmd .. ')', vim.log.levels.WARN)
          else
            package.loaded['lsp.web_' .. web_lsp_type] = web_config
            vim.api.nvim_create_autocmd('FileType', {
              pattern = web_config.filetypes or {},
              callback = function(args)
                local bufnr = args.buf
                local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
                for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
                  if client.name == 'web_' .. web_lsp_type then return end
                end
                local root_dir = web_config.root_dir and web_config.root_dir(vim.api.nvim_buf_get_name(bufnr)) or vim.loop.cwd()
                local new_config = vim.tbl_deep_extend('force', {}, web_config, {
                  name = 'web_' .. web_lsp_type,
                  root_dir = root_dir,
                })
                vim.lsp.start(new_config)
              end,
            })
          end
        end
      else
        -- Handle regular single LSP configurations
        local cmd = config.cmd and config.cmd[1]
        if cmd and vim.fn.executable(cmd) == 0 then
          vim.notify('Skipping LSP ' .. lsp_name .. ' (missing executable: ' .. cmd .. ')', vim.log.levels.WARN)
        else
          package.loaded['lsp.' .. lsp_name] = config
          vim.api.nvim_create_autocmd('FileType', {
            pattern = config.filetypes or {},
            callback = function(args)
              local bufnr = args.buf
              local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
              for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
                if client.name == lsp_name then return end
              end
              local root_dir = config.root_dir and config.root_dir(vim.api.nvim_buf_get_name(bufnr)) or vim.loop.cwd()
              local new_config = vim.tbl_deep_extend('force', {}, config, {
                name = lsp_name,
                root_dir = root_dir,
              })
              vim.lsp.start(new_config)
            end,
          })
        end
      end
    else
      vim.notify('Failed to load LSP config: ' .. lsp_name .. ' - ' .. tostring(config), vim.log.levels.ERROR)
    end
  end
end

-- Rounded border for hover (help text)
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = 'rounded' }
)

-- Helper command to check LSP status
vim.api.nvim_create_user_command('LspInfo', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to this buffer")
  else
    for _, client in ipairs(clients) do
      print(string.format("LSP: %s (id: %d)", client.name, client.id))
    end
  end
end, { desc = 'Show attached LSP clients' })

-- Force LSP buffer sync command (useful for kotlin-lsp sync issues)
vim.api.nvim_create_user_command('LspSync', function()
  vim.cmd('write')
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    -- Force document synchronization
    local params = vim.lsp.util.make_text_document_params(0)
    client.notify('textDocument/didSave', params)
  end
  print("LSP buffer synchronized")
end, { desc = 'Force sync current buffer with LSP' })

-- Force HTML validation command
vim.api.nvim_create_user_command('HtmlValidate', function()
  -- First try LSP diagnostics
  local diagnostics = vim.diagnostic.get(0)
  local lsp_issues = #diagnostics

  -- Then use tidy for comprehensive HTML validation
  local filename = vim.fn.expand('%:p')
  if vim.fn.executable('tidy') == 1 and vim.fn.filereadable(filename) == 1 then
    local cmd = string.format('tidy -q -e "%s" 2>&1', filename)
    local result = vim.fn.system(cmd)

    if vim.v.shell_error == 0 then
      print("HTML validation passed (tidy)")
    else
      local lines = vim.split(result, '\n')
      local tidy_issues = 0
      print("HTML validation issues found:")
      for _, line in ipairs(lines) do
        if line:match('line %d+') and not line:match('DOCTYPE') then
          print("  " .. line)
          tidy_issues = tidy_issues + 1
        end
      end
      if tidy_issues == 0 and lsp_issues == 0 then
        print("No validation issues found")
      end
    end
  else
    -- Fallback to LSP-only validation
    vim.cmd('write')
    vim.defer_fn(function()
      local diagnostics = vim.diagnostic.get(0)
      if #diagnostics > 0 then
        print("Found " .. #diagnostics .. " HTML validation issues")
        for i, diag in ipairs(diagnostics) do
          print(string.format("%d: %s (line %d)", i, diag.message, diag.lnum + 1))
        end
      else
        print("No HTML validation issues found")
      end
    end, 1000)
  end
end, { desc = 'Force HTML validation using tidy or LSP' })

-- HTML validation with diagnostics integration
vim.api.nvim_create_user_command('HtmlValidateWithHighlight', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.fn.expand('%:p')
  if vim.fn.executable('tidy') == 1 and vim.fn.filereadable(filename) == 1 then
    local cmd = string.format('tidy -q -e "%s" 2>&1', filename)
    local result = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
      local lines = vim.split(result, '\n')
      local qf_list = {}

      for _, line in ipairs(lines) do
        -- Parse tidy output: "line 5 column 3 - Error: <header> is not recognized!"
        local line_num, col_num, severity, message = line:match('line (%d+) column (%d+) %- (%w+): (.+)')
        if line_num and message and not message:match('DOCTYPE') and not message:match('inserting "type"') then
          table.insert(qf_list, {
            bufnr = bufnr,
            lnum = tonumber(line_num),
            col = tonumber(col_num) or 1,
            text = message,
            type = severity == 'Error' and 'E' or 'W'
          })
        end
      end

      -- Set quickfix list
      vim.fn.setqflist(qf_list)

      if #qf_list > 0 then
        print("Found " .. #qf_list .. " HTML validation issues (added to quickfix list)")
        print("Use :copen to view issues with highlighting, K to show error details")
      else
        print("No validation issues found")
      end
    else
      print("HTML validation passed")
    end
  else
    print("tidy not available or file not readable")
  end
end, { desc = 'HTML validation with quickfix highlighting' })

-- Telescope integration for HTML validation errors
vim.api.nvim_create_user_command('TelescopeHtmlErrors', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr, { namespace = tidy_namespace })

  if #diagnostics == 0 then
    print("No HTML validation errors found. Run :HtmlValidateWithHighlight first.")
    return
  end

  -- Check if telescope is available
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    print("Telescope not available")
    return
  end

  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers.new({}, {
    prompt_title = 'HTML Validation Errors',
    finder = finders.new_table({
      results = diagnostics,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("%d:%d %s", entry.lnum + 1, entry.col + 1, entry.message),
          ordinal = string.format("%d:%d %s", entry.lnum + 1, entry.col + 1, entry.message),
          lnum = entry.lnum + 1,
          col = entry.col + 1,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
        end
      end)
      return true
    end,
  }):find()
end, { desc = 'Browse HTML validation errors with Telescope' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf, noremap = true, silent = true }

    -- Navigation keymaps
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', function()
      local builtin = require('telescope.builtin')
      builtin.lsp_references({
        initial_mode = 'normal',
        layout_strategy = 'horizontal',
        layout_config = { preview_width = 0.55 },
        show_line = false,
      })
    end, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- Workspace keymaps
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)

    -- Actions
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>rn', function()
      -- Workaround for kotlin-lsp sync issues
      if vim.bo.modified then
        vim.cmd('write')
      end
      vim.defer_fn(vim.lsp.buf.rename, 100)
    end, opts)
    -- Note: conform.nvim will override this for Kotlin files
    -- Only set this keymap if conform.nvim isn't loaded or doesn't handle this filetype
    if not pcall(require, 'conform') then
      vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
      end, opts)
    end

    -- Diagnostics
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

    -- Special handling for HTML/CSS LSPs
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and (client.name == 'web_html' or client.name == 'web_css' or client.name == 'web_emmet') then
      -- Enable document highlighting for HTML/CSS
      if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = ev.buf,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd('CursorMoved', {
          buffer = ev.buf,
          callback = vim.lsp.buf.clear_references,
        })
      end

      -- Enable completion for HTML/CSS
      if client.server_capabilities.completionProvider then
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
      end

      -- Special setup for HTML LSP to enable CSS class completion
      if client.name == 'web_html' then
        -- Notify the LSP about CSS files in the workspace
        vim.api.nvim_create_autocmd('BufWritePost', {
          pattern = '*.css,*.scss,*.less',
          callback = function()
            -- Trigger re-scan of CSS files for class completion
            if client.server_capabilities.workspaceSymbolProvider then
              vim.lsp.buf.workspace_symbol('')
            end
          end,
        })

        -- Add key mapping for HTML error navigation
        vim.keymap.set('n', '<leader>he', '<Cmd>TelescopeHtmlErrors<CR>', { buffer = ev.buf, desc = 'Browse HTML errors with Telescope' })

        -- Override K to show diagnostic info for HTML files
        if client.name == 'web_html' then
          vim.keymap.set('n', 'K', function()
            local diagnostics = vim.diagnostic.get(ev.buf, { lnum = vim.fn.line('.') - 1 })
            if #diagnostics > 0 then
              vim.diagnostic.open_float()
            else
              -- Fallback to LSP hover if no diagnostics
              vim.lsp.buf.hover()
            end
          end, { buffer = ev.buf, desc = 'Show diagnostic info or LSP hover' })
        end
      end
    end
  end,
})