local M = {}

M.setup = function(opts)
    -- Import modules
    local config = require("neodoc.config")
    local commands = require("neodoc.commands")
    
    -- Initialize configuration
    config.init(opts)
    
    -- Setup commands and keymaps
    commands.setup_commands()
    commands.setup_keymaps()
    
    -- Log initialization
    --vim.notify("NeoDoc initialized with template-based generation", vim.log.levels.INFO)
    
    return M
end

-- Helper function to set docstring style
M.set_style = function(style)
    local config = require("neodoc.config")
    local utils = require("neodoc.utils")
    
    if utils.is_empty(style) then
        vim.notify("Please provide a valid style (google, numpy, or sphinx)", vim.log.levels.ERROR)
        return
    end
    
    if utils.is_valid_style(style) then
        config.update_config("docstring_style", style:lower())
        vim.notify("Docstring style set to: " .. utils.capitalize(style), vim.log.levels.INFO)
    else
        vim.notify("Invalid style: " .. style .. ". Valid options are: Google, NumPy, Sphinx", vim.log.levels.ERROR)
    end
end

return M 
