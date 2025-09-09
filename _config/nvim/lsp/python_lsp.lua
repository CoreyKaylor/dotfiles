local M = {}

-- Check which Python LSP server is available
local function find_python_lsp()
  -- Try pylsp first
  local handle = io.popen('which pylsp 2>/dev/null')
  local result = handle:read('*a')
  handle:close()
  
  if result and result ~= '' then
    return 'pylsp', { 'pylsp' }
  end
  
  -- Fallback to pyright
  handle = io.popen('which pyright-langserver 2>/dev/null')
  result = handle:read('*a')
  handle:close()
  
  if result and result ~= '' then
    return 'pyright', { 'pyright-langserver', '--stdio' }
  end
  
  return nil, nil
end

local lsp_name, lsp_cmd = find_python_lsp()

if lsp_name == 'pylsp' then
  return {
    cmd = lsp_cmd,
    
    filetypes = { 'python' },
    
    root_markers = {
      '.git',
      'setup.py',
      'setup.cfg',
      'pyproject.toml',
      'requirements.txt',
      'Pipfile',
      'pyrightconfig.json'
    },
    
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
            enabled = true,
            maxLineLength = 88,
            ignore = {'E203', 'W503'},
          },
          pyflakes = {
            enabled = true,
          },
          pylint = {
            enabled = false,
          },
          pydocstyle = {
            enabled = false,
          },
          autopep8 = {
            enabled = false,
          },
          yapf = {
            enabled = false,
          },
          black = {
            enabled = true,
            line_length = 88,
          },
          isort = {
            enabled = true,
          },
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
          jedi_hover = {
            enabled = true,
          },
          jedi_references = {
            enabled = true,
          },
          jedi_signature_help = {
            enabled = true,
          },
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
    },
  }
elseif lsp_name == 'pyright' then
  return {
    cmd = lsp_cmd,
    
    filetypes = { 'python' },
    
    root_markers = {
      '.git',
      'setup.py',
      'setup.cfg',
      'pyproject.toml',
      'requirements.txt',
      'Pipfile',
      'pyrightconfig.json'
    },
    
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'workspace',
          typeCheckingMode = 'basic',
          autoImportCompletions = true,
        },
      },
    },
  }
else
  -- Return empty config if no Python LSP found
  vim.notify('No Python LSP server found. Please install python-lsp-server (pip install python-lsp-server) or pyright (npm install -g pyright)', vim.log.levels.WARN)
  return {}
end