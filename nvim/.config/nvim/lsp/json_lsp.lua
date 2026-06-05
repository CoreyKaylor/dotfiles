return {
  cmd = { 'vscode-json-language-server', '--stdio' },

  filetypes = {
    'json',
    'jsonc',
  },

  root_markers = {
    'package.json',
    '.git',
    'tsconfig.json',
    'jsconfig.json',
    'pyrightconfig.json',
    '.luarc.json',
    '.luarc.jsonc',
  },

  settings = {
    json = {
      -- Enable schema validation
      validate = { enable = true },

      -- Schema configuration
      schemas = {
        -- Package.json schema
        {
          fileMatch = { 'package.json' },
          url = 'https://json.schemastore.org/package.json',
        },
        -- TypeScript config schema
        {
          fileMatch = { 'tsconfig*.json' },
          url = 'https://json.schemastore.org/tsconfig.json',
        },
        -- JavaScript config schema
        {
          fileMatch = { 'jsconfig*.json' },
          url = 'https://json.schemastore.org/jsconfig.json',
        },
        -- Prettier config schema
        {
          fileMatch = {
            '.prettierrc',
            '.prettierrc.json',
            'prettier.config.json',
          },
          url = 'https://json.schemastore.org/prettierrc.json',
        },
        -- ESLint config schema
        {
          fileMatch = {
            '.eslintrc.json',
            '.eslintrc',
          },
          url = 'https://json.schemastore.org/eslintrc.json',
        },
        -- VSCode settings schema
        {
          fileMatch = {
            '.vscode/settings.json',
            '.vscode/launch.json',
          },
          url = 'https://json.schemastore.org/vscode.json',
        },
        -- Pyright config schema
        {
          fileMatch = { 'pyrightconfig.json' },
          url = 'https://raw.githubusercontent.com/microsoft/pyright/main/packages/vscode-pyright/schemas/pyrightconfig.schema.json',
        },
        -- Lua LSP config schema
        {
          fileMatch = {
            '.luarc.json',
            '.luarc.jsonc',
          },
          url = 'https://raw.githubusercontent.com/LuaLS/lua-language-server/master/doc/schema.json',
        },
      },

      -- Format configuration
      format = { enable = true },

      -- Hover configuration
      hover = { enable = true },

      -- Completion configuration
      completion = { enable = true },

      -- Folding configuration
      folding = { enable = true },
    },
  },

  -- Initialize options for jsonls
  init_options = {
    provideFormatter = true,
  },
}