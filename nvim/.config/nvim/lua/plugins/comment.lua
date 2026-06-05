return {
  'numToStr/Comment.nvim',
  keys = {
    { 'gcc', desc = 'Toggle line comment' },
    { 'gbc', desc = 'Toggle block comment' },
    { 'gc', desc = 'Toggle comment (operator)', mode = { 'n', 'v' } },
    { 'gb', desc = 'Toggle block comment (operator)', mode = { 'n', 'v' } },
  },
  config = function()
    require('Comment').setup({
      -- Add a space b/w comment and the line
      padding = true,
      -- Whether the cursor should stay at its position
      sticky = true,
      -- Lines to be ignored while (un)comment
      ignore = nil,
      -- LHS of toggle mappings in NORMAL mode
      toggler = {
        line = 'gcc', -- Line-comment toggle keymap
        block = 'gbc', -- Block-comment toggle keymap
      },
      -- LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        line = 'gc', -- Line-comment keymap
        block = 'gb', -- Block-comment keymap
      },
      -- LHS of extra mappings
      extra = {
        above = 'gcO', -- Add comment on the line above
        below = 'gco', -- Add comment on the line below
        eol = 'gcA', -- Add comment at the end of line
      },
      -- Enable keybindings
      mappings = {
        basic = true, -- Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        extra = true, -- Extra mapping; `gco`, `gcO`, `gcA`
      },
      -- Function to call before (un)comment
      pre_hook = nil,
      -- Function to call after (un)comment
      post_hook = nil,
    })

    -- Integration with nvim-ts-context-commentstring for better JSX/TSX support
    local ok, ts_context = pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
    if ok then
      require('Comment').setup({
        pre_hook = ts_context.create_pre_hook(),
      })
    end
  end,
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring', -- Better JSX/TSX commenting
  },
}