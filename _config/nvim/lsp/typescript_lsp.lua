return {
  cmd = { 'typescript-language-server', '--stdio' },

  filetypes = { 
    'javascript', 
    'typescript', 
    'javascriptreact', 
    'typescriptreact', 
    'javascript.jsx', 
    'typescript.tsx' 
  },

  root_markers = { 
    'package.json', 
    'tsconfig.json', 
    'jsconfig.json', 
    '.git' 
  },

  settings = {
    typescript = {
      preferences = {
        includePackageJsonAutoImports = 'auto',
        importModuleSpecifierPreference = 'relative',
      },
      suggest = {
        autoImports = true,
        completeFunctionCalls = true,
      },
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      preferences = {
        includePackageJsonAutoImports = 'auto',
        importModuleSpecifierPreference = 'relative',
      },
      suggest = {
        autoImports = true,
        completeFunctionCalls = true,
      },
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
}