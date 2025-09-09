return {
  cmd = { 'gopls' },

  filetypes = { 
    'go', 
    'gomod', 
    'gowork', 
    'gotmpl' 
  },

  root_markers = { 
    'go.mod', 
    'go.sum', 
    '.git' 
  },

  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
      },
      staticcheck = true,
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
      matcher = 'fuzzy',
      codelenses = {
        generate = true,
        gc_details = true,
        regenerate_cgo = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
        test = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}