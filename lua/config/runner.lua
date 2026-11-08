-- Function to run scripts in a split right window
local persistent_term_win = nil

local function run_in_terminal(cmd)
  local win_exists = persistent_term_win
    and vim.api.nvim_win_is_valid(persistent_term_win)

  if not win_exists then
    vim.cmd("rightbelow vsplit")
    persistent_term_win = vim.api.nvim_get_current_win()
  else
    vim.api.nvim_set_current_win(persistent_term_win)
  end

  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(persistent_term_win, term_buf)

  vim.fn.termopen(cmd, {
    buffer = term_buf,
  })

  vim.cmd("wincmd p")
end

local function run()
  vim.cmd("write")

  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")

  local commands = {
    python = { "python", file },
    javascript = { "node", file },
    typescript = { "node", file },
    java = { "java", file },
    ps1 = { "pwsh", "-File", file },
    dosbatch = { "cmd", "/c", file },
    html = { "cmd", "/c", "start", "", file },
    cpp = { "C:\\Users\\ruido\\Desktop\\Code\\C++\\cpp.exe", file },
  }

  local cmd = commands[ft]

  if cmd then
    run_in_terminal(cmd)
  else
    print("No runner configured for filetype: " .. ft)
  end
end

return {
  run = run,
}
