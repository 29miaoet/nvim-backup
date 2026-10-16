local function uses_prettier(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local directory = vim.fs.dirname(filename)

  local package_json = vim.fs.find("package.json", {
    path = directory,
    upward = true,
  })[1]

  if not package_json then
    return false
  end

  local ok, package = pcall(function()
    return vim.json.decode(
      table.concat(vim.fn.readfile(package_json), "\n")
    )
  end)

  local format_script = ok
    and package
    and package.scripts
    and package.scripts.format

  return type(format_script) == "string"
    and format_script:match("%f[%w]prettier%f[%W]") ~= nil
end

local function js_formatter(bufnr)
  if uses_prettier(bufnr) then
    return { "prettier" }
  end

  return { "biome", "prettier", stop_after_first = true }
end

return {
  "stevearc/conform.nvim",

  event = { "BufWritePre" },
  cmd = { "ConformInfo" },

  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },

  opts = {
    format_on_save = {
      lsp_format = "fallback",
    },

    formatters = {
      prettier = {
        append_args = { "--no-color" },
      },
    },

    formatters_by_ft = {
      python = { "ruff_format" },

      javascript = js_formatter,
      typescript = js_formatter,
      javascriptreact = js_formatter,
      typescriptreact = js_formatter,

      css = js_formatter,
      json = js_formatter,
      jsonc = js_formatter,

      html = { "prettier" },
      scss = { "prettier" },
      markdown = { "prettier" },
      yaml = { "prettier" },
      yml = { "prettier" },
    },
  },
}
