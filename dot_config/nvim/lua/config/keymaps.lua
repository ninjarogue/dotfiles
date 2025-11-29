-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map kj to escape in insert mode
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })

vim.keymap.set("n", "<leader>cp", function()
  local filepath = vim.fn.expand("%:.") -- :. gives path relative to current working directory
  local line_number = vim.fn.line(".")
  local result = filepath .. ":" .. line_number
  vim.fn.setreg("+", result)
  vim.notify("Copied: " .. result)
end, { desc = "Copy file path:line to clipboard" })

vim.keymap.set("v", "<leader>cP", function()
  local filepath = vim.fn.expand("%:.")
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local result = filepath .. ":" .. start_line .. "-" .. end_line
  vim.fn.setreg("+", result)
  vim.notify("Copied: " .. result)
end, { desc = "Copy file path:line range to clipboard" })

-- Center screen after search navigation
vim.keymap.set("n", "n", "nzz") -- Center after n
vim.keymap.set("n", "N", "Nzz") -- Center after N
