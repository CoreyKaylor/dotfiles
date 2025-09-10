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

    -- Auto-lint on save and after text changes
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Only lint if we have a linter for this filetype
        local ft = vim.bo.filetype
        if lint.linters_by_ft[ft] then
          lint.try_lint()
        end
      end,
    })

    -- Manual lint command
    vim.api.nvim_create_user_command('Lint', function()
      lint.try_lint()
    end, { desc = 'Run linter on current buffer' })
  end,
}

