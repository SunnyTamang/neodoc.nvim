--local M = {}
--
--M.generate = function(func_data)
--    return string.format([[
--    """
--    %s
--
--    Args:
--        %s
--
--    Returns:
--        %s
--    """
--    ]], func_data.name, func_data.params, func_data.return_type)
--end
--
--return M
--

--local M = {}

--M.generate = function(func_data)
--    -- Generate formatted arguments list
--    local args_str = ""
--    print(vim.inspect(func_data.params))
--    if func_data.params and #func_data.params > 0 then
--        for _, param in ipairs(func_data.params) do
--            args_str = args_str .. string.format("\t%s: %s\n\t", param.name, param.type)
--        end
--    else
--        args_str = "None\n"  -- If no arguments are present
--    end
--
--    -- Ensure return type is set
--    local return_type = func_data.return_type or "None"
--
--    -- Generate docstring using string.format
--    return string.format([[
--    """
--    Function:
--      %s
--
--    Args:
--      %s
--    Returns:
--      %s
--    """
--]], func_data.name, args_str, return_type)
--end
--
--return M
--


local M = {}

-- Parse parameters string into a table of parameters
local function parse_parameters(params_str)
    local debug_output = "Parameters to parse: "
    
    if type(params_str) ~= "string" then
        vim.notify("Warning: Parameters are not in string format: " .. vim.inspect(params_str), vim.log.levels.WARN)
        return {}
    end
    
    -- Handle nil or empty params
    if not params_str or params_str == "" then
        vim.notify("No parameters found", vim.log.levels.DEBUG)
        return {}
    end
    
    --vim.notify("Parsing parameters: " .. params_str, vim.log.levels.DEBUG)
    
    -- Remove parentheses and split by comma
    local params = {}
    
    -- Remove parentheses safely
    local clean_params = params_str
    
    -- Only perform gsub if params_str is a valid string
    if type(params_str) == "string" then
        clean_params = params_str:gsub("^%(", ""):gsub("%)$", "")
        
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
    end
    
    --vim.notify("Found " .. #params .. " parameters", vim.log.levels.DEBUG)
    return params
end

M.generate = function(func_data)
    -- Validate input
    if not func_data then
        vim.notify("Error: No function data provided", vim.log.levels.ERROR)
        return nil
    end
    
    -- Debug logging
    --vim.notify("Generating docstring for: " .. (func_data.name or "unnamed function"), vim.log.levels.DEBUG)
    
    local params = parse_parameters(func_data.params)
    
    -- Build the docstring
    local lines = {
        '"""',
        (func_data.name or "Unnamed") .. " function.",
        "",
    }

    -- Add Args section if there are parameters
    if #params > 0 then
        table.insert(lines, "Args:")
        for _, param in ipairs(params) do
            table.insert(lines, string.format("    %s (%s): Description of %s.", 
                param.name, param.type, param.name))
        end
        table.insert(lines, "")
    end

    -- Add Returns section
    table.insert(lines, "Returns:")
    if func_data.return_type and func_data.return_type ~= "None" then
        table.insert(lines, string.format("    %s: Description of return value.", 
            func_data.return_type))
    else
        table.insert(lines, "    None")
    end
    
    -- Close docstring
    table.insert(lines, '"""')
    
    -- Join all lines with proper indentation (no leading spaces)
    return table.concat(lines, "\n")
end

return M




