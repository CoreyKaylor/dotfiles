vim.opt.shortmess="I" --don't launch with splash screen
vim.opt.termguicolors=true --enable true color for UI plugins and color previews
vim.opt.cursorline=true --show the cursor line wherever cursor is located
vim.opt.number=true --always show line numbers
vim.opt.wrap=false --no wrap text on long lines
vim.opt.complete="." --only use current buffer for autocomplete
vim.opt.pumheight=10 --the menu height in lines for autocomplete popup menu

vim.opt.autoindent=true
vim.opt.smartindent=true
vim.opt.tabstop=2 --show two spaces for tabs
vim.opt.shiftwidth=2 -- Indent using two columns
vim.opt.expandtab=true -- Use spaces not tabs

vim.opt.undofile=true --Enable undo files
vim.opt.splitbelow=true --Create new horizontal windows below
vim.opt.splitright=true --Create new vertical windows to the right
vim.opt.hlsearch=true --Highlight search
vim.opt.incsearch=true --Search incrementally, not just on enter
vim.opt.exrc=true --Add support for local .nvim.lua configuration to localize settings if needed
vim.opt.mouse="a" --Enable mouse in all modes

-- Gentler horizontal trackpad scrolling. Ghostty (gtk-horizontal-tab-scroll =
-- false) sends roughly one wheel event per pixel of a sideways swipe, so the
-- default 6 columns per event is far too fast. Scroll one column per event
-- and pass only every `hscroll_events_per_col`th event through to Neovim's
-- own wheel handling (window under the pointer, cursor kept on screen).
vim.opt.mousescroll = "ver:3,hor:1"
local hscroll_events_per_col = 3
local hscroll_pending = 0
local function hscroll(dir, key)
  return function()
    if (hscroll_pending > 0) ~= (dir > 0) then
      hscroll_pending = 0
    end
    hscroll_pending = hscroll_pending + dir
    if math.abs(hscroll_pending) < hscroll_events_per_col then
      return ""
    end
    hscroll_pending = 0
    return key
  end
end
local hscroll_opts = { expr = true, replace_keycodes = true }
vim.keymap.set({ "n", "v", "i" }, "<ScrollWheelRight>", hscroll(1, "<ScrollWheelRight>"),
  vim.tbl_extend("force", hscroll_opts, { desc = "Scroll right (trackpad)" }))
vim.keymap.set({ "n", "v", "i" }, "<ScrollWheelLeft>", hscroll(-1, "<ScrollWheelLeft>"),
  vim.tbl_extend("force", hscroll_opts, { desc = "Scroll left (trackpad)" }))
vim.opt.path=""..vim.fn.getcwd()..","..vim.fn.getcwd().."/**"

vim.opt.winborder='rounded'

vim.g.have_nerd_font = true
