-- Marksman LSP configuration for Markdown files
-- Marksman provides completion, goto definition, find references, 
-- rename refactoring, diagnostics, and more for Markdown documents

return {
  cmd = { 'marksman', 'server' },
  
  filetypes = { 'markdown', 'markdown.mdx' },
  
  -- Root directory detection for project-wide features
  root_markers = { '.marksman.toml', '.git' },
  
  settings = {
    -- No specific settings required for marksman
    -- It works out of the box with sensible defaults
  },
  
  on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    
    -- Set up buffer-local keymaps
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local keymap = vim.keymap.set
    
    -- Navigation
    keymap('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
    keymap('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Find references' }))
    keymap('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
    keymap('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
    keymap('n', 'gt', vim.lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Go to type definition' }))
    
    -- Documentation
    keymap('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
    keymap('n', '<C-k>', vim.lsp.buf.signature_help, vim.tbl_extend('force', opts, { desc = 'Signature help' }))
    
    -- Workspace
    keymap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, vim.tbl_extend('force', opts, { desc = 'Add workspace folder' }))
    keymap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, vim.tbl_extend('force', opts, { desc = 'Remove workspace folder' }))
    keymap('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, vim.tbl_extend('force', opts, { desc = 'List workspace folders' }))
    
    -- Actions
    keymap('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
    keymap({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
    keymap('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, vim.tbl_extend('force', opts, { desc = 'Format document' }))
    
    -- Diagnostics navigation
    keymap('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
    keymap('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
    keymap('n', '<leader>e', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = 'Show diagnostic' }))
    keymap('n', '<leader>q', vim.diagnostic.setloclist, vim.tbl_extend('force', opts, { desc = 'Diagnostics to loclist' }))
    
    -- Markdown-specific features
    -- Marksman provides excellent support for:
    -- - Wiki-style links [[file]] and [[file#heading]]
    -- - Standard markdown links [text](url)
    -- - Reference-style links [text][ref]
    -- - Diagnostics for broken links and duplicate headings
  end,
}