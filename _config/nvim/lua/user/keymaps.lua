vim.g.mapleader=','

vim.keymap.set('n', '<leader>+', vim.cmd.vs) --vertical split
vim.keymap.set('n', '<leader>-', vim.cmd.split) --horizontal split
vim.keymap.set('n', '<C-k>', '<C-w>k') --move up one window
vim.keymap.set('n', '<C-j>', '<C-w>j') --move down one window
vim.keymap.set('n', '<C-h>', '<C-w>h') --move left one window
vim.keymap.set('n', '<C-l>', '<C-w>l') --move right one window
vim.keymap.set('n', '<C-Up>', [[<cmd>horizontal resize + 5<cr>]])
vim.keymap.set('n', '<C-Down>', [[<cmd>horizontal resize - 5<cr>]])
vim.keymap.set('n', '<C-Left>', [[<cmd>vertical resize + 5<cr>]])
vim.keymap.set('n', '<C-Right>', [[<cmd>vertical resize - 5<cr>]])
vim.keymap.set('n', '<C-q>', vim.cmd.quit)

vim.keymap.set('n', '<C-t>', vim.cmd.tabnew)
vim.keymap.set('n', '<C-w>', vim.cmd.tabclose)
vim.keymap.set('n', '<C-p>', vim.cmd.tabprevious)
vim.keymap.set('n', '<C-n>', vim.cmd.tabnext)

vim.keymap.set('n', '<S-Left>', vim.cmd.bprevious)
vim.keymap.set('n', '<S-Right>', vim.cmd.bnext)
vim.keymap.set('n', '<S-Up>', ':buffer')
vim.keymap.set('n', '<S-Down>', vim.cmd.buffers)
vim.keymap.set('n', '<S-Del>', vim.cmd.bdelete)

vim.keymap.set('i', '<Tab>', '<C-x><C-o>')
vim.keymap.set('i', '<C-c>', '<Esc>:wa<CR>')
vim.keymap.set('n', '<C-c>', '<Esc>:wa<CR>')
vim.keymap.set('n', '<leader>?', vim.cmd.map)
vim.keymap.set('n', '<leader>r', ':%s/<C-r<C-W>//g<Left><Left>')
vim.keymap.set('n', '<leader>e', ':Lex 30<CR>')
vim.keymap.set('n', '<F3>', ':set list!<CR>')
vim.keymap.set('n', '<F4>', ':set hls!<CR>')

vim.keymap.set('v', '<leader>r', ':s/') --replace
vim.keymap.set('v', '<leader>y', '"+y') --yank selection to clipboard
vim.keymap.set('v', '<leader>d', '"_d') --delete selection into void register
vim.keymap.set('v', '<leader>p', '_dP') --delete selection into the void register and paste over it

vim.keymap.set('n', 'J', 'mzJ`z') --join the next line keeping cursor position
vim.keymap.set('n', '<C-u>', '<C-u>M') --scroll up half page keep cursor in the middle
vim.keymap.set('n', '<C-d>', '<C-d>M') --scroll down half page keeping cursor in the middle
vim.keymap.set('n', 'n', 'nzzzv') --search forward keeping cursor in the middle
vim.keymap.set('n', 'N', 'Nzzzv') --search backwards keeping cursor in the middle
vim.keymap.set('n', '*', '*nzzv') --search word under cursor keeping cursor in the middle

vim.keymap.set('n', '<C-PageUp>', vim.cmd.lprev)
vim.keymap.set('n', '<C-PageDown>', vim.cmd.lnext)

vim.keymap.set('n', '<Up>', '<Nop>')
vim.keymap.set('n', '<Down>', '<Nop>')
vim.keymap.set('n', '<Left>', '<Nop>')
vim.keymap.set('n', '<Right>', '<Nop>')
