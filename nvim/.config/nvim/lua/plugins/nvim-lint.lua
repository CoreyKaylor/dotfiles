return {
  'mfussenegger/nvim-lint',
  event = { 'BufWritePost', 'BufReadPost' },
  config = function()
    local lint = require('lint')

    -- Configure linters per filetype
    lint.linters_by_ft = {
      javascript = { 'eslint' },
      typescript = { 'eslint' },
      javascriptreact = { 'eslint' },
      typescriptreact = { 'eslint' },
      python = { 'pylint' },
      kotlin = { 'ktlint' },
      json = { 'jsonlint' },
      yaml = { 'yamllint' },
      dockerfile = { 'hadolint' },
      sh = { 'shellcheck' },
      zsh = { 'shellcheck' },
    }

    -- Customize linter configurations for ESLint
    -- Use npx to prefer local installations and handle ESLint v9+ flat config
    lint.linters.eslint.cmd = 'npx'
    lint.linters.eslint.args = {
      'eslint',
      '--format',
      'json',
      '--stdin',
      '--stdin-filename',
      function()
        -- Use relative path from cwd to avoid "outside base path" issues
        local filepath = vim.api.nvim_buf_get_name(0)
        local cwd = vim.fn.getcwd()
        -- If file is within cwd, use relative path; otherwise use basename
        if vim.startswith(filepath, cwd) then
          return vim.fn.fnamemodify(filepath, ':.')
        else
          return vim.fn.fnamemodify(filepath, ':t')
        end
      end,
    }

    -- ktlint: IntelliJ/Kotlin conventions only (see ktlint.editorconfig).
    -- Project .editorconfig still wins when present; this is the fallback.
    local ktlint_editorconfig = vim.fn.stdpath('config') .. '/ktlint.editorconfig'
    lint.linters.ktlint.args = {
      '--reporter=json',
      '--stdin',
      '--editorconfig=' .. ktlint_editorconfig,
    }

    local function linter_cmd(name)
      local linter = lint.linters[name]
      if type(linter) == 'function' then
        linter = linter()
      end
      local cmd = linter and linter.cmd
      if type(cmd) == 'function' then
        cmd = cmd()
      end
      return cmd
    end

    local function available_linters()
      local names = lint._resolve_linter_by_ft(vim.bo.filetype)
      local available = {}
      for _, name in ipairs(names) do
        local cmd = linter_cmd(name)
        if cmd and vim.fn.executable(cmd) == 1 then
          table.insert(available, name)
        end
      end
      return available
    end

    -- Auto-lint on save and after text changes
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        local names = available_linters()
        if #names > 0 then
          lint.try_lint(names)
        end
      end,
    })

    -- Manual lint command
    vim.api.nvim_create_user_command('Lint', function()
      local names = available_linters()
      if #names > 0 then
        lint.try_lint(names)
      else
        vim.notify('No linters available for ' .. vim.bo.filetype, vim.log.levels.WARN)
      end
    end, { desc = 'Run linter on current buffer' })

    -- BufReadPost already fired to load this plugin. Wait for filetype detection.
    vim.schedule(function()
      local names = available_linters()
      if #names > 0 then
        lint.try_lint(names)
      end
    end)
  end,
}

