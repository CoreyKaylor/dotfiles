return {
  'junegunn/vim-easy-align',
  keys = {
    { "ga", mode = "n", desc = "Start alignment" },
    { "ga", mode = "v", desc = "Align selection" },
  },
  
  config = function()
    -- Start interactive alignment for normal mode
    vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)', { desc = 'Start alignment' })
    
    -- Start interactive alignment for visual/select mode
    vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)', { desc = 'Align selection' })
    
    -- Define custom alignment rules for better usability
    vim.g.easy_align_delimiters = {
      -- Enhanced rules for common programming patterns
      ['>'] = { pattern = '>>', left_margin = 2, right_margin = 1 },
      ['\\'] = { pattern = [[\\+]], left_margin = 2, right_margin = 0 },
      ['/'] = {
        pattern = [[//+|/\*|\*/]],
        delimiter_align = 'l',
        ignore_groups = {'!Comment'},
      },
      [']'] = {
        left_margin = 0, right_margin = 0,
        stick_to_left = 0
      },
      [')'] = {
        left_margin = 0, right_margin = 0,
        stick_to_left = 0
      },
      ['d'] = {
        pattern = [[ (\S+\s*[;,])@=]],
        left_margin = 0, right_margin = 0
      },
      -- Better table alignment
      ['|'] = {
        pattern = '|',
        left_margin = 1,
        right_margin = 1,
        stick_to_left = 0
      },
      -- Improved equals alignment for assignments
      ['='] = {
        pattern = [[=+]],
        left_margin = 1,
        right_margin = 1,
        stick_to_left = 0
      },
      -- Enhanced colon alignment for hashes/objects
      [':'] = {
        pattern = ':',
        left_margin = 0,
        right_margin = 1,
        stick_to_left = 1
      },
      -- Better arrow alignment for functions/lambdas
      ['-'] = {
        pattern = [[->|=>|<=|>=]],
        left_margin = 1,
        right_margin = 1,
        stick_to_left = 0
      },
      -- Enhanced comma alignment for arrays/parameters
      [','] = {
        pattern = ',',
        left_margin = 0,
        right_margin = 1,
        stick_to_left = 1
      },
      -- Space alignment (useful for columnar text)
      [' '] = {
        pattern = [[ +]],
        left_margin = 0,
        right_margin = 0,
        stick_to_left = 0
      },
      -- Markdown table enhancement
      ['*'] = {
        pattern = [[\*+]],
        left_margin = 0,
        right_margin = 0,
        stick_to_left = 0
      }
    }
    
    -- Enhanced ignore patterns for better alignment
    vim.g.easy_align_ignore_groups = {'Comment', 'String'}
    
    -- Create user commands for convenience
    vim.api.nvim_create_user_command('AlignEquals', function()
      vim.cmd('EasyAlign=')
    end, { 
      desc = 'Align by equals signs',
      range = true 
    })
    
    vim.api.nvim_create_user_command('AlignCommas', function()
      vim.cmd('EasyAlign,')
    end, { 
      desc = 'Align by commas',
      range = true 
    })
    
    vim.api.nvim_create_user_command('AlignTable', function()
      vim.cmd('EasyAlign|')
    end, { 
      desc = 'Align table columns',
      range = true 
    })
    
    vim.api.nvim_create_user_command('AlignColons', function()
      vim.cmd('EasyAlign:')
    end, { 
      desc = 'Align by colons',
      range = true 
    })
    
    vim.api.nvim_create_user_command('AlignArrows', function()
      vim.cmd('EasyAlign-')
    end, { 
      desc = 'Align by arrows/operators',
      range = true 
    })
    
    -- Additional convenience keymaps for common alignments
    vim.keymap.set('v', '<leader>a=', '<Plug>(EasyAlign)=', { desc = 'Align by equals' })
    vim.keymap.set('v', '<leader>a:', '<Plug>(EasyAlign):', { desc = 'Align by colons' })
    vim.keymap.set('v', '<leader>a,', '<Plug>(EasyAlign),', { desc = 'Align by commas' })
    vim.keymap.set('v', '<leader>a|', '<Plug>(EasyAlign)|', { desc = 'Align table columns' })
    vim.keymap.set('v', '<leader>a-', '<Plug>(EasyAlign)-', { desc = 'Align by arrows' })
    vim.keymap.set('v', '<leader>a<space>', '<Plug>(EasyAlign)*<space>', { desc = 'Align by spaces' })
    
    -- Normal mode versions for common alignments on text objects
    vim.keymap.set('n', '<leader>a=', 'ga=', { desc = 'Start alignment by equals', remap = true })
    vim.keymap.set('n', '<leader>a:', 'ga:', { desc = 'Start alignment by colons', remap = true })
    vim.keymap.set('n', '<leader>a,', 'ga,', { desc = 'Start alignment by commas', remap = true })
    vim.keymap.set('n', '<leader>a|', 'ga|', { desc = 'Start alignment by pipes', remap = true })
    vim.keymap.set('n', '<leader>a-', 'ga-', { desc = 'Start alignment by arrows', remap = true })
  end,
}