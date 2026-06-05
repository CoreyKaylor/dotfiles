local disabled = {
  markdown = true,
  markdown_inline = true,
}

local function stop_disabled_treesitter(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local ft = vim.bo[bufnr].filetype
  if disabled[ft] then
    pcall(vim.treesitter.stop, bufnr)
    vim.bo[bufnr].syntax = 'ON'
  end
end

vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('user_disable_markdown_treesitter', { clear = true }),
  pattern = { 'markdown', 'markdown_inline' },
  callback = function(args)
    stop_disabled_treesitter(args.buf)
    vim.schedule(function()
      stop_disabled_treesitter(args.buf)
    end)
  end,
})

for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
  stop_disabled_treesitter(bufnr)
end
