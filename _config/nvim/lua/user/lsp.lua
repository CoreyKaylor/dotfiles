-- Load LSP configurations
local lsp_configs = {
  'lua_ls',
  'kotlin_lsp',
  'sqls',
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
      vim.lsp.config[lsp_name] = config
      vim.lsp.enable(lsp_name)
    else
      vim.notify('Failed to load LSP config: ' .. lsp_name .. ' - ' .. tostring(config), vim.log.levels.ERROR)
    end
  end
end

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

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf, noremap = true, silent = true }

    -- Navigation keymaps
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
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
  end,
})