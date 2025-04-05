--[[
Custom Template Configuration for NeoDoc
======================================

This file allows you to define your own custom docstring template.
To use your custom template:

1. Set use_custom_template = true in your Neovim config:
   require('neodoc').setup({
       use_custom_template = true
   })

2. Modify the template below using these placeholders:
   - {function_name}    : Name of the function
   - {params}          : Function parameters with types and descriptions
   - {return_type}     : Return type and description
   - {description}     : Function description
   - {class_name}      : Class name (for class methods)
   - {raises}          : Exceptions that might be raised

Example template:
]]

local M = {}

-- Function to generate docstring from template
M.generate = function(func_data)
    -- Extract function information
    local name = func_data.name or "unnamed"
    local params = func_data.params or ""
    local return_type = func_data.return_type or "None"
    
    -- Parse parameters into a formatted string
    local param_lines = {}
    if params ~= "" then
        for param in params:gmatch("[^,]+") do
            param = param:gsub("^%s*(.-)%s*$", "%1")
            local name, type = param:match("([^:]+):%s*(.+)")
            if name then
                name = name:gsub("^%s*(.-)%s*$", "%1")
                table.insert(param_lines, string.format("    %s (%s): ", name, type))
            end
        end
    end
    
    -- Build the docstring skeleton
    local lines = {
        '"""',
        "TODO: Add function description",
        "",
    }
    
    -- Add Parameters section if there are parameters
    if #param_lines > 0 then
        table.insert(lines, "Parameters:")
        table.insert(lines, "----------")
        for _, line in ipairs(param_lines) do
            table.insert(lines, line)
        end
        table.insert(lines, "")
    end
    
    -- Add Returns section
    table.insert(lines, "Returns:")
    table.insert(lines, "-------")
    if return_type ~= "None" then
        table.insert(lines, string.format("    %s: ", return_type))
    else
        table.insert(lines, "    None")
    end
    
    -- Add optional sections
    table.insert(lines, "")
    table.insert(lines, "Raises:")
    table.insert(lines, "------")
    table.insert(lines, "    TODO: Add exceptions that might be raised")
    table.insert(lines, "")
    table.insert(lines, "Examples:")
    table.insert(lines, "--------")
    table.insert(lines, "    >>> TODO: Add example usage")
    
    -- Close docstring
    table.insert(lines, '"""')
    
    -- Join all lines
    return table.concat(lines, "\n")
end

return M 
