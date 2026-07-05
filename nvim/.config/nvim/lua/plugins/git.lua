return {
  -- DiffBandit - Git-aware diff viewer
  {
    'CoreyKaylor/diffbandit.nvim',
    name = 'diffbandit.nvim',
    lazy = true,
    cmd = {
      'DiffBandit',
      'DiffBanditBuffers',
      'DiffBanditFolderDiff',
      'DiffBanditGit',
      'DiffBanditGitCurrent',
      'DiffBanditCommitPanel',
      'DiffBanditGitMenu',
      'DiffBanditGitLog',
      'DiffBanditGitCommit',
      'DiffBanditGitCompare',
      'DiffBanditGitCheckout',
      'DiffBanditMerge',
      'DiffBanditToggleStageHunk',
      'DiffBanditStageHunk',
      'DiffBanditUnstageHunk',
      'DiffBanditDiscardHunk',
      'DiffBanditApplyLeftHunk',
      'DiffBanditApplyRightHunk',
      'DiffBanditUndo',
    },
    keys = {
      { '<leader>gg', '<cmd>DiffBanditGit<cr>', desc = 'Git changes (DiffBandit)' },
      { '<leader>gG', '<cmd>DiffBanditGitCurrent<cr>', desc = 'Current file changes' },
      { '<leader>gc', '<cmd>DiffBanditCommitPanel<cr>', desc = 'Commit panel' },
      { '<leader>gm', '<cmd>DiffBanditGitMenu<cr>', desc = 'Git menu' },
      { '<leader>gl', '<cmd>DiffBanditGitLog<cr>', desc = 'Git log' },
      { '<leader>gb', '<cmd>DiffBanditGitCompare<cr>', desc = 'Compare refs' },
      { '<leader>gB', '<cmd>DiffBanditGitCheckout<cr>', desc = 'Checkout branch' },
      { '<leader>gM', '<cmd>DiffBanditMerge<cr>', desc = 'Resolve merge conflict' },
    },
    config = function()
      require('diffbandit').setup()
    end,
  },
}
