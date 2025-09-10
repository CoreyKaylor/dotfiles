return {
  'mattn/emmet-vim',
  ft = { 'html', 'css', 'scss', 'less', 'javascriptreact', 'typescriptreact', 'vue' },
  init = function()
    -- Emmet configuration
    vim.g.user_emmet_mode = 'i'  -- Enable in insert mode
    vim.g.user_emmet_leader_key = '<C-y>'  -- Leader key for emmet commands
    vim.g.user_emmet_install_global = 0  -- Don't install globally

    -- Enable emmet for specific filetypes
    vim.g.user_emmet_install_command = 'EmmetInstall'

    -- Filetype-specific settings
    vim.g.user_emmet_settings = {
      html = {
        snippets = {
          ['html:5'] = '<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n\t<meta charset=\"UTF-8\">\n\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n\t<title></title>\n</head>\n<body>\n\t${child}\n</body>\n</html>',
        }
      },
      css = {
        snippets = {
          ['bgc'] = 'background-color: #${1:fff};',
          ['bdc'] = 'border: 1px solid #${1:000};',
          ['bxsh'] = 'box-shadow: ${1:0} ${2:0} ${3:0} ${4:#000};',
        }
      },
      javascript = {
        extends = 'jsx'
      },
      typescript = {
        extends = 'jsx'
      }
    }
  end,
  config = function()
    -- Auto-install emmet for supported filetypes
    vim.cmd([[
      augroup EmmetInstall
        autocmd!
        autocmd FileType html,css,scss,less,javascriptreact,typescriptreact EmmetInstall
      augroup END
    ]])
  end,
}