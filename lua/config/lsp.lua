-- LSP configs

-- Servers:
-- Python
-- TypeScript & JavaScript
-- C++ & C
-- Java

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

vim.lsp.config("jdtls", {
  cmd = {
    "C:/Tools/jdtls/bin/jdtls.bat",
  },
  root_markers = { "pom.xml", "build.gradle", ".git" },
})

-- Enable IntelliSense
vim.lsp.enable("ts_ls")
vim.lsp.enable("basedpyright")
vim.lsp.enable("clangd")
vim.lsp.enable("jdtls")

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

