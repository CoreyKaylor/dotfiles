return {
  -- Markdown preview plugin with live updates
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreview<cr>', desc = 'Start markdown preview' },
      { '<leader>ms', '<cmd>MarkdownPreviewStop<cr>', desc = 'Stop markdown preview' },
      { '<leader>mt', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Toggle markdown preview' },
    },
    init = function()
      -- Set browser to open preview in
      vim.g.mkdp_browser = ''
      
      -- Don't auto close when switching buffers
      vim.g.mkdp_auto_close = 0
      
      -- Refresh on save only (not on text change in normal/insert mode)
      vim.g.mkdp_refresh_slow = 0
      
      -- Preview server port
      vim.g.mkdp_port = ''
      
      -- Echo preview url in command line
      vim.g.mkdp_echo_preview_url = 1
      
      -- Custom function to open preview in vertical split (browser-based preview)
      -- For vertical split behavior, we'll use browser preview but position window
      vim.g.mkdp_browserfunc = ''
      
      -- Preview options
      vim.g.mkdp_preview_options = {
        mkit = {},                -- markdown-it options
        katex = {},                -- KaTeX options
        uml = {},                  -- plantuml options
        maid = {},                 -- mermaid options
        disable_sync_scroll = 0,  -- disable sync scroll
        sync_scroll_type = 'middle', -- 'middle', 'top' or 'relative'
        hide_yaml_meta = 1,        -- hide yaml metadata
        sequence_diagrams = {},    -- js-sequence-diagrams options
        flowchart_diagrams = {},   -- flowchart options
        content_editable = false,  -- make preview editable
        disable_filename = 0,      -- disable filename header
        toc = {}                   -- table of contents options
      }
      
      -- Recognized filetypes
      vim.g.mkdp_filetypes = { 'markdown' }
      
      -- Use a custom markdown style (can point to local CSS file)
      vim.g.mkdp_markdown_css = ''
      
      -- Use a custom highlight style (must be absolute path)
      vim.g.mkdp_highlight_css = ''
      
      -- Custom page title
      vim.g.mkdp_page_title = '「${name}」'
      
      -- Auto start when entering markdown buffer
      vim.g.mkdp_auto_start = 0
      
      -- Combine preview windows
      vim.g.mkdp_combine_preview = 0
      
      -- Auto refresh when save any file
      vim.g.mkdp_combine_preview_auto_refresh = 1
    end,
  },
  
  -- Table of contents generation
  {
    'mzlogin/vim-markdown-toc',
    ft = { 'markdown' },
    cmd = { 'GenTocGFM', 'GenTocRedcarpet', 'GenTocGitLab', 'GenTocMarked', 'UpdateToc', 'RemoveToc' },
    keys = {
      { '<leader>mtc', '<cmd>GenTocGFM<cr>', desc = 'Generate GitHub-flavored TOC' },
      { '<leader>mtu', '<cmd>UpdateToc<cr>', desc = 'Update existing TOC' },
      { '<leader>mtr', '<cmd>RemoveToc<cr>', desc = 'Remove TOC' },
    },
  },
  
  -- Better markdown syntax and concealing
  {
    'preservim/vim-markdown',
    ft = { 'markdown' },
    dependencies = { 'godlygeek/tabular' },
    init = function()
      -- Disable folding
      vim.g.vim_markdown_folding_disabled = 1
      
      -- Enable TOC window auto-fit
      vim.g.vim_markdown_toc_autofit = 1
      
      -- Enable strikethrough with ~~
      vim.g.vim_markdown_strikethrough = 1
      
      -- Set header folding level
      vim.g.vim_markdown_folding_level = 6
      
      -- Enable YAML front matter
      vim.g.vim_markdown_frontmatter = 1
      
      -- Enable TOML front matter
      vim.g.vim_markdown_toml_frontmatter = 1
      
      -- Enable JSON front matter
      vim.g.vim_markdown_json_frontmatter = 1
      
      -- Do not require .md extension for links
      vim.g.vim_markdown_no_extensions_in_markdown = 1
      
      -- Auto-write when following links
      vim.g.vim_markdown_autowrite = 1
      
      -- Enable math
      vim.g.vim_markdown_math = 1
      
      -- Follow named anchors
      vim.g.vim_markdown_follow_anchor = 1
      
      -- Don't indent new lines in lists
      vim.g.vim_markdown_new_list_item_indent = 0
    end,
  },
  
  -- Markview.nvim for embedded preview with split view
  {
    'OXY2DEV/markview.nvim',
    lazy = true,  -- Only load when explicitly called
    cmd = { 'Markview' },  -- Load on Markview commands
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>mv', '<cmd>Markview splitToggle<cr>', desc = 'Toggle markdown split preview (right side)' },
      { '<leader>mo', '<cmd>Markview splitOpen<cr>', desc = 'Open markdown split preview' },
      { 
        '<leader>mc', 
        function()
          -- Close the split preview
          vim.cmd('Markview splitClose')
          -- Return focus to the original window (left side)
          vim.cmd('wincmd h')
        end,
        desc = 'Close markdown split preview' 
      },
      { '<leader>mr', '<cmd>Markview splitRedraw<cr>', desc = 'Redraw markdown split preview' },
      { '<leader>mh', '<cmd>Markview toggle<cr>', desc = 'Toggle inline preview (current buffer)' },
    },
    config = function()
      -- Ensure markview doesn't auto-enable on markdown files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'markdown', 'markdown.mdx' },
        callback = function()
          vim.cmd('Markview disable')
        end,
      })
      
      require('markview').setup({
        -- Disable preview by default (only show in split)
        enable = false,
        
        -- Maximum file size to process (in KB)
        max_file_size = 1000,
        
        -- Preview settings (contains all preview-related configuration)
        preview = {
          -- Modes where markview is active (empty to prevent auto-activation)
          modes = {},
          
          -- Hybrid mode allows editing while seeing preview (empty by default)
          hybrid_modes = {},
          
          -- Filetypes to enable markview
          filetypes = { 'markdown', 'markdown.mdx', 'quarto', 'rmd' },
          
          -- Buffer types to ignore
          ignore_buftypes = { 'nofile' },
          
          -- Split view configuration for vertical right split
          splitview_winopts = {
            split = 'right',  -- Open preview in vertical split on the right
            width = 80,       -- Width of the preview window
            relative = '',    -- Use normal split, not floating window
          },
          
          -- Callbacks for split view events
          callbacks = {
            on_enable = function(_, win)
              vim.wo[win].conceallevel = 2
              vim.wo[win].concealcursor = 'nc'
              vim.wo[win].wrap = true
              vim.wo[win].number = false
              vim.wo[win].relativenumber = false
              vim.wo[win].signcolumn = 'no'
              vim.wo[win].foldcolumn = '0'
              vim.wo[win].cursorline = false
            end,
            on_disable = function(_, win)
              vim.wo[win].conceallevel = 0
              vim.wo[win].concealcursor = ''
            end,
          },
        },
        
        -- Markdown-specific rendering options
        markdown = {
          -- Table rendering options
          tables = {
            enable = true,
            block_decorator = true,
            use_virt_lines = true,
          },
          
          -- List rendering options
          list_items = {
            enable = true,
            shift_amount = 2,
          },
          
          -- Heading rendering
          headings = {
            enable = true,
            shift_width = 0,
          },
        },
        
        -- Rendering options
        render = {
          -- Enable rendering for different elements
          enable = true,
        },
        
        -- Checkbox rendering
        checkboxes = {
          enable = true,
          checked = { text = '✓', hl = 'MarkviewCheckboxChecked' },
          unchecked = { text = '✗', hl = 'MarkviewCheckboxUnchecked' },
        },
        
        -- Code block rendering
        code_blocks = {
          enable = true,
          style = 'simple',
          border_hl = 'MarkviewCode',  -- Changed from 'hl' to 'border_hl'
        },
        
        -- Inline code rendering
        inline_codes = {
          enable = true,
          hl = 'MarkviewInlineCode',
        },
        
        -- Link rendering
        links = {
          enable = true,
          hyperlinks = {
            enable = true,
            hl = 'MarkviewHyperlink',
          },
          images = {
            enable = true,
            hl = 'MarkviewImageLink',
          },
        },
      })
    end,
  },
}