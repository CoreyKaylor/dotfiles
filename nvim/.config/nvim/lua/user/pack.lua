local M = {}

local disabled_builtins = {
  "gzip",
  "matchit",
  "matchparen",
  "netrwPlugin",
  "tarPlugin",
  "tohtml",
  "tutor",
  "zipPlugin",
}

for _, plugin in ipairs(disabled_builtins) do
  vim.g["loaded_" .. plugin] = 1
end

local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
local build_state_dir = vim.fn.stdpath("state") .. "/pack-build"

local specs = {}
local specs_by_name = {}
local loaded = {}
local loading = {}
local key_triggers = {}

M.specs = specs
M.specs_by_name = specs_by_name

local setup_modules = {
  ["Comment.nvim"] = "Comment",
  ["aerial.nvim"] = "aerial",
  ["bufferline.nvim"] = "bufferline",
  ["catppuccin"] = "catppuccin",
  ["colorizer"] = "colorizer",
  ["flash.nvim"] = "flash",
  ["nvim-html-css"] = "html-css",
  ["lualine.nvim"] = "lualine",
  ["nvim-autopairs"] = "nvim-autopairs",
  ["nvim-surround"] = "nvim-surround",
  ["nvim-tree.lua"] = "nvim-tree",
  ["nvim-treesitter"] = "nvim-treesitter.configs",
  ["smart-splits.nvim"] = "smart-splits",
  ["todo-comments.nvim"] = "todo-comments",
  ["trouble.nvim"] = "trouble",
}

local function basename(src)
  local name = src:gsub("%.git$", ""):match("([^/]+)$") or src
  return name
end

local function plugin_src(repo)
  if repo:match("^https?://") or repo:match("^git@") then
    return repo
  end
  return "https://github.com/" .. repo
end

local function list(value)
  if value == nil then
    return {}
  end
  if type(value) == "table" then
    return value
  end
  return { value }
end

local function normalize_key(key)
  if type(key) == "string" then
    return { key }
  end
  return key
end

local function normalize_spec(spec, parent)
  if type(spec) == "string" then
    spec = { spec }
  end

  if type(spec) ~= "table" or type(spec[1]) ~= "string" then
    return nil
  end

  spec.src = plugin_src(spec[1])
  spec.name = spec.name or basename(spec[1])
  spec.parent = parent

  if spec.tag then
    spec.version = spec.tag
  elseif spec.branch then
    spec.version = spec.branch
  elseif spec.version == "*" then
    spec.version = nil
  end

  return spec
end

local function collect_spec(spec, parent)
  local normalized = normalize_spec(spec, parent)
  if not normalized then
    return
  end

  local existing = specs_by_name[normalized.name]
  if existing then
    local should_upgrade = existing.parent and not normalized.parent

    if should_upgrade then
      for key, value in pairs(normalized) do
        existing[key] = value
      end
    elseif not existing.parent or normalized.parent then
      for key, value in pairs(normalized) do
        if existing[key] == nil then
          existing[key] = value
        end
      end
    end

    for _, dependency in ipairs(list(existing.dependencies)) do
      if type(dependency) ~= "table" or not dependency.optional then
        collect_spec(dependency, existing.name)
      end
    end

    return existing
  end

  table.insert(specs, normalized)
  specs_by_name[normalized.name] = normalized

  for _, dependency in ipairs(list(normalized.dependencies)) do
    if type(dependency) ~= "table" or not dependency.optional then
      collect_spec(dependency, normalized.name)
    end
  end

  return normalized
end

local function load_plugin_file(path)
  local module = "plugins." .. vim.fn.fnamemodify(path, ":t:r")
  local ok, plugin_spec = pcall(require, module)
  if not ok then
    vim.notify(("Failed to load %s: %s"):format(module, plugin_spec), vim.log.levels.ERROR)
    return
  end

  if type(plugin_spec) ~= "table" then
    return
  end

  if type(plugin_spec[1]) == "string" then
    collect_spec(plugin_spec)
    return
  end

  for _, child in ipairs(plugin_spec) do
    collect_spec(child)
  end
