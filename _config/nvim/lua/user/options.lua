vim.opt.shortmess="I" --don't launch with splash screen
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
vim.opt.mouse="" --Disable mouse
vim.opt.path=""..vim.fn.getcwd()..","..vim.fn.getcwd().."/**"

vim.opt.winborder=rounded

