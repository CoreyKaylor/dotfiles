local servers = {
  lua_ls = { 'lua-language-server' },
  kotlin_lsp = { 'kotlin-lsp' },
  sqls = { 'sqls' },
  csharp_lsp = { 'csharp-ls' },
  typescript_lsp = { 'typescript-language-server' },
  golang_lsp = { 'gopls' },
  python_lsp = { 'pylsp', 'pyright-langserver' },
  json_lsp = { 'vscode-json-language-server' },
  web_html = { 'vscode-html-language-server' },
  web_css = { 'vscode-css-language-server' },
  web_emmet = { 'emmet-ls' },
  marksman = { 'marksman' },
}

local enabled = {}

for name, executables in pairs(servers) do
  for _, executable in ipairs(executables) do
    if vim.fn.executable(executable) == 1 then
      table.insert(enabled, name)
      break
    end
  end
end

vim.lsp.enable(enabled)

vim.api.nvim_create_user_command('LspInfo', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print('No LSP clients attached to this buffer')
    return
  end

  for _, client in ipairs(clients) do
    print(string.format('LSP: %s (id: %d)', client.name, client.id))
  end
end, { desc = 'Show attached LSP clients' })

vim.api.nvim_create_user_command('LspSync', function()
  vim.cmd('write')
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    client.notify('textDocument/didSave', vim.lsp.util.make_text_document_params(0))
  end
  print('LSP buffer synchronized')
end, { desc = 'Force sync current buffer with LSP' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf, noremap = true, silent = true }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', function()
      require('telescope.builtin').lsp_references({
        initial_mode = 'normal',
        layout_strategy = 'horizontal',
        layout_config = { preview_width = 0.55 },
        show_line = false,
      })
    end, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)

    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>rn', function()
      if vim.bo.modified then
        vim.cmd('write')
      end
      vim.defer_fn(vim.lsp.buf.rename, 100)
    end, opts)

    if not pcall(require, 'conform') then
      vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
      end, opts)
    end

    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    if client.name == 'web_html' or client.name == 'web_css' or client.name == 'web_emmet' then
      if client.server_capabilities.documentHighlightProvider then
        local group = vim.api.nvim_create_augroup('lsp_document_highlight_' .. ev.buf, { clear = true })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          group = group,
          buffer = ev.buf,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd('CursorMoved', {
          group = group,
          buffer = ev.buf,
          callback = vim.lsp.buf.clear_references,
        })
      end

      if client.server_capabilities.completionProvider then
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
      end
    end

    if client.name == 'web_html' then
      vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('html_lsp_css_rescan_' .. ev.buf, { clear = true }),
        pattern = { '*.css', '*.scss', '*.less' },
        callback = function()
          if client.server_capabilities.workspaceSymbolProvider then
            vim.lsp.buf.workspace_symbol('')
          end
        end,
      })

      vim.keymap.set('n', '<leader>he', '<Cmd>TelescopeHtmlErrors<CR>', {
        buffer = ev.buf,
        desc = 'Browse HTML errors with Telescope',
      })

      vim.keymap.set('n', 'K', function()
        local diagnostics = vim.diagnostic.get(ev.buf, { lnum = vim.fn.line('.') - 1 })
        if #diagnostics > 0 then
          vim.diagnostic.open_float()
        else
          vim.lsp.buf.hover()
        end
      end, { buffer = ev.buf, desc = 'Show diagnostic info or LSP hover' })
    end
  end,
})