end

local function run_config(spec)
  if spec.config == false then
    return
  end

  if type(spec.config) == "function" then
    spec.config(spec, spec.opts)
    return
  end

  if spec.opts ~= nil or spec.config == true then
    local module = spec.main or setup_modules[spec.name] or spec.name:gsub("%.nvim$", ""):gsub("%.lua$", "")
    local ok, plugin = pcall(require, module)
    if ok and type(plugin.setup) == "function" then
      plugin.setup(spec.opts or {})
    end
  end
end

local function run_build(spec)
  if spec.build == nil then
    return
  end

  vim.fn.mkdir(build_state_dir, "p")
  local marker = build_state_dir .. "/" .. spec.name:gsub("[^%w_.-]", "_")
  if vim.uv.fs_stat(marker) then
    return
  end

  local plugin_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/" .. spec.name

  local ok, err = pcall(function()
    if type(spec.build) == "function" then
      spec.build()
    elseif type(spec.build) == "string" then
      if spec.build:sub(1, 1) == ":" then
        vim.cmd(spec.build:sub(2))
      else
        vim.system(vim.split(spec.build, "%s+"), { cwd = plugin_path }):wait()
      end
    end
  end)

  if ok then
    vim.fn.writefile({ os.date("!%Y-%m-%dT%H:%M:%SZ") }, marker)
  else
    vim.notify(("Build failed for %s: %s"):format(spec.name, err), vim.log.levels.WARN)
  end
end

local function register_build_hooks()
  vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("PackBuildHooks", { clear = true }),
    callback = function(event)
      local data = event.data or {}
      local pack_spec = data.spec or {}
      local spec = specs_by_name[pack_spec.name]

      if not spec or not spec.build then
        return
      end

      if data.kind ~= "install" and data.kind ~= "update" then
        return
      end

      os.remove(build_state_dir .. "/" .. spec.name:gsub("[^%w_.-]", "_"))

      if not loaded[spec.name] then
        if not data.active then
          vim.cmd.packadd(spec.name)
        end
        run_build(spec)
      else
        run_build(spec)
      end
    end,
  })
end

function M.load(name)
  if loaded[name] then
    return
  end

  local spec = specs_by_name[name]
  if not spec or loading[name] then
    return
  end

  loading[name] = true

  for _, dependency in ipairs(list(spec.dependencies)) do
    if type(dependency) == "table" and dependency.optional then
      goto continue
    end

    local dep = normalize_spec(dependency, spec.name)
    if dep then
      M.load(dep.name)
    end

    ::continue::
  end

  vim.cmd.packadd(spec.name)
  run_build(spec)
  run_config(spec)

  loaded[name] = true
  loading[name] = nil
end

local function should_start_loaded(spec)
  if spec.parent then
    return false
  end
  if spec.lazy == true then
    return false
  end
  if spec.lazy == false then
    return true
  end
  return spec.keys == nil and spec.cmd == nil and spec.ft == nil and spec.event == nil
end

local function command_body(command, opts)
  local pieces = { command }

  if opts.bang then
    pieces[1] = pieces[1] .. "!"
  end

  if opts.range and opts.range > 0 then
    table.insert(pieces, 1, ("%s,%s"):format(opts.line1, opts.line2))
  end

  if opts.args and opts.args ~= "" then
    table.insert(pieces, opts.args)
  end

  return table.concat(pieces, " ")
end

local function register_commands(spec)
  for _, command in ipairs(list(spec.cmd)) do
    if vim.fn.exists(":" .. command) ~= 0 then
      goto continue
    end

    vim.api.nvim_create_user_command(command, function(opts)
      pcall(vim.api.nvim_del_user_command, command)
      M.load(spec.name)
      vim.cmd(command_body(command, opts))
    end, {
      bang = true,
      bar = true,
      complete = "file",
      nargs = "*",
      range = true,
    })

    ::continue::
  end
end

local function feed(lhs, mode)
  local term = vim.api.nvim_replace_termcodes(lhs, true, true, true)
  vim.api.nvim_feedkeys(term, mode == "i" and "i" or "m", false)
