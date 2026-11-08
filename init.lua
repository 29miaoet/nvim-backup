-- Speed up plugin loading
vim.loader.enable()

-- Disable unneeded providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Load personal configuration
require("config.options")
require("config.autocmds")

vim.keymap.set("n", "<leader>r", function()
  require("config.runner").run()
end, { desc = "Run current file" })

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    require("config.lsp")
  end,
})

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

