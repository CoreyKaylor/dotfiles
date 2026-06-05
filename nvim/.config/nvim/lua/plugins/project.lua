return {
  'coffebar/neovim-project',
  lazy = true,
  priority = 100,
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
    { "Shatur/neovim-session-manager" },
  },
  keys = {
    { "<leader>pp", function()
        -- Enhanced project finder with better subfolder handling
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        local themes = require('telescope.themes')
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        
        -- Custom project finder
        local function find_git_projects()
          local projects = {}
          local found_paths = {} -- Track found paths to avoid duplicates
          local search_paths = {
            vim.fn.expand("~/Projects"),
            vim.fn.expand("~/dev"),
            vim.fn.expand("~/work"),
            vim.fn.expand("~/.config"),
          }
          
          -- Project markers to look for (in addition to .git)
          local project_markers = {
            ".git",
            "package.json",
            "Cargo.toml",
            "go.mod",
            "pyproject.toml",
            "requirements.txt", 
            "pom.xml",
            "build.gradle",
            "Makefile",
            "CMakeLists.txt",
            "*.sln",
            "*.csproj",
            ".project",
          }
          
          for _, base_path in ipairs(search_paths) do
            if vim.fn.isdirectory(base_path) == 1 then
              -- Find all project directories up to 3 levels deep
              for _, marker in ipairs(project_markers) do
                local cmd
                if marker == "*.sln" or marker == "*.csproj" then
                  -- Handle wildcards
                  local pattern = string.sub(marker, 3) -- remove "*."
                  cmd = string.format("find %s -maxdepth 3 -name '*.%s' -type f 2>/dev/null", 
                    vim.fn.shellescape(base_path), pattern)
                else
                  cmd = string.format("find %s -maxdepth 3 -name '%s' 2>/dev/null", 
                    vim.fn.shellescape(base_path), marker)
                end
                
                local marker_paths = vim.fn.systemlist(cmd)
                
                for _, marker_path in ipairs(marker_paths) do
                  local project_dir
                  if marker == ".git" then
                    project_dir = vim.fn.fnamemodify(marker_path, ":h")
                  else
                    -- For files, the parent directory is the project
                    project_dir = vim.fn.fnamemodify(marker_path, ":h")
                  end
                  
                  -- Avoid duplicates
                  if not found_paths[project_dir] then
                    found_paths[project_dir] = true
                    
                    local project_name = vim.fn.fnamemodify(project_dir, ":t")
                    local relative_path = vim.fn.fnamemodify(project_dir, ":~")
                    
                    -- Create a nice display name with category
                    local category = ""
                    local icon = "📁"
                    
                    if string.match(project_dir, "/Projects/") then
                      local parts = vim.split(project_dir, "/")
                      for i, part in ipairs(parts) do
                        if part == "Projects" and parts[i + 1] then
                          category = parts[i + 1] .. "/"
                          break
                        end
                      end
                    elseif string.match(project_dir, "/%.config/") then
                      category = "config/"
                      icon = "⚙️"
                    end
                    
                    -- Add project type indicator
                    local type_indicator = ""
                    if vim.fn.filereadable(project_dir .. "/.git/config") == 1 then
                      type_indicator = " (git)"
                    elseif vim.fn.filereadable(project_dir .. "/package.json") == 1 then
                      type_indicator = " (node)"
                    elseif vim.fn.filereadable(project_dir .. "/Cargo.toml") == 1 then
                      type_indicator = " (rust)"
                    elseif vim.fn.filereadable(project_dir .. "/go.mod") == 1 then
                      type_indicator = " (go)"
                    elseif vim.fn.filereadable(project_dir .. "/pyproject.toml") == 1 then
                      type_indicator = " (python)"
                    end
                    
                    table.insert(projects, {
                      name = project_name,
                      path = project_dir,
                      display = string.format("%s %-18s %s%s%s", icon, project_name, category, relative_path, type_indicator),
                      category = category,
                      type_indicator = type_indicator,
                    })
                  end
                end
              end
            end
          end
          
          -- Sort by category, then name
          table.sort(projects, function(a, b)
            if a.category ~= b.category then
              return a.category < b.category
            end
            return a.name < b.name
          end)
          
          return projects
        end
        
        local projects = find_git_projects()
        
        pickers.new(themes.get_dropdown({
          prompt_title = "📁 Projects",
          previewer = false,
          layout_config = {
            width = 0.9,
            height = 0.7,
          },
          -- Enable telescope's default search behavior
          results_title = "Found " .. #projects .. " projects",
        }), {
          finder = finders.new_table({
            results = projects,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.display,
                ordinal = entry.name .. " " .. entry.path .. " " .. entry.category .. (entry.type_indicator or ""),
                path = entry.path, -- For telescope's default actions
              }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            -- Function to switch to project
            local function switch_to_project(close_telescope)
              local selection = action_state.get_selected_entry()
              if close_telescope then
                actions.close(prompt_bufnr)
              end
              
              if selection and selection.value then
                local project_path = selection.value.path
                vim.cmd("cd " .. vim.fn.fnameescape(project_path))
                print("Switched to project: " .. selection.value.name)
                
                -- Try to load session if session manager is available
                local ok, session_manager = pcall(require, "session_manager")
                if ok then
                  pcall(session_manager.load_current_dir_session)
                end
                
                -- Refresh nvim-tree if it's open
                local ok_tree, nvim_tree_api = pcall(require, "nvim-tree.api")
                if ok_tree and nvim_tree_api.tree.is_visible() then
                  nvim_tree_api.tree.change_root(project_path)
                end
              end
            end
            
            -- Default action (Enter)
            actions.select_default:replace(function()
              switch_to_project(true)
            end)
            
            -- Horizontal split (Ctrl-x)
            map('i', '<C-x>', function()
              switch_to_project(true)
              vim.cmd('split')
            end)
            
            -- Vertical split (Ctrl-v) 
            map('i', '<C-v>', function()
              switch_to_project(true)
              vim.cmd('vsplit')
            end)
            
            -- Tab (Ctrl-t)
            map('i', '<C-t>', function()
              switch_to_project(true)
              vim.cmd('tabnew')
            end)
            
            -- Preview project info (Ctrl-p)
            map('i', '<C-p>', function()
              local selection = action_state.get_selected_entry()
              if selection and selection.value then
                local info = string.format(
                  "Project: %s\nPath: %s\nCategory: %s\nType: %s",
                  selection.value.name,
                  selection.value.path,
                  selection.value.category ~= "" and selection.value.category or "none",
                  selection.value.type_indicator or "unknown"
                )
                vim.notify(info, vim.log.levels.INFO, { title = "Project Info" })
              end
            end)
            
            -- Show help (Ctrl-h)
            map('i', '<C-h>', function()
              local help = [[
Enhanced Project Finder - Keymaps:
  <Enter>  - Switch to project (and close)
  <C-x>    - Switch + horizontal split
  <C-v>    - Switch + vertical split  
  <C-t>    - Switch + new tab
  <C-p>    - Show project info
  <C-r>    - Refresh project list
  <C-h>    - Show this help
  <Esc>    - Close without action
  
Type to search by name, path, or category!]]
              vim.notify(help, vim.log.levels.INFO, { title = "Project Finder Help" })
            end)
            
            -- Refresh project list (Ctrl-r)
            map('i', '<C-r>', function()
              -- Close current picker and reopen with fresh data
              actions.close(prompt_bufnr)
              -- Trigger the same function again
              vim.defer_fn(function()
                -- Re-execute the parent function
                local new_projects = find_git_projects()
                if #new_projects > 0 then
                  -- Recreate the picker with new data
                  require('telescope.pickers').new(themes.get_dropdown({
                    prompt_title = "📁 Projects (Refreshed)",
                    previewer = false,
                    layout_config = { width = 0.9, height = 0.7 },
                    results_title = "Found " .. #new_projects .. " projects",
                  }), {
                    finder = finders.new_table({
                      results = new_projects,
                      entry_maker = function(entry)
                        return {
                          value = entry,
                          display = entry.display,
                          ordinal = entry.name .. " " .. entry.path .. " " .. entry.category .. (entry.type_indicator or ""),
                          path = entry.path,
                        }
                      end,
                    }),
                    sorter = conf.generic_sorter({}),
                  }):find()
                end
              end, 100)
            end)
            
            return true
          end,
        }):find()
      end, desc = "Find projects (enhanced)" },
    { "<leader>pP", function() require('telescope').extensions['neovim-project'].discover() end, desc = "Find projects (original)" },
    { "<leader>ph", function() require('telescope').extensions['neovim-project'].history() end, desc = "Recent projects" },
    { "<leader>pr", function() 
        local current_dir = vim.fn.getcwd()
        print("Current directory: " .. current_dir)
      end, desc = "Show current directory" },
    { "<leader>pl", function() require('neovim-project').load_recent_project() end, desc = "Load recent project" },
    { "<leader>ps", function() 
        local scratch_dir = vim.fn.expand("~/Projects/scratch")
        if vim.fn.isdirectory(scratch_dir) == 1 then
          vim.cmd("cd " .. vim.fn.fnameescape(scratch_dir))
          print("Switched to scratch directory")
        else
          print("Scratch directory not found: " .. scratch_dir)
        end
      end, desc = "Go to scratch directory" },
  },
  init = function()
    -- Enable saving sessions for git projects by default
    vim.opt.sessionoptions:append("globals") -- save global variables
    vim.g.neovim_project_discovery_frequency = 2 -- Check for new projects every 2 sessions
  end,
  config = function()
    local neovim_project = require("neovim-project")
    
    neovim_project.setup({
      -- Project directory paths for discovery
      projects = {
        "~/Projects/*/*", -- Look 2 levels deep for nested organization
        "~/Projects/*/*/*", -- Look 3 levels deep for deeply nested projects
        "~/dev/*",
        "~/dev/*/*", -- Also look deeper in dev
        "~/dotfiles",
        "~/work/*",
        "~/work/*/*", -- Also look deeper in work
        "~/.config/*",
      },
      
      -- Auto-detection patterns for project root
      project_detection = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        "pom.xml",
        "requirements.txt",
        "Cargo.toml",
        "pyproject.toml",
        "go.mod",
        ".project",
        "*.sln",
        "*.csproj",
        "composer.json",
        "build.gradle",
        "CMakeLists.txt",
      },
      
      -- Picker to use for project selection
      picker = {
        type = "telescope",
      },
      
      -- Session management integration
      session_manager_opts = {
        autosave_ignore_dirs = {
          vim.fn.expand("~"), -- Don't save sessions for home directory
          "/tmp",
          "/private/tmp",
        },
        autosave_ignore_filetypes = {
          "gitcommit",
          "gitrebase",
        },
        autosave_only_in_session = false, -- Save sessions even if not explicitly loaded
      },
      
      -- Session management integration (handled automatically)
      
      -- Auto-save sessions when leaving projects
      last_session_on_exit = true,
      
      -- Dashboard integration (if using dashboard)
      dashboard_mode = false,
      
      -- Datapath for storing project history
      datapath = vim.fn.stdpath("data"), -- ~/.local/share/nvim
    })
    
    -- Create user commands for easier access
    vim.api.nvim_create_user_command('Projects', function()
      require('telescope').extensions["neovim-project"].discover({})
    end, { desc = "Discover projects" })
    
    vim.api.nvim_create_user_command('ProjectHistory', function()
      require('telescope').extensions["neovim-project"].history({})
    end, { desc = "Recent projects" })
    
    vim.api.nvim_create_user_command('ProjectRoot', function()
      local current_dir = vim.fn.getcwd()
      print("Current directory: " .. current_dir)
    end, { desc = "Show current directory" })
  end,
}