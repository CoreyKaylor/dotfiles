return {
  -- Fugitive - Premier Git integration
  {
    'tpope/vim-fugitive',
    lazy = true,
    cmd = { 'Git', 'G', 'Gdiff', 'Gwrite', 'Gread', 'Gclog', 'Gblame' },
    keys = {
      { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
      { '<leader>gd', '<cmd>Gdiff<cr>', desc = 'Git diff' },
      { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Git commit' },
      { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
      { '<leader>gl', '<cmd>Gclog<cr>', desc = 'Git log (quickfix)' },
      { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git push' },
      { '<leader>gP', '<cmd>Git pull<cr>', desc = 'Git pull' },
      { '<leader>gf', '<cmd>Git fetch<cr>', desc = 'Git fetch' },
      { '<leader>gr', '<cmd>Gread<cr>', desc = 'Git checkout file' },
      { '<leader>gw', '<cmd>Gwrite<cr>', desc = 'Git add current file' },
      { '<leader>ge', '<cmd>Gedit<cr>', desc = 'Edit git index version' },
      { '<leader>gm', '<cmd>Git merge<cr>', desc = 'Git merge' },
    },
    config = function()
      -- Better statusline integration (show current branch)
      vim.opt.statusline:append('%{FugitiveStatusline()}')
      
      -- Fugitive specific keymaps for Git status window
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'fugitive',
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          -- Stage/unstage file under cursor
          vim.keymap.set('n', '-', '-', opts)
          -- Show inline diff for file under cursor
          vim.keymap.set('n', '=', '=', opts)
          -- Jump to file under cursor
          vim.keymap.set('n', '<cr>', '<cr>', opts)
          -- Open file in new split
          vim.keymap.set('n', 'o', 'O', opts)
          -- Stash operations
          vim.keymap.set('n', 'czz', ':Git stash<cr>', opts)
          vim.keymap.set('n', 'czw', ':Git stash --keep-index<cr>', opts)
          vim.keymap.set('n', 'czA', ':Git stash --include-untracked<cr>', opts)
          vim.keymap.set('n', 'cza', ':Git stash apply<cr>', opts)
          vim.keymap.set('n', 'czp', ':Git stash pop<cr>', opts)
          -- Help
          vim.keymap.set('n', 'g?', 'g?', opts)
        end,
      })
      
      -- Fugitive specific keymaps for Git blame window
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'fugitiveblame',
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          -- Open commit under cursor
          vim.keymap.set('n', '<cr>', '<cr>', opts)
          -- Re-blame at parent commit
          vim.keymap.set('n', '~', '~', opts)
          -- Show commit details
          vim.keymap.set('n', 'o', 'o', opts)
          -- Show commit in split
          vim.keymap.set('n', 'O', 'O', opts)
          -- Close blame window
          vim.keymap.set('n', 'q', 'gq', opts)
        end,
      })
    end,
  },
  
  -- GV - Git commit browser (Gitv replacement)
  {
    'junegunn/gv.vim',
    lazy = true,
    dependencies = { 'tpope/vim-fugitive' },
    cmd = { 'GV' },
    keys = {
      { '<leader>gv', '<cmd>GV<cr>', desc = 'Git history (all)' },
      { '<leader>gV', '<cmd>GV!<cr>', desc = 'Git history (current file)' },
      { '<leader>g?', '<cmd>GV?<cr>', desc = 'Git history (fill location list)' },
    },
    config = function()
      -- GV specific settings
      vim.g.GV_horizontal = 0  -- Vertical split by default
      vim.g.GV_preview_width = 80  -- Preview window width
      
      -- GV specific keymaps
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'GV',
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          -- Open commit in split
          vim.keymap.set('n', 'o', '<cr><c-w>k', opts)
          -- Open commit diff
          vim.keymap.set('n', 'O', 'o<cr>', opts)
          -- Next/prev commit
          vim.keymap.set('n', 'j', 'j', opts)
          vim.keymap.set('n', 'k', 'k', opts)
          -- Checkout commit
          vim.keymap.set('n', 'C', ':Git checkout <c-r><c-w><cr>', opts)
          -- Create branch from commit
          vim.keymap.set('n', 'gb', ':Git branch <space>', opts)
          -- Revert commit
          vim.keymap.set('n', 'r', ':Git revert <c-r><c-w><cr>', opts)
          -- Cherry-pick commit
          vim.keymap.set('n', 'cp', ':Git cherry-pick <c-r><c-w><cr>', opts)
          -- Close GV window
          vim.keymap.set('n', 'q', ':q<cr>', opts)
        end,
      })
    end,
  },
}