end

local function register_keys(spec)
  for _, raw_key in ipairs(list(spec.keys)) do
    local key = normalize_key(raw_key)
    if type(key) ~= "table" then
      goto continue
    end

    local lhs = key[1]
    local rhs = key[2]
    if lhs == nil then
      goto continue
    end

    local modes = key.mode or "n"
    for _, mode in ipairs(list(modes)) do
      key_triggers[lhs] = key_triggers[lhs] or {}
      key_triggers[lhs][mode] = spec.name

      vim.keymap.set(mode, lhs, function()
        if rhs == nil then
          pcall(vim.keymap.del, mode, lhs)
        end

        M.load(spec.name)

        if type(rhs) == "function" then
          rhs()
        elseif type(rhs) == "string" then
          local command = rhs:match("^<cmd>(.*)<cr>$") or rhs:match("^:(.*)<cr>$")
          if command then
            vim.cmd(command)
          else
            feed(rhs, mode)
          end
        else
          feed(lhs, mode)
        end
      end, {
        desc = key.desc,
        expr = key.expr,
        noremap = key.noremap ~= false,
        nowait = key.nowait,
        remap = key.remap,
        silent = key.silent ~= false,
      })
    end

    ::continue::
  end
end

local function register_filetypes(spec)
  for _, filetype in ipairs(list(spec.ft)) do
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("PackFt" .. spec.name:gsub("[^%w]", ""), { clear = false }),
      pattern = filetype,
      callback = function()
        M.load(spec.name)
      end,
    })

    vim.schedule(function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == filetype then
          M.load(spec.name)
          return
        end
      end
    end)
  end
end

local function register_events(spec)
  for _, event in ipairs(list(spec.event)) do
    if event == "VeryLazy" then
      vim.schedule(function()
        M.load(spec.name)
      end)
    else
      vim.api.nvim_create_autocmd(event, {
        group = vim.api.nvim_create_augroup("PackEvent" .. spec.name:gsub("[^%w]", ""), { clear = false }),
        callback = function()
          M.load(spec.name)
        end,
        once = true,
      })
    end
  end
end

local function sorted_start_specs()
  local start_specs = {}
  for _, spec in ipairs(specs) do
    if should_start_loaded(spec) then
      table.insert(start_specs, spec)
    end
  end
  table.sort(start_specs, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)
  return start_specs
end

function M.setup()
  for _, path in ipairs(vim.fn.glob(plugin_dir .. "/*.lua", false, true)) do
    load_plugin_file(path)
  end

  register_build_hooks()

  local pack_specs = {}
  for _, spec in ipairs(specs) do
    table.insert(pack_specs, {
      name = spec.name,
      src = spec.src,
      version = spec.version,
      data = {
        lazy_spec = spec[1],
      },
    })

    if type(spec.init) == "function" then
      spec.init()
    end
  end

  vim.pack.add(pack_specs, {
    confirm = false,
    load = function() end,
  })

  for _, spec in ipairs(specs) do
    register_keys(spec)
    register_commands(spec)
    register_filetypes(spec)
    register_events(spec)
  end

  for _, spec in ipairs(sorted_start_specs()) do
    M.load(spec.name)
  end

  vim.api.nvim_create_user_command("PackStatus", function()
    local installed = vim.pack.get()
    vim.notify(("vim.pack managing %d plugins; %d loaded"):format(#installed, vim.tbl_count(loaded)))
  end, {})

  vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
  end, {})

  vim.api.nvim_create_user_command("PackBuild", function(opts)
    local target = opts.args ~= "" and opts.args or nil
    for _, spec in ipairs(specs) do
      if spec.build and (target == nil or target == spec.name) then
        os.remove(build_state_dir .. "/" .. spec.name:gsub("[^%w_.-]", "_"))
        M.load(spec.name)
        run_build(spec)
      end
    end
  end, {
    complete = function()
      local names = {}
      for _, spec in ipairs(specs) do
        if spec.build then
          table.insert(names, spec.name)
        end
      end
      return names
    end,
    nargs = "?",
  })
end

M.setup()

return M
