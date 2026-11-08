return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      vim.opt.termguicolors = true

      require("catppuccin").setup({
        flavour = "mocha",

        integrations = {
          blink_cmp = false,
          colorful_winsep = false,
          dropbar = false,
          navic = false,
          indent_blankline = false,
          illuminate = false,
          lir = false,
          mini = false,
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
