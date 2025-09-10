return {
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    -- Completion sources
    'hrsh7th/cmp-nvim-lsp',     -- LSP source
    'hrsh7th/cmp-buffer',        -- Buffer source
    'hrsh7th/cmp-path',          -- Path source
    'hrsh7th/cmp-cmdline',       -- Command line source
    'hrsh7th/cmp-nvim-lua',      -- Neovim Lua API
    
    -- Snippet support (required for many LSP features)
    'L3MON4D3/LuaSnip',          -- Snippet engine
    'saadparwaiz1/cmp_luasnip',  -- Snippet source for cmp
    'rafamadriz/friendly-snippets', -- Snippet collection
    
    -- Icons for completion menu
    'onsails/lspkind.nvim',      -- VS Code-like icons
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local lspkind = require('lspkind')
    
    -- Custom source for executables in PATH (for shell scripts)
    local executable_source = {}
    executable_source.new = function()
      return setmetatable({}, { __index = executable_source })
    end
    
    executable_source.is_available = function()
      local ft = vim.bo.filetype
      return ft == 'sh' or ft == 'bash' or ft == 'zsh'
    end
    
    executable_source.get_keyword_pattern = function()
      return [[\k\+]]
    end
    
    executable_source.complete = function(self, params, callback)
      local input = string.sub(params.context.cursor_before_line, params.offset)
      local items = {}
      
      -- Only suggest commands at the start of a line or after certain characters
      local before = params.context.cursor_before_line:sub(1, params.offset - 1)
      local should_complete = before:match('^%s*$') or 
                             before:match('[|&;(]%s*$') or
                             before:match('^%s*sudo%s+$') or
                             before:match('^%s*command%s+$')
      
      if should_complete and input:len() > 0 then
        -- Get executables from PATH
        local paths = vim.split(vim.env.PATH, ':')
        local seen = {}
        
        for _, dir in ipairs(paths) do
          local handle = vim.loop.fs_scandir(dir)
          if handle then
            while true do
              local name, type = vim.loop.fs_scandir_next(handle)
              if not name then break end
              
              if not seen[name] and vim.startswith(name, input) then
                local stat = vim.loop.fs_stat(dir .. '/' .. name)
                if stat and stat.type == 'file' and bit.band(stat.mode, 73) > 0 then -- Check if executable
                  seen[name] = true
                  table.insert(items, {
                    label = name,
                    kind = cmp.lsp.CompletionItemKind.Function,
                    detail = 'Command',
                  })
                end
              end
            end
          end
        end
        
        -- Limit results for performance
        local limited_items = {}
        for i = 1, math.min(#items, 50) do
          limited_items[i] = items[i]
        end
        
        callback({ items = limited_items, isIncomplete = #items > 50 })
      else
        callback({ items = {}, isIncomplete = false })
      end
    end
    
    -- Load snippets from friendly-snippets
    require('luasnip.loaders.from_vscode').lazy_load()
    
    -- Helper function for SuperTab-like behavior
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
    end
    
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      
      mapping = {
        -- Navigation
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Only confirm explicitly selected items
        
        -- SuperTab behavior based on official nvim-cmp documentation
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback() -- Insert tab at beginning of line or after whitespace
          end
        end, { 'i', 's' }),
        
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
        
        -- Additional navigation
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
      },
      
      sources = cmp.config.sources({
        { name = 'html-css' }, -- CSS class completion for HTML
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'nvim_lua' },
      }, {
        { name = 'buffer', keyword_length = 3 },
      }),
      
      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          maxwidth = 50,
          ellipsis_char = '...',
          before = function (entry, vim_item)
            -- Show source in menu
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snippet]',
              buffer = '[Buffer]',
              path = '[Path]',
              relative_path = '[Path]',
              nvim_lua = '[Lua]',
              executables = '[Command]',
              ["html-css"] = '[CSS]',
            })[entry.source.name]
            return vim_item
          end
        }),
      },
      
      -- Experimental features
      experimental = {
        ghost_text = false, -- Disabled - can cause undo history issues
      },
      
      -- Performance
      performance = {
        max_view_entries = 20,
      },
      
      -- Completion behavior
      completion = {
        keyword_length = 2, -- Start completing after 2 characters
        completeopt = 'menu,menuone,noselect',
      },
      
      -- Sorting
      sorting = {
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
    })
    
    -- Enhanced setup for HTML files
    cmp.setup.filetype({ 'html', 'htmldjango', 'tsx', 'jsx', 'vue', 'svelte', 'astro' }, {
      sources = cmp.config.sources({
        { name = 'html-css', priority = 1000 }, -- High priority for CSS classes
        { name = 'nvim_lsp', priority = 900 },
        { name = 'luasnip', priority = 800 },
        { name = 'emmet_ls', priority = 700 }, -- If you have emmet
        { name = 'path', priority = 600 },
      }, {
        { name = 'buffer', keyword_length = 3, priority = 500 },
      }),
      -- Shorter keyword length for HTML files
      completion = {
        keyword_length = 1, -- Start completing after 1 character in HTML
        completeopt = 'menu,menuone,noselect',
      },
    })
    
    -- Setup for specific filetypes
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        { name = 'buffer' },
      })
    })
    
    -- Enhanced setup for shell scripts
    cmp.setup.filetype({ 'sh', 'bash', 'zsh' }, {
      sources = cmp.config.sources({
        { name = 'executables' }, -- Custom PATH executables
        { name = 'path' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer', keyword_length = 2 }, -- Lower threshold for shell scripts
      })
    })
    
    -- Command line setup
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })
    
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    })
    
    -- Configure LuaSnip
    luasnip.config.setup({
      history = true,
      delete_check_events = 'TextChanged',
    })
    
    -- NOTE: Path completion requires explicit path indicators like ./ or ../
    -- For example: use ./_config/ instead of _config/
    -- This is a limitation of the cmp-path plugin which only recognizes
    -- paths that start with /, ./, ../, or ~/
    
    
    -- Add some custom snippets for common patterns
    -- How to use snippets with multiple placeholders:
    -- 1. Type the snippet trigger (e.g., 'local', 'fun', 'lfun')
    -- 2. Press Tab to expand the snippet
    -- 3. Type to replace the first placeholder (e.g., function name)
    -- 4. Press Tab to jump to next placeholder (e.g., arguments)
    -- 5. Type to replace that placeholder
    -- 6. Continue pressing Tab to move through all placeholders
    -- 7. Press Tab after the last placeholder to exit snippet mode
    local ls = require('luasnip')
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    
    -- Lua snippets
    ls.add_snippets('lua', {
      s('local', {
        t('local '),
        i(1, 'name'),
        t(' = '),
        i(2, 'value'),
      }),
      s('fun', {
        t('function '),
        i(1, 'name'),
        t('('),
        i(2, 'args'),
        t(')'),
        t({'', '  '}),
        i(3, '-- body'),
        t({'', 'end'}),
      }),
      s('lfun', {
        t('local function '),
        i(1, 'name'),
        t('('),
        i(2, 'args'),
        t(')'),
        t({'', '  '}),
        i(3, '-- body'),
        t({'', 'end'}),
      }),
      s('req', {
        t('local '),
        i(1, 'name'),
        t(' = require(\''),
        i(2, 'module'),
        t('\')'),
      }),
    })
    
    ls.add_snippets('javascript', {
      s('cl', {
        t('console.log('),
        i(1),
        t(')'),
      }),
      s('fun', {
        t('function '),
        i(1, 'name'),
        t('('),
        i(2, 'args'),
        t(') {'),
        t({'', '  '}),
        i(3, '// body'),
        t({'', '}'}),
      }),
    })
    
    ls.add_snippets('typescript', {
      s('cl', {
        t('console.log('),
        i(1),
        t(')'),
      }),
      s('fun', {
        t('function '),
        i(1, 'name'),
        t('('),
        i(2, 'args'),
        t(': '),
        i(3, 'any'),
        t(') {'),
        t({'', '  '}),
        i(4, '// body'),
        t({'', '}'}),
      }),
    })
    
    ls.add_snippets('python', {
      s('def', {
        t('def '),
        i(1, 'function_name'),
        t('('),
        i(2, 'args'),
        t('):'),
        t({'', '    '}),
        i(3, 'pass'),
      }),
      s('class', {
        t('class '),
        i(1, 'ClassName'),
        t(':'),
        t({'', '    '}),
        i(2, 'pass'),
      }),
      s('if', {
        t('if '),
        i(1, 'condition'),
        t(':'),
        t({'', '    '}),
        i(2, 'pass'),
      }),
      s('for', {
        t('for '),
        i(1, 'item'),
        t(' in '),
        i(2, 'iterable'),
        t(':'),
        t({'', '    '}),
        i(3, 'pass'),
      }),
    })
  end,
}