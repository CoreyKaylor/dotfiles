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
-- Smart quit function - intelligently closes buffer, tab, window, or vim
local function smart_quit()
  local tab_count = vim.fn.tabpagenr('$')
  local win_count = vim.fn.winnr('$')
  local buffer_count = #vim.fn.getbufinfo({buflisted=1})
  
  -- Check if bufferline is showing buffers as tabs
  local has_bufferline = pcall(require, 'bufferline')
  
  if has_bufferline and buffer_count > 1 then
    -- Close current buffer (what appears as a "tab" in bufferline)
    vim.cmd.bdelete()
  elseif tab_count > 1 then
    -- Close current vim tab
    vim.cmd.tabclose()
  elseif win_count > 1 then
    -- Close current window
    vim.cmd.close()
  else
    -- Quit vim
    vim.cmd.quit()
  end
end

vim.keymap.set('n', '<C-q>', smart_quit, { desc = "Smart quit" })

-- Tab management
vim.keymap.set('n', '<C-t>', vim.cmd.tabnew)
vim.keymap.set('n', '<C-p>', vim.cmd.tabprevious)
vim.keymap.set('n', '<C-n>', vim.cmd.tabnext)

-- Alternative tab navigation (for when C-p/C-n conflict with other plugins)
vim.keymap.set('n', '<leader>tn', vim.cmd.tabnext, { desc = "Next tab" })
vim.keymap.set('n', '<leader>tp', vim.cmd.tabprevious, { desc = "Previous tab" })
vim.keymap.set('n', '<leader>tc', vim.cmd.tabclose, { desc = "Close tab" })
vim.keymap.set('n', '<leader>to', vim.cmd.tabonly, { desc = "Close other tabs" })
vim.keymap.set('n', '<leader>tt', vim.cmd.tabnew, { desc = "New tab" })

-- Quick tab switching by number
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt', { desc = "Go to tab " .. i })
end

-- Smart commands for better tab/buffer management
vim.api.nvim_create_user_command('Q', smart_quit, { desc = "Smart quit" })

vim.api.nvim_create_user_command('Qa', function()
  if vim.fn.tabpagenr('$') > 1 then
    local confirm = vim.fn.confirm("Close all tabs?", "&Yes\n&No", 2)
    if confirm == 1 then
      vim.cmd.qall()
    end
  else
    vim.cmd.qall()
  end
end, { desc = "Quit all tabs/windows with confirmation" })

-- Command to close buffer but keep window open (replace with empty buffer)
vim.api.nvim_create_user_command('Bd', function()
  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  
  -- If it's the last buffer in the last tab, create new empty buffer first
  if vim.fn.tabpagenr('$') == 1 and #vim.fn.getbufinfo({buflisted=1}) == 1 then
    vim.cmd.enew()
  end
  
  -- Delete the buffer
  vim.cmd('bdelete ' .. buf)
  print("Closed buffer: " .. (buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":t") or "[No Name]"))
end, { desc = "Close buffer but keep window" })

vim.keymap.set('n', '<S-Left>', vim.cmd.bprevious)
vim.keymap.set('n', '<S-Right>', vim.cmd.bnext)
vim.keymap.set('n', '<S-Up>', ':buffer')
vim.keymap.set('n', '<S-Down>', vim.cmd.buffers)
vim.keymap.set('n', '<S-Del>', vim.cmd.bdelete)

vim.keymap.set('i', '<C-c>', '<Esc>:wa<CR>')
vim.keymap.set('n', '<C-c>', '<Esc>:wa<CR>')
vim.keymap.set('n', '<leader>?', vim.cmd.map)
vim.keymap.set('n', '<leader>s', ':%s/<C-r<C-W>//g<Left><Left>')
vim.keymap.set('n', '<leader>e', ':Lex 30<CR>')
vim.keymap.set('n', '<F3>', ':set list!<CR>')
vim.keymap.set('n', '<F4>', ':set hls!<CR>')

vim.keymap.set('v', '<leader>s', ':s/') --replace
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
