return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  keys = {
    {
      '<leader>f',
      function()
        local conform = require('conform')
        -- Check if we're in visual mode to format selection
        local mode = vim.fn.mode()
        if mode == 'v' or mode == 'V' or mode == '\22' then -- visual modes
          local result = conform.format({
            async = false,
            lsp_fallback = true,
            timeout_ms = 3000,
            range = {
              start = vim.fn.getpos("'<"),
              ['end'] = vim.fn.getpos("'>"),
            }
          })
          if result then
            vim.notify("Formatted selection", vim.log.levels.INFO)
          end
        else
          local result = conform.format({
            async = false,
            lsp_fallback = true,
            timeout_ms = 3000,
            quiet = false -- Show errors if formatting fails
          })
          if result then
            vim.notify("Formatted buffer", vim.log.levels.INFO)
          end
        end
      end,
      mode = { 'n', 'v' },
      desc = 'Format buffer or selection'
    }
  },
  opts = {
    formatters_by_ft = {
      -- JavaScript/TypeScript
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescriptreact = { 'prettier' },

      -- Web technologies
      json = { 'prettier' },
      jsonc = { 'prettier' },
      html = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      less = { 'prettier' },
      yaml = { 'prettier' },
      markdown = { 'prettier' },

      -- Python
      python = { 'black' },

      -- Kotlin
      kotlin = { 'ktlint' },

      -- Go
      go = { 'gofmt', 'goimports' },

      -- Lua
      lua = { 'stylua' },

      -- Shell
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },

      -- C/C++
      c = { 'clang_format' },
      cpp = { 'clang_format' },

      -- SQL
      sql = { 'sqlformat' },

      -- Rust
      rust = { 'rustfmt' },
    },

    -- Optional: Format on save (can be disabled by setting to false)
    format_on_save = function(bufnr)
      -- Disable format on save for certain filetypes or large files
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local file_size = vim.fn.getfsize(bufname)

      -- Skip formatting for files larger than 1MB
      if file_size > 1024 * 1024 then
        return false
      end

      -- Skip formatting for certain paths
      if bufname:match('/node_modules/') or bufname:match('%.min%.') then
        return false
      end

      return {
        timeout_ms = 1000,
        lsp_fallback = true,
        quiet = true -- Don't show notifications on auto-format
      }
    end,

    formatters = {
      -- Prettier configuration
      prettier = {
        prepend_args = function(_, ctx)
          -- Try to find prettier config in project
          local prettier_config_files = {
            '.prettierrc',
            '.prettierrc.json',
            '.prettierrc.js',
            '.prettierrc.mjs',
            '.prettierrc.cjs',
            '.prettierrc.yaml',
            '.prettierrc.yml',
            'prettier.config.js',
            'prettier.config.mjs',
            'prettier.config.cjs',
          }

          -- Look for config starting from file directory up to project root
          local filepath = ctx.filename
          local dir = vim.fn.fnamemodify(filepath, ':h')

          while dir ~= '/' and dir ~= '' do
            for _, config_file in ipairs(prettier_config_files) do
              if vim.fn.filereadable(dir .. '/' .. config_file) == 1 then
                return { '--config', dir .. '/' .. config_file }
              end
            end
            dir = vim.fn.fnamemodify(dir, ':h')
          end

          -- Default prettier options if no config found
          return {
            '--tab-width', '2',
            '--single-quote',
            '--trailing-comma', 'es5'
          }
        end,
      },

      -- Black configuration
      black = {
        prepend_args = { '--fast', '--line-length', '88' },
      },

      -- Kotlin formatter configuration (using ktlint for both linting and formatting)
      ktlint = {
        command = 'ktlint',
        args = { '--format', '--stdin', '--log-level=none' },
        stdin = true,
      },

      -- Go imports + format
      goimports = {
        prepend_args = { '-local', 'github.com/' },
      },

      -- Stylua for Lua
      stylua = {
        prepend_args = { '--search-parent-directories' },
      },

      -- Shell formatting
      shfmt = {
        prepend_args = { '-i', '2', '-ci' },
      },

      -- Clang format for C/C++
      clang_format = {
        prepend_args = { '--style=Google' },
      },

      -- SQL formatting
      sqlformat = {
        prepend_args = { '--reindent', '--keywords', 'upper', '--identifiers', 'lower' },
      },
    },
  },

  config = function(_, opts)
    local conform = require('conform')
    conform.setup(opts)

    -- Create user command for manual formatting
    vim.api.nvim_create_user_command('Format', function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ['end'] = { args.line2, end_line:len() },
        }
      end
      conform.format({ async = true, lsp_fallback = true, range = range })
    end, { range = true })

    -- Create command to show formatter info
    vim.api.nvim_create_user_command('ConformInfo', function()
      local formatters = conform.list_formatters()
      if #formatters == 0 then
        vim.notify('No formatters available for current filetype', vim.log.levels.WARN)
      else
        local formatter_names = {}
        for _, formatter in ipairs(formatters) do
          table.insert(formatter_names, formatter.name)
        end
        vim.notify('Available formatters: ' .. table.concat(formatter_names, ', '), vim.log.levels.INFO)
      end
    end, {})

    -- Create command to toggle format on save
    vim.api.nvim_create_user_command('FormatToggle', function()
      if conform.will_fallback_lsp() then
        vim.notify('Format on save: enabled (LSP fallback)', vim.log.levels.INFO)
      else
        vim.notify('Format on save: disabled', vim.log.levels.INFO)
      end
    end, {})
  end,
}

