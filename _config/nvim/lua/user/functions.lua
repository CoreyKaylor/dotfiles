--go to tag in help
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'help' },
  callback = function(opts)
    vim.keymap.set('n', '<Enter>', '<C-]>')
  end,
})

--autocomplete
--vim.api.nvim_create_autocmd('InsertCharPre', {
--  callback = function(opts)
--    if vim.fn.pumvisible() == 0 then
--      local key = vim.api.nvim_replace_termcodes('<C-n>', true, false, true)
--      vim.api.nvim_feedkeys(key, 'n', false)
--    end
--  end,
--})

--git grep
vim.keymap.set('n', '<leader>g', function()
  local cword = vim.fn.expand('<cword>')
  local git_grep = 'git grep -I -n '..cword
  local cmd = 'system("'..git_grep..'")'
  vim.cmd.lgetexpr(cmd)
  vim.cmd.lopen()
  vim.cmd('/'..cword)
end)

--git ls-files
vim.api.nvim_create_user_command('OpenFile', function(opts)
  local names = "*"
  for arg in opts.args:gmatch("%S+") do
    names = names..arg.."*"
  end
  local git_ls_files = 'git ls-files '..names
  local cmd = 'system("'..git_ls_files..'")'
  vim.cmd.lgetexpr(cmd)
  vim.cmd.lopen()
  local txt = opts.args:gsub('.*%', '')
  vim.cmd('/'..txt)
end,
{ nargs = '+' }
)

vim.keymap.set('n', '<leader>o', ':OpenFile')

vim.keymap.set('n', '<leader>m', function()
  vim.cmd.lgetexpr('system(&makeprg)')
  vim.cmd.lopen()
end)

--clear jumps
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function(opts)
    vim.cmd.clearjumps()
  end,
})
