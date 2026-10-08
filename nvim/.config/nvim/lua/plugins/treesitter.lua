-- nvim-treesitter `main`: installs parsers/queries only. Highlighting and
-- indent are started per buffer below; incremental selection is built into
-- Neovim (visual `an`/`in`).
local ensure_installed = {
  "bash",
  "c",
  "html",
  "java",
  "javascript",
  "json",
  "kotlin",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

-- Highlighting stays off for these (see user/treesitter_guard.lua).
local highlight_disabled = { markdown = true, markdown_inline = true }
local indent_disabled = { markdown = true, markdown_inline = true, python = true, yaml = true }

local function map_textobjects()
  local select = require("nvim-treesitter-textobjects.select")
  local move = require("nvim-treesitter-textobjects.move")
  local swap = require("nvim-treesitter-textobjects.swap")

  for lhs, capture in pairs({
    af = "@function.outer",
    ["if"] = "@function.inner",
    ac = "@class.outer",
    ic = "@class.inner",
    aa = "@parameter.outer",
    ia = "@parameter.inner",
  }) do
    vim.keymap.set({ "x", "o" }, lhs, function()
      select.select_textobject(capture, "textobjects")
    end, { desc = "Select " .. capture })
  end

  for lhs, target in pairs({
    ["]f"] = { move.goto_next_start, "@function.outer" },
    ["]c"] = { move.goto_next_start, "@class.outer" },
    ["]F"] = { move.goto_next_end, "@function.outer" },
    ["]C"] = { move.goto_next_end, "@class.outer" },
    ["[f"] = { move.goto_previous_start, "@function.outer" },
    ["[c"] = { move.goto_previous_start, "@class.outer" },
    ["[F"] = { move.goto_previous_end, "@function.outer" },
    ["[C"] = { move.goto_previous_end, "@class.outer" },
  }) do
    vim.keymap.set({ "n", "x", "o" }, lhs, function()
      target[1](target[2], "textobjects")
    end, { desc = "Move to " .. target[2] })
  end

  vim.keymap.set("n", "<leader>a", function()
    swap.swap_next("@parameter.inner")
  end, { desc = "Swap with next parameter" })
  vim.keymap.set("n", "<leader>A", function()
    swap.swap_previous("@parameter.inner")
  end, { desc = "Swap with previous parameter" })
end

local function map_incremental_selection()
  vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Select treesitter node" })
  vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Expand to parent node" })
  vim.keymap.set("x", "<M-space>", "in", { remap = true, desc = "Shrink to child node" })
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- `main` does not support lazy-loading.
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
  },
  config = function()
    local ts = require("nvim-treesitter")
    ts.install(ensure_installed)

    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })
    map_textobjects()
    map_incremental_selection()

    local available = {}
    for _, lang in ipairs(ts.get_available()) do
      available[lang] = true
    end

    local function attach(bufnr, lang)
      if not vim.api.nvim_buf_is_valid(bufnr) or not vim.treesitter.language.add(lang) then
        return
      end
      local ft = vim.bo[bufnr].filetype
      if not highlight_disabled[ft] then
        pcall(vim.treesitter.start, bufnr, lang)
      end
      if not indent_disabled[ft] then
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end
        if vim.treesitter.language.add(lang) then
          attach(args.buf, lang)
        elseif available[lang] then
          -- Equivalent of the old `auto_install = true`.
          ts.install(lang):await(function(err)
            if not err then
              vim.schedule(function()
                attach(args.buf, lang)
              end)
            end
          end)
        end
      end,
    })
  end,
}
