local M = {}

-- Default configuration
M.default_config = {
    docstring_style = "google",
    python_interpreter = vim.fn.executable("python3") == 1 and "python3" or vim.fn.executable("python") == 1 and "python" or "",
    use_custom_template = false,
    enable_keymaps = true,
    keymap = "<leader>d"
}

-- Current configuration
M.config = vim.deepcopy(M.default_config)

-- Function to initialize configuration with user settings
function M.init(user_settings)
    -- Reset to defaults first
    M.config = vim.deepcopy(M.default_config)
    
    if user_settings then
        -- Convert string boolean values to actual booleans
        if type(user_settings.use_custom_template) == "string" then
            user_settings.use_custom_template = user_settings.use_custom_template:lower() == "true"
        end
        if type(user_settings.enable_keymaps) == "string" then
            user_settings.enable_keymaps = user_settings.enable_keymaps:lower() == "true"
        end
        
        -- Merge user settings, overriding defaults
        for key, value in pairs(user_settings) do
            if M.config[key] ~= nil then
                M.config[key] = value
            end
        end
    end
    
    return M.config
end

-- Function to get the current configuration
function M.get_config()
    return M.config
end

-- Function to update a specific configuration value
function M.update_config(key, value)
    if M.config[key] ~= nil then
        M.config[key] = value
        return true
    end
    return false
end

return M 
