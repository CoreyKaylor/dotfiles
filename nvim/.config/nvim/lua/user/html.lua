local tidy_namespace = vim.api.nvim_create_namespace('tidy')

local function run_tidy(filename)
  if vim.fn.executable('tidy') ~= 1 then
    return nil, 'tidy is not available'
  end

  if vim.fn.filereadable(filename) ~= 1 then
    return nil, 'file is not readable'
  end

  local result = vim.fn.system({ 'tidy', '-q', '-e', filename })
  return result, nil
end

local function parse_tidy_output(bufnr, output)
  local diagnostics = {}
  local qf_list = {}

  for _, line in ipairs(vim.split(output, '\n', { trimempty = true })) do
    local lnum, col, severity, message = line:match('line (%d+) column (%d+) %- (%w+): (.+)')
    if lnum and message and not message:match('DOCTYPE') and not message:match('inserting "type"') then
      local diag = {
        lnum = tonumber(lnum) - 1,
        col = (tonumber(col) or 1) - 1,
        severity = severity == 'Error' and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
        message = message,
        source = 'tidy',
      }
      table.insert(diagnostics, diag)
      table.insert(qf_list, {
        bufnr = bufnr,
        lnum = diag.lnum + 1,
        col = diag.col + 1,
        text = message,
        type = severity == 'Error' and 'E' or 'W',
      })
    end
  end

  return diagnostics, qf_list
end

vim.api.nvim_create_user_command('HtmlValidate', function()
  local filename = vim.fn.expand('%:p')
  local output, err = run_tidy(filename)

  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  if vim.v.shell_error == 0 then
    vim.notify('HTML validation passed', vim.log.levels.INFO)
    return
  end

  local diagnostics = parse_tidy_output(vim.api.nvim_get_current_buf(), output)
  vim.notify('Found ' .. #diagnostics .. ' HTML validation issues', vim.log.levels.WARN)
end, { desc = 'Validate current HTML file with tidy' })

vim.api.nvim_create_user_command('HtmlValidateWithHighlight', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.fn.expand('%:p')
  local output, err = run_tidy(filename)

  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  if vim.v.shell_error == 0 then
    vim.diagnostic.set(tidy_namespace, bufnr, {})
    vim.fn.setqflist({})
    vim.notify('HTML validation passed', vim.log.levels.INFO)
    return
  end

  local diagnostics, qf_list = parse_tidy_output(bufnr, output)
  vim.diagnostic.set(tidy_namespace, bufnr, diagnostics)
  vim.fn.setqflist(qf_list, 'r')

  if #qf_list > 0 then
    vim.notify('Found ' .. #qf_list .. ' HTML validation issues', vim.log.levels.WARN)
  else
    vim.notify('No validation issues found', vim.log.levels.INFO)
  end
end, { desc = 'Validate current HTML file with tidy diagnostics' })

vim.api.nvim_create_user_command('TelescopeHtmlErrors', function()
  local diagnostics = vim.diagnostic.get(0, { namespace = tidy_namespace })
  if #diagnostics == 0 then
    vim.notify('No HTML validation errors found. Run :HtmlValidateWithHighlight first.', vim.log.levels.INFO)
    return
  end

  local ok = pcall(require, 'telescope')
  if not ok then
    vim.notify('Telescope is not available', vim.log.levels.WARN)
    return
  end

  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers.new({}, {
    prompt_title = 'HTML Validation Errors',
    finder = finders.new_table({
      results = diagnostics,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format('%d:%d %s', entry.lnum + 1, entry.col + 1, entry.message),
          ordinal = string.format('%d:%d %s', entry.lnum + 1, entry.col + 1, entry.message),
          lnum = entry.lnum + 1,
          col = entry.col + 1,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
        end
      end)
      return true
    end,
  }):find()
end, { desc = 'Browse HTML validation errors with Telescope' })
