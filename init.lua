-- Speed up plugin loading
vim.loader.enable()

-- Disable unneeded providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Set a line number
vim.opt.number = true

-- Show commands when typing
vim.opt.showcmd = true

-- Automatically choose the appropriate line endings
vim.opt.fileformats = { "unix", "dos", "mac" }


-- Set tab length to 4 spaces, and convert tabs into spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Create a group so autocommands don't duplicate
local tab_adjustments = vim.api.nvim_create_augroup("TabAdjustments", { clear = true })

-- Web Development (2 spaces), soft tab
vim.api.nvim_create_autocmd("FileType", {
  group = tab_adjustments,
  pattern = { 
    "html", "css", "javascript", "typescript", 
    "javascriptreact", "typescriptreact",
    "lua", "ruby", "yml", "yaml", "xml",
    "json"
  },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})


-- Map jj to close insert mode
vim.keymap.set('i', 'jj', '<Esc>', { noremap = true })


-- Restore last cursor position when opening a file
local cursor_group = vim.api.nvim_create_augroup('remember_cursor', { clear = true })

vim.api.nvim_create_autocmd('BufReadPost', {
  group = cursor_group,
  callback = function()
    local line = vim.fn.line('\'"')
    if line > 0 and line <= vim.fn.line('$') then
      vim.cmd('normal! g`"')
    end
  end,
})


-- Visual tweaks
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#FFFF00' })
vim.api.nvim_set_hl(0, 'NonText', { fg = '#0000FF' })
vim.opt.termguicolors = true


-- Bootstrap Lazy and enable plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", {
  rocks = {
    enabled = false,
  },
})


-- Unhighlight matched search text
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- reduce visual noise
vim.opt.fillchars = { eob = " " }


-- Easy method for commenting multiple lines in python
vim.keymap.set("v", "<leader>/", ":s/^/#/<CR>", {
  desc = "Comment selected lines"
})

-- Automatically initialize and save folds
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if pcall(vim.treesitter.get_parser, 0) then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    else
      vim.opt_local.foldmethod = "indent"
    end
    vim.opt.foldlevel = 99
  end,
})

vim.opt.viewoptions:append("folds")

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWinEnter" }, {
  pattern = "*",
  callback = function(args)
    if vim.bo.buftype ~= "" or vim.fn.bufname(args.buf) == "" then
      return
    end

    if args.event == "BufWinLeave" then
      vim.cmd("mkview")
    else
      vim.cmd("silent! loadview")
    end
  end,
})

-- Use PowerShell as Neovim's shell
vim.opt.shell = "pwsh"
vim.opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"

vim.opt.shellquote = ""
vim.opt.shellxquote = ""

-- IntelliSense for Python, TypeScript/JavaScript, and C++
vim.lsp.config("ts_ls", {
  cmd = { "tsc", "--lsp", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
})

vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
})

vim.lsp.config("clangd", {
  cmd = { "clangd" },
  filetypes = {
    "c",
    "cpp",
    "objc",
    "objcpp",
  },
})

-- Enable IntelliSense
vim.lsp.enable("ts_ls")
vim.lsp.enable("basedpyright")
vim.lsp.enable("clangd")

-- Custom behavior for erronous code
vim.diagnostic.config({
  underline = {
    severity = vim.diagnostic.severity.ERROR,
  },

  virtual_text = false,

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },

    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticError",
    },
  },

  severity_sort = true,
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
  undercurl = true,
  sp = "#ff0000",
})

vim.api.nvim_set_hl(0, "DiagnosticError", {
  fg = "#cc1111",
})

-- Map gd to LSP go to definition
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
      buffer = args.buf,
      desc = "LSP: Go to definition",
    })
  end,
})

-- Map K to show diagnostics and leader d to show inferred types
vim.keymap.set("n", "<leader>d", vim.lsp.buf.hover)
vim.keymap.set("n", "K", function()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = line })

  if #diagnostics > 0 then
    vim.diagnostic.open_float()
  else
    vim.lsp.buf.hover()
  end
end)


-- Create a function for running currently open scripts in neovim
local function run_in_terminal(cmd)
  vim.cmd("rightbelow vsplit")

  local terminal_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, terminal_buf)

  vim.fn.termopen(cmd, {
    buffer = terminal_buf,
  })

  vim.cmd("startinsert")
end

-- Remap leader r to trigger the run scripts function
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("write")

  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")

  local commands = {
    cpp = { "pwsh", "-NoExit", "-Command", "cpp '" .. file .. "'" },
    python = { "pwsh", "-NoExit", "-Command", "python '" .. file .. "'" },
    javascript = { "pwsh", "-NoExit", "-Command", "node '" .. file .. "'" },
    typescript = { "pwsh", "-NoExit", "-Command", "tsx '" .. file .. "'" },
    dosbatch = { "cmd", "/k", file },
    ps1 = { "pwsh", "-NoExit", "-File", file },
    html = { "pwsh", "-NoProfile", "-Command", "Start-Process '" .. file .. "'" },
  }

  local cmd = commands[ft]

  if cmd then
    run_in_terminal(cmd)
  else
    print("No runner configured for filetype: " .. ft)
  end
end)


-- Prevent file creation for sensitive information
vim.api.nvim_create_autocmd({"BufReadPre", "BufNewFile"}, {
  pattern = { "C:/Users/ruido/Secure/*", "C:/Users/ruido/Secure/**" },
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.backup = false
    vim.opt_local.writebackup = false
    vim.opt_local.undofile = false
  end,
})


