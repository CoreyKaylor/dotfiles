return {
  cmd = { 'emmet-ls', '--stdio' },
  filetypes = { 'html', 'css', 'scss', 'less', 'javascriptreact', 'typescriptreact', 'vue' },
  root_markers = { 'package.json', '.git' },
  settings = {
    emmet = {
      includeLanguages = {
        javascriptreact = 'html',
        typescriptreact = 'html',
        vue = 'html',
      },
      variables = {
        lang = 'en',
      },
      showExpandedAbbreviation = 'always',
      showAbbreviationSuggestions = true,
      syntaxProfiles = {
        html = {
          self_closing_tag = 'xhtml',
        },
      },
      excludeLanguages = {},
    },
  },
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          resolveSupport = {
            properties = { 'documentation', 'detail', 'additionalTextEdits' },
          },
        },
      },
    },
  },
  init_options = {
    html = {
      options = {
        ['bem.enabled'] = true,
      },
    },
  },
}
