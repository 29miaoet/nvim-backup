-- Set a line number
vim.opt.number = true

-- Show commands when typing
vim.opt.showcmd = true

-- Automatically choose the appropriate line endings
vim.opt.fileformats = { "unix", "dos", "mac" }

-- Map jj to close insert mode
vim.keymap.set('i', 'jj', '<Esc>', { noremap = true })

-- Visual tweaks
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#FFFF00' })
vim.api.nvim_set_hl(0, 'NonText', { fg = '#0000FF' })
vim.opt.termguicolors = true

-- Unhighlight matched search text
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- reduce visual noise
vim.opt.fillchars = { eob = " " }


-- Easy method for commenting multiple lines in python
vim.keymap.set("v", "<leader>/", ":s/^/#/<CR>", {
  desc = "Comment selected lines"
})


-- Use PowerShell as Neovim's shell
vim.opt.shell = "pwsh"
vim.opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
vim.opt.shellcmdflag = vim.opt.shellcmdflag:get()
  .. "$PSStyle.OutputRendering = 'PlainText';"

vim.opt.shellpipe = "2>&1| Out-File -Encoding utf8"
vim.opt.shellredir = "| Out-File -Encoding utf8"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
