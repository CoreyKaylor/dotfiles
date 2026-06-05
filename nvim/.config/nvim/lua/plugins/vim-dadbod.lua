return {
  'tpope/vim-dadbod',
  cmd = { 'DB', 'DBUI', 'DBUIToggle', 'DBUIAddConnection' },
  dependencies = {
    'kristijanhusak/vim-dadbod-ui',
    'kristijanhusak/vim-dadbod-completion',
  },
  config = function()
    vim.g.db_ui_save_location = vim.fn.stdpath('data') .. '/db_ui'
    vim.g.db_ui_use_nerd_fonts = 1
    
    -- Manual database connection examples:
    -- :DB g:my_db = postgresql://user:password@localhost/dbname
    -- :DB g:my_db = mysql://user:password@localhost/dbname
    -- :DB g:my_db = sqlite:///path/to/database.db
    -- 
    -- Then use the connection:
    -- :DB g:my_db SELECT * FROM users
    -- 
    -- Or set a default connection for the buffer:
    -- :DB b:db = g:my_db
    -- :DB SELECT * FROM users
    --
    -- For interactive UI:
    -- :DBUI
    -- :DBUIToggle
    -- :DBUIAddConnection
    
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'sql', 'mysql', 'plsql' },
      callback = function()
        require('cmp').setup.buffer({
          sources = {
            { name = 'vim-dadbod-completion' },
            { name = 'buffer' },
          },
        })
      end,
    })
  end,
}