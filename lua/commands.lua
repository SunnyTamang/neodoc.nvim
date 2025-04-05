local parser = require("neodoc.parser")
local generator = require("neodoc.generators.template")

vim.api.nvim_create_user_command("GenerateDocstring", function()
    -- Get selected lines
    local start_line, end_line = vim.fn.line("'<"), vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    -- Extract function details
    local func_details = parser.extract_function_signature(lines)
    if func_details then
        -- Generate docstring
        local docstring = generator.generate(func_details)
        vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, docstring)
        print("Docstring generated!")
    else
        print("No valid function found in selection!")
    end
end, {})
