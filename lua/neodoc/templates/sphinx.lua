local M = {}

-- Parse parameters string into a table of parameters
local function parse_parameters(params_str)
    if not params_str or params_str == "" then
        return {}
    end
    
    -- Remove parentheses and split by comma
    local params = {}
    
    if type(params_str) ~= "string" then
        vim.notify("Warning: Parameters are not in string format", vim.log.levels.WARN)
        return {}
    end
    
    local clean_params = params_str:gsub("^%(", ""):gsub("%)$", "")
    
    for param in clean_params:gmatch("[^,]+") do
        local param_name, param_type = param:match("([%w_]+)%s*:%s*([^%s,]+)")
        if not param_name then
            param_name = param:match("([%w_]+)")
            param_type = "Any"
        end
        if param_name then
            table.insert(params, {
                name = param_name:match("^%s*(.-)%s*$"),
                type = param_type and param_type:match("^%s*(.-)%s*$") or "Any"
            })
        end
    end
    return params
end

M.generate = function(func_data)
    local params = parse_parameters(func_data.params)
    
    -- Build the docstring
    local lines = {
        '"""',
        "Short description of the function.",
        "",
    }

    -- Add Parameters section if there are parameters
    if #params > 0 then
        for _, param in ipairs(params) do
            table.insert(lines, string.format(":param %s: Description of parameter %s", 
                param.name, param.name))
            table.insert(lines, string.format(":type %s: %s", param.name, param.type))
        end
        table.insert(lines, "")
    end

    -- Add Returns section
    if func_data.return_type and func_data.return_type ~= "None" then
        table.insert(lines, ":returns: Description of return value")
        table.insert(lines, string.format(":rtype: %s", func_data.return_type))
    else
        table.insert(lines, ":returns: None")
        table.insert(lines, ":rtype: None")
    end

    -- Add optional sections commonly used in Sphinx
    table.insert(lines, "")
    table.insert(lines, ":raises: ExceptionName: Description of when this exception is raised")
    table.insert(lines, "")
    table.insert(lines, ".. note::")
    table.insert(lines, "   Additional notes or implementation details can go here.")
    
    -- Close docstring
    table.insert(lines, '"""')
    
    -- Join all lines with proper indentation (no leading spaces)
    return table.concat(lines, "\n")
end

return M
