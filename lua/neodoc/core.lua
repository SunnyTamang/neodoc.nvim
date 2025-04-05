local M = {}
local utils = require("neodoc.utils")
local config = require("neodoc.config")

-- Get the current docstring template
M.get_template = function()
    local config = require("neodoc.config")
    local custom_template = require("neodoc.custom_template")
    
    -- Check if custom template is enabled
    if config.get_config().use_custom_template then
        -- Try to get the custom template
        local ok, template = pcall(function()
            return custom_template
        end)
        
        -- If we got a valid template with a generate function, use it
        if ok and template and template.generate then
            vim.notify("Using custom template", vim.log.levels.INFO)
            return template
        else
            vim.notify("Custom template is enabled but not available. Falling back to default template.", vim.log.levels.WARN)
        end
    end
    
    -- Get the current style for fallback
    local style = config.get_config().docstring_style
    
    -- Return the appropriate template based on style
    local style_map = {
        google = "neodoc.templates.google",
        numpy = "neodoc.templates.numpy",
        sphinx = "neodoc.templates.sphinx"
    }
    
    local template_path = style_map[style]
    if not template_path then
        vim.notify("Invalid docstring style: " .. style, vim.log.levels.ERROR)
        return nil
    end
    
    local ok, template = pcall(require, template_path)
    if not ok or not template then
        vim.notify("Failed to load template for style: " .. style, vim.log.levels.ERROR)
        return nil
    end
    
    return template
end

-- Find the insertion point for the docstring
M.find_insertion_point = function(bufnr, start_line)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local current_line = start_line
    
    -- Find the function or class definition
    while current_line >= 0 and current_line < #lines do
        local line = lines[current_line + 1]  -- Lua tables are 1-based
        if line and (line:match("^%s*def%s+") or line:match("^%s*class%s+")) then
            -- Get the indentation level of the function/class definition
            local indent = line:match("^(%s*)")
            return current_line, indent
        end
        current_line = current_line - 1
    end
    
    return nil, nil
end

-- Generate docstring for a function
M.generate_docstring = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local start_line = cursor_pos[1] - 1  -- Convert to 0-based index
    
    -- Find the function definition and its indentation
    local func_line, base_indent = M.find_insertion_point(bufnr, start_line)
    if not func_line then
        vim.notify("No function or class definition found above cursor", vim.log.levels.ERROR)
        return
    end
    
    -- Get the function definition line
    local func_def = vim.api.nvim_buf_get_lines(bufnr, func_line, func_line + 1, false)[1]
    
    -- Parse function parameters
    local params = {}
    local return_type = nil
    
    -- Extract parameters from function definition
    local param_str = func_def:match("%b()")
    if param_str then
        -- Remove parentheses
        param_str = param_str:sub(2, -2)
        
        -- Split parameters
        for param in param_str:gmatch("[^,]+") do
            param = param:gsub("^%s*(.-)%s*$", "%1")
            local name, type = param:match("([^:]+):%s*(.+)")
            if name then
                name = name:gsub("^%s*(.-)%s*$", "%1")
                table.insert(params, {name = name, type = type})
            end
        end
        
        -- Extract return type if present
        return_type = func_def:match("%->%s*(%w+)")
    end
    
    -- Get the template
    local template = M.get_template()
    if not template then
        vim.notify("Failed to get docstring template", vim.log.levels.ERROR)
        return
    end
    
    -- Generate docstring using template
    local func_data = {
        name = func_def:match("def%s+(%w+)") or func_def:match("class%s+(%w+)"),
        params = param_str,
        return_type = return_type or "None"
    }
    
    local docstring = template.generate(func_data)
    
    -- Split docstring into lines and add proper indentation
    local doc_lines = {}
    for line in docstring:gmatch("[^\r\n]+") do
        -- Add base indentation plus 4 spaces for docstring content
        table.insert(doc_lines, base_indent .. "    " .. line)
    end
    
    -- Insert docstring after function definition
    vim.api.nvim_buf_set_lines(bufnr, func_line + 1, func_line + 1, false, doc_lines)
    
    vim.notify("Docstring generated successfully", vim.log.levels.INFO)
end

return M 