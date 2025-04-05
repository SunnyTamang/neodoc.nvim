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
        func_data.name,
        string.rep("-", #func_data.name),  -- Underline the function name
        "",
        "Short description of the function.",
        "",
    }

    -- Add Parameters section if there are parameters
    if #params > 0 then
        table.insert(lines, "Parameters")
        table.insert(lines, "----------")
        for _, param in ipairs(params) do
            table.insert(lines, string.format("%s : %s", param.name, param.type))
            table.insert(lines, string.format("    Description of parameter `%s`.", param.name))
        end
        table.insert(lines, "")
    end

    -- Add Returns section
    table.insert(lines, "Returns")
    table.insert(lines, "-------")
    if func_data.return_type and func_data.return_type ~= "None" then
        table.insert(lines, string.format("%s", func_data.return_type))
        table.insert(lines, "    Description of return value.")
    else
        table.insert(lines, "None")
        table.insert(lines, "    This function doesn't return anything.")
    end

    -- Add Examples section (optional but common in NumPy style)
    table.insert(lines, "")
    table.insert(lines, "Examples")
    table.insert(lines, "--------")
    table.insert(lines, ">>> " .. func_data.name .. "()")
    
    -- Close docstring
    table.insert(lines, '"""')
    
    -- Join all lines with proper indentation (no leading spaces)
    return table.concat(lines, "\n")
end

return M
