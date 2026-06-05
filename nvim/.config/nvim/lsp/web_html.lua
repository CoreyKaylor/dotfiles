return {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = { 'package.json', '.git', 'index.html' },
  settings = {
    html = {
      format = {
        tabSize = 2,
        insertSpaces = true,
        wrapLineLength = 120,
        unformatted = 'wbr',
        contentUnformatted = 'pre,code,textarea',
        indentInnerHtml = false,
        preserveNewLines = true,
        maxPreserveNewLines = 2,
        indentHandlebars = false,
        endWithNewline = false,
        extraLiners = 'head, body, /html',
        wrapAttributes = 'auto',
      },
      suggest = {
        html5 = true,
        angular1 = false,
        ionic = false,
      },
      validate = {
        scripts = true,
        styles = true,
        html = true,
      },
      hover = {
        documentation = true,
        references = true,
      },
      css = {
        enabled = true,
        validate = true,
      },
      completion = {
        attributeDefaultValue = 'doublequotes',
      },
      experimental = {
        customData = {},
        fileExtensions = { '.html', '.htm' },
      },
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
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  init_options = {
    provideFormatter = true,
    embeddedLanguages = {
      css = true,
      javascript = true,
    },
    configurationSection = { 'html', 'css', 'javascript' },
    workspace = {
      scan = {
        css = true,
        html = true,
      },
    },
  },
}
