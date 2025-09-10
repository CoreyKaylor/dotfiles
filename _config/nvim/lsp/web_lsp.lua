-- HTML LSP Configuration
local html_config = {
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
        wrapAttributes = 'auto'
      },
      suggest = {
        html5 = true,
        angular1 = false,
        ionic = false
      },
      validate = {
        scripts = true,
        styles = true,
        html = true
      },
      hover = {
        documentation = true,
        references = true
      },
      -- Enable CSS class completion from linked files
      css = {
        enabled = true,
        validate = true
      },
      -- Enable completion for HTML attributes
      completion = {
        attributeDefaultValue = 'doublequotes'
      },
      -- Enable experimental features for better completion
      experimental = {
        customData = {},
        fileExtensions = { '.html', '.htm' }
      }
    }
  },
  -- Custom capabilities for better HTML support
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          resolveSupport = {
            properties = { 'documentation', 'detail', 'additionalTextEdits' }
          }
        }
      }
    },
    -- Add workspace capabilities for file watching
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true
      }
    }
  },
  -- Initialize options for workspace scanning
  init_options = {
    provideFormatter = true,
    embeddedLanguages = {
      css = true,
      javascript = true
    },
    configurationSection = { 'html', 'css', 'javascript' },
    -- Enable workspace scanning for CSS files
    workspace = {
      scan = {
        css = true,
        html = true
      }
    }
  },
  -- Custom handlers for better HTML support
  handlers = {
    -- Let the LSP handle completions normally - nvim-cmp will handle CSS classes
  }
}

-- CSS LSP Configuration
local css_config = {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  settings = {
    css = {
      validate = true,
      completion = {
        completePropertyWithSemicolon = true,
        triggerPropertyValueCompletion = true
      },
      lint = {
        compatibleVendorPrefixes = 'warning',
        vendorPrefix = 'warning',
        duplicateProperties = 'warning',
        emptyRules = 'warning',
        importStatement = 'warning',
        boxModel = 'warning',
        universalSelector = 'warning',
        zeroUnits = 'warning',
        fontFaceProperties = 'warning',
        hexColorLength = 'warning',
        argumentsInColorFunction = 'warning',
        unknownProperties = 'warning',
        ieHack = 'warning',
        unknownVendorSpecificProperties = 'warning',
        propertyIgnoredDueToDisplay = 'warning',
        important = 'warning',
        float = 'warning',
        idSelector = 'warning'
      },
      colorDecorators = {
        enabled = true
      }
    },
    scss = {
      validate = true,
      completion = {
        completePropertyWithSemicolon = true,
        triggerPropertyValueCompletion = true
      },
      lint = {
        compatibleVendorPrefixes = 'warning',
        vendorPrefix = 'warning',
        duplicateProperties = 'warning',
        emptyRules = 'warning',
        importStatement = 'warning',
        boxModel = 'warning',
        universalSelector = 'warning',
        zeroUnits = 'warning',
        fontFaceProperties = 'warning',
        hexColorLength = 'warning',
        argumentsInColorFunction = 'warning',
        unknownProperties = 'warning',
        ieHack = 'warning',
        unknownVendorSpecificProperties = 'warning',
        propertyIgnoredDueToDisplay = 'warning',
        important = 'warning',
        float = 'warning',
        idSelector = 'warning'
      }
    },
    less = {
      validate = true,
      completion = {
        completePropertyWithSemicolon = true,
        triggerPropertyValueCompletion = true
      },
      lint = {
        compatibleVendorPrefixes = 'warning',
        vendorPrefix = 'warning',
        duplicateProperties = 'warning',
        emptyRules = 'warning',
        importStatement = 'warning',
        boxModel = 'warning',
        universalSelector = 'warning',
        zeroUnits = 'warning',
        fontFaceProperties = 'warning',
        hexColorLength = 'warning',
        argumentsInColorFunction = 'warning',
        unknownProperties = 'warning',
        ieHack = 'warning',
        unknownVendorSpecificProperties = 'warning',
        propertyIgnoredDueToDisplay = 'warning',
        important = 'warning',
        float = 'warning',
        idSelector = 'warning'
      }
    }
  },
  -- Custom capabilities for better CSS support
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          resolveSupport = {
            properties = { 'documentation', 'detail', 'additionalTextEdits' }
          }
        }
      }
    }
  },
  -- Initialize options for CSS
  init_options = {
    provideFormatter = true
  }
}

-- Emmet LSP Configuration
local emmet_config = {
  cmd = { 'emmet-ls', '--stdio' },
  filetypes = { 'html', 'css', 'scss', 'less', 'javascriptreact', 'typescriptreact' },
  root_markers = { 'package.json', '.git' },
  settings = {
    emmet = {
      includeLanguages = {
        javascriptreact = 'html',
        typescriptreact = 'html'
      },
      variables = {
        lang = 'en'
      },
      showExpandedAbbreviation = 'always',
      showAbbreviationSuggestions = true,
      syntaxProfiles = {
        html = {
          self_closing_tag = 'xhtml'
        }
      },
      excludeLanguages = {}
    }
  },
  -- Custom capabilities for emmet
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          resolveSupport = {
            properties = { 'documentation', 'detail', 'additionalTextEdits' }
          }
        }
      }
    }
  },
  -- Initialize options for emmet
  init_options = {
    html = {
      options = {
        ['bem.enabled'] = true
      }
    }
  }
}

-- Return all configurations
return {
  html = html_config,
  css = css_config,
  emmet = emmet_config
}