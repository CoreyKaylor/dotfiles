local lint = {
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
  idSelector = 'warning',
}

local completion = {
  completePropertyWithSemicolon = true,
  triggerPropertyValueCompletion = true,
}

return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  settings = {
    css = {
      validate = true,
      completion = completion,
      lint = lint,
      colorDecorators = {
        enabled = true,
      },
    },
    scss = {
      validate = true,
      completion = completion,
      lint = lint,
    },
    less = {
      validate = true,
      completion = completion,
      lint = lint,
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
    provideFormatter = true,
  },
}
