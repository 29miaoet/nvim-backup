return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python", "javascript", "typescript", "cpp", },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
