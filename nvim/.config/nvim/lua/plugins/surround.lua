return {
  'kylechui/nvim-surround',
  version = "*", -- Use for stability; omit to use `main` branch for latest features
  keys = {
    -- Normal mode surround operations
    { "ys", mode = "n", desc = "Add surround" },
    { "ds", mode = "n", desc = "Delete surround" },
    { "cs", mode = "n", desc = "Change surround" },
    
    -- Visual mode surround
    { "S", mode = "v", desc = "Surround selection" },
    
    -- Insert mode surround (optional, for better ergonomics)
    { "<C-g>s", mode = "i", desc = "Insert surround" },
    { "<C-g>S", mode = "i", desc = "Insert surround (line)" },
  },
  
  opts = {
    keymaps = {
      -- Normal mode
      insert = "ys",          -- ys{motion}{char} - Add surround
      insert_line = "yss",    -- yss{char} - Surround entire line
      normal = "ys",          -- For text objects
      normal_cur = "yss",     -- Current line
      normal_line = "yS",     -- Entire line with newlines
      normal_cur_line = "ySS", -- Current line with newlines
      
      -- Visual mode
      visual = "S",           -- Visual selection surround
      visual_line = "gS",     -- Visual line surround
      
      -- Delete and change
      delete = "ds",          -- ds{char} - Delete surround
      change = "cs",          -- cs{old}{new} - Change surround
      change_line = "cS",     -- Change line surround
      
      -- Insert mode (for better workflow)
      insert_mode = "<C-g>s", -- Insert mode surround
      insert_mode_line = "<C-g>S", -- Insert mode line surround
    },
    
    -- Custom surrounds for better ergonomics
    surrounds = {
      -- Default pairs (enhanced with better handling)
      ["("] = {
        add = { "(", ")" },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "a(" })
        end,
        delete = "^(.)().-(.)()$",
      },
      [")"] = {
        add = { "( ", " )" },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "a)" })
        end,
        delete = "^(. ?)().-( ?.)()$",
      },
      
      ["["] = {
        add = { "[", "]" },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "a[" })
        end,
        delete = "^(.)().-(.)()$",
      },
      ["]"] = {
        add = { "[ ", " ]" },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "a]" })
        end,
        delete = "^(. ?)().-( ?.)()$",
      },
      
      ["{"] = {
        add = { "{", "}" },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "a{" })
        end,
        delete = "^(.)().-(.)()$",
      },
      ["}"] = {
        add = { "{ ", " }" },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "a}" })
        end,
        delete = "^(. ?)().-( ?.)()$",
      },
      
      -- Enhanced quote handling
      ['"'] = {
        add = { '"', '"' },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = 'a"' })
        end,
        delete = '^(.)().-(.)()$',
      },
      ["'"] = {
        add = { "'", "'" },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "a'" })
        end,
        delete = "^(.)().-(.)()$",
      },
      ["`"] = {
        add = { "`", "`" },
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "a`" })
        end,
        delete = "^(.)().-(.)()$",
      },
      
      -- Programming language specific surrounds
      ["f"] = {
        add = function()
          local config = require("nvim-surround.config")
          local result = config.get_input("Function name: ")
          if result then
            return { result .. "(", ")" }
          end
        end,
        find = function()
          return require("nvim-surround.config").get_selection({ motion = "af" })
        end,
        delete = "^(.-%()().-(%))()$",
        change = {
          target = "^.-([%w_.]+)%(.-%)()()$",
          replacement = function()
            local config = require("nvim-surround.config")
            local result = config.get_input("Function name: ")
            if result then
              return { result .. "(", ")" }
            end
          end,
        },
      },
      
      -- HTML/XML tags - let nvim-surround handle default 't' behavior
      -- The 't' surround is built-in to nvim-surround and works correctly by default
      
      -- Markdown specific
      ["*"] = {
        add = { "*", "*" },
        find = "%*.-=%*",
        delete = "^(.)().-(.)()$",
      },
      ["**"] = {
        add = { "**", "**" },
        find = "%*%*.-=%*%*",
        delete = "^(..)().-(..)()$",
      },
      ["`"] = {
        add = { "`", "`" },
        find = "`.-=`",
        delete = "^(.)().-(.)()$",
      },
      ["```"] = {
        add = function()
          local config = require("nvim-surround.config")
          local result = config.get_input("Language (optional): ")
          return { "```" .. (result or ""), "```" }
        end,
        find = "```.-```",
        delete = "^(```).-\n().-\n(```)()$",
      },
      
      -- LaTeX
      ["$"] = {
        add = { "$", "$" },
        find = "%$.-=%$",
        delete = "^(.)().-(.)()$",
      },
      ["$$"] = {
        add = { "$$", "$$" },
        find = "%$%$.-=%$%$",
        delete = "^(..)().-(..)()$",
      },
      
      -- Common programming constructs
      ["c"] = {
        add = function()
          return { "/* ", " */" }
        end,
        find = "/%*.-=%*/",
        delete = "^(/. ?)().-( ?%*/)()$",
      },
      
      -- Easier access to common surrounds with better mnemonics
      ["p"] = { add = { "(", ")" } },  -- p for parentheses
      ["b"] = { add = { "[", "]" } },  -- b for brackets  
      ["r"] = { add = { "{", "}" } },  -- r for braces (cuRly)
      ["a"] = { add = { "<", ">" } },  -- a for angle brackets
    },
    
    -- Better aliases for common operations
    aliases = {
      ["a"] = ">",     -- a for angle brackets
      ["b"] = "]",     -- b for square brackets
      ["B"] = "}",     -- B for curly braces
      ["r"] = ")",     -- r for round parentheses
      ["q"] = { '"', "'", "`" }, -- q for quotes (any type)
    },
    
    -- Highlight surrounding pairs briefly when added/changed
    highlight = {
      duration = 200,
    },
    
    -- Move cursor to end of added surround
    move_cursor = "begin",
  },
  
  config = function(_, opts)
    require("nvim-surround").setup(opts)
    
    -- Additional keymaps for enhanced workflow
    vim.keymap.set("n", "<leader>s", function()
      -- Quick surround word under cursor with quotes
      vim.cmd("normal! ysiw\"")
    end, { desc = "Surround word with quotes" })
    
    vim.keymap.set("n", "<leader>S", function()
      -- Quick surround word under cursor with parentheses
      vim.cmd("normal! ysiw)")
    end, { desc = "Surround word with parentheses" })
    
    -- Visual mode quick surrounds
    vim.keymap.set("v", "<leader>\"", "S\"<Esc>", { desc = "Surround with quotes" })
    vim.keymap.set("v", "<leader>'", "S'<Esc>", { desc = "Surround with single quotes" })
    vim.keymap.set("v", "<leader>(", "S)<Esc>", { desc = "Surround with parentheses" })
    vim.keymap.set("v", "<leader>[", "S]<Esc>", { desc = "Surround with brackets" })
    vim.keymap.set("v", "<leader>{", "S}<Esc>", { desc = "Surround with braces" })
    
    -- Quick function wrap
    vim.keymap.set("n", "<leader>f", function()
      vim.cmd("normal! ysiwf")
    end, { desc = "Surround word with function call" })
    
    -- Quick tag wrap
    vim.keymap.set("v", "<leader>t", "St<Esc>", { desc = "Surround with HTML tag" })
    
    -- Create user commands for convenience
    vim.api.nvim_create_user_command('SurroundWord', function(opts)
      local char = opts.args
      if char and #char > 0 then
        vim.cmd("normal! ysiw" .. char)
      else
        vim.notify("Usage: :SurroundWord <character>", vim.log.levels.WARN)
      end
    end, { 
      desc = 'Surround word under cursor with specified character',
      nargs = 1,
      complete = function()
        return { '"', "'", '(', ')', '[', ']', '{', '}', '<', '>', '`' }
      end
    })
    
    vim.api.nvim_create_user_command('SurroundLine', function(opts)
      local char = opts.args
      if char and #char > 0 then
        vim.cmd("normal! yss" .. char)
      else
        vim.notify("Usage: :SurroundLine <character>", vim.log.levels.WARN)
      end
    end, { 
      desc = 'Surround entire line with specified character',
      nargs = 1,
      complete = function()
        return { '"', "'", '(', ')', '[', ']', '{', '}', '<', '>', '`' }
      end
    })
  end,
}