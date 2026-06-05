local use_pylsp = vim.fn.executable('pylsp') == 1

local config = {
  cmd = use_pylsp and { 'pylsp' } or { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    '.git',
    'setup.py',
    'setup.cfg',
    'pyproject.toml',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
  },
}

if use_pylsp then
  config.settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          enabled = true,
          maxLineLength = 88,
          ignore = { 'E203', 'W503' },
        },
        pyflakes = { enabled = true },
        pylint = { enabled = false },
        pydocstyle = { enabled = false },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        black = {
          enabled = true,
          line_length = 88,
        },
        isort = { enabled = true },
        mypy = {
          enabled = false,
          live_mode = false,
        },
        jedi_completion = {
          enabled = true,
          fuzzy = true,
        },
        jedi_definition = {
          enabled = true,
          follow_imports = true,
          follow_builtin_imports = true,
        },
        jedi_hover = { enabled = true },
        jedi_references = { enabled = true },
        jedi_signature_help = { enabled = true },
        jedi_symbols = {
          enabled = true,
          all_scopes = true,
          include_import_symbols = true,
        },
        mccabe = {
          enabled = true,
          threshold = 10,
        },
      },
    },
  }
else
  config.settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
        typeCheckingMode = 'basic',
        autoImportCompletions = true,
      },
    },
  }
end

return config
