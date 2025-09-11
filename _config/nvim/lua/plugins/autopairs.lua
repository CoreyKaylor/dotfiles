return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    check_ts = true,
    ts_config = {
      lua = {'string', 'source'},
      javascript = {'string', 'template_string'},
      typescript = {'string', 'template_string'},
      java = false,
    },
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    disable_in_macro = true,
    disable_in_visualblock = false,
    disable_in_replace_mode = true,
    ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
    enable_moveright = true,
    enable_afterquote = true,
    enable_check_bracket_line = true,
    enable_bracket_in_quote = true,
    enable_abbr = false,
    break_undo = true,
    check_comma = true,
    map_cr = true,
    map_bs = true,
    map_c_h = false,
    map_c_w = false,
  },

  config = function(_, opts)
    local npairs = require('nvim-autopairs')
    npairs.setup(opts)

    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')

    -- Add spaces in bracket pairs
    local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
    npairs.add_rules {
      Rule(' ', ' ')
        :with_pair(function(opts_rule)
          local pair = opts_rule.line:sub(opts_rule.col - 1, opts_rule.col)
          return vim.tbl_contains({
            brackets[1][1] .. brackets[1][2],
            brackets[2][1] .. brackets[2][2],
            brackets[3][1] .. brackets[3][2],
          }, pair)
        end),
    }
    
    for _, bracket in pairs(brackets) do
      npairs.add_rules {
        Rule(bracket[1] .. ' ', ' ' .. bracket[2])
          :with_pair(function() return false end)
          :with_move(function(opts_rule)
            return opts_rule.prev_char:match('.%' .. bracket[2]) ~= nil
          end)
          :use_key(bracket[2])
      }
    end

    -- HTML/XML tag completion
    npairs.add_rules {
      Rule('<', '>')
        :with_pair(cond.before_regex('%a+:?%a*$', 1))
        :with_move(function(opts_rule) return opts_rule.char == '>' end),
    }

    -- HTML tag auto-completion is handled by nvim-ts-autotag plugin
    -- See dependencies section below

    -- Markdown code blocks
    npairs.add_rules {
      Rule('```', '```', {'markdown', 'md'})
        :with_pair(cond.not_after_regex('```'))
    }

    -- Fast wrap with Alt+e keymap
    vim.keymap.set('i', '<M-e>', function()
      local char = vim.fn.nr2char(vim.fn.getchar())
      if char:match('[%(%[%{%"%.%`]') then
        local close_char = ({
          ['('] = ')',
          ['['] = ']',
          ['{'] = '}',
          ['"'] = '"',
          ["'"] = "'",
          ['`'] = '`'
        })[char] or char
        return char .. close_char .. '<Left>'
      end
      return char
    end, { expr = true, desc = 'Fast wrap with pair' })

    -- Integration with completion plugins (cmp)
    local ok, cmp = pcall(require, 'cmp')
    if ok then
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end

    -- Setup nvim-ts-autotag for HTML tag completion
    local ok_autotag, autotag = pcall(require, 'nvim-ts-autotag')
    if ok_autotag then
      autotag.setup({
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = true -- Auto close on trailing </
        },
        filetypes = { "html", "xml", "jsx", "tsx", "vue", "svelte", "javascriptreact", "typescriptreact" },
      })
    end
  end,

  dependencies = {
    'hrsh7th/nvim-cmp', -- Optional cmp integration
    'windwp/nvim-ts-autotag', -- HTML tag auto-completion
  },
}