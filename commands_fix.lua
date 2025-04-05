M={}
M.setup_commands=function()
  vim.api.nvim_create_user_command("NeoDocDiagnosePython", function()
    print("This is a test")
  end, {})
end
return M