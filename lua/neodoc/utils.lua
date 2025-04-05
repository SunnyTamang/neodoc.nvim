local M = {}

-- Function to check if a string is empty or nil
function M.is_empty(str)
    return str == nil or str == ""
end

-- Function to capitalize first letter of a string
function M.capitalize(str)
    if M.is_empty(str) then return str end
    return str:sub(1,1):upper() .. str:sub(2)
end

-- Function to convert string to boolean
function M.str_to_bool(str)
    if type(str) == "string" then
        return str:lower() == "true"
    end
    return str
end

-- Function to get valid docstring styles
function M.get_valid_styles()
    return {
        google = true,
        numpy = true,
        sphinx = true
    }
end

-- Function to validate docstring style
function M.is_valid_style(style)
    local valid_styles = M.get_valid_styles()
    return valid_styles[style:lower()] or false
end

-- Function to get sample function data for previews
function M.get_sample_function()
    return {
        name = "sample_function",
        params = "(param1: int, param2: str, param3: List[float])",
        return_type = "Dict[str, Any]",
        body = "    result = {}\n    for i, p in enumerate(param3):\n        result[param2 + str(i)] = param1 * p\n    return result"
    }
end

-- Function to create a centered window
function M.create_centered_window(width, height, title)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local win_opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = title,
        title_pos = "center"
    }
    
    return win_opts
end

return M 