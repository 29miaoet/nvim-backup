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
    "json", "cpp", "c", "objc", "objcpp"
  },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})

-- Automatically initialize and save folds
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

vim.opt.viewoptions = { "folds", "cursor" }

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    local has_parser = lang and pcall(vim.treesitter.get_parser, args.buf, lang)

    if has_parser then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    else
      vim.opt_local.foldmethod = "indent"
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWinEnter" }, {
  pattern = "*",
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.fn.bufname(args.buf) == "" then
      return
    end

    if args.event == "BufWinLeave" then
      vim.cmd("silent! mkview")
    else
      vim.cmd("silent! loadview")
    end
  end,
})

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
