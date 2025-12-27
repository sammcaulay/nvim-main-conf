-- ==========================================================================
-- KEYMAPS.LUA
-- ==========================================================================

-- 1. BUFFER NAVIGATION
-- Use Shift+L and Shift+H to switch tabs (buffers)
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next Buffer (Tab)" })
vim.keymap.set("n", "<S-h>", ":bprev<CR>", { desc = "Prev Buffer (Tab)" })

-- Close the current buffer (Tab) without closing the window split
-- This mimics 'closing a tab' (Ctrl+W)
vim.keymap.set("n", "<leader>x", ":bp|bd #<CR>", { desc = "Close Current Buffer" })

-- 2. WINDOW NAVIGATION
-- Move between splits (Left, Down, Up, Right) using Ctrl + hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- 3. BETTER INDENTING
-- Stay in visual mode after indenting text with < or >
vim.keymap.set("v", "<", "<gv", { desc = "Indent Left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right" })

-- 4. CLEAR SEARCH HIGHLIGHTS
-- Press Esc to clear search highlighting (very useful)
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear Highlights" })
