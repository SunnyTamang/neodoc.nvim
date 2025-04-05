local M = {}
local core = require("neodoc.core")
local ui = require("neodoc.ui")
local config = require("neodoc.config")
local utils = require("neodoc.utils")

-- Function to setup all commands
function M.setup_commands()
    -- Main NeoDoc command
    vim.api.nvim_create_user_command("NeoDoc", function(opts)
        local args = opts.args
        if args == "" then
            vim.notify("Usage: NeoDoc [generate|config|set_style|set_python|preview|template]", vim.log.levels.INFO)
            return
        end

        local cmd = args:match("^%s*(%S+)")
        local rest = args:match("^%s*%S+%s*(.-)%s*$")

        if cmd == "generate" then
            core.generate_docstring()
        elseif cmd == "config" then
            ui.show_config_popup()
        elseif cmd == "set_style" then
            local style = rest:match("^%s*(%S+)")
            if style then
                if utils.is_valid_style(style) then
                    config.update_config("docstring_style", style:lower())
                    vim.notify("Docstring style set to: " .. utils.capitalize(style), vim.log.levels.INFO)
                else
                    vim.notify("Invalid style: " .. style .. ". Valid options are: Google, NumPy, Sphinx", vim.log.levels.ERROR)
                end
            else
                vim.notify("Usage: NeoDoc set_style <style>", vim.log.levels.ERROR)
            end
        elseif cmd == "set_python" then
            local python_path = rest:match("^%s*(%S+)")
            if python_path then
                config.update_config("python_interpreter", python_path)
                vim.notify("Python interpreter set to: " .. python_path, vim.log.levels.INFO)
            else
                vim.notify("Usage: NeoDoc set_python <path>", vim.log.levels.ERROR)
            end
        elseif cmd == "preview" then
            ui.show_preview()
        elseif cmd == "template" then
            require("neodoc.ui.template_editor").open()
        else
            vim.notify("Unknown command: " .. cmd, vim.log.levels.ERROR)
        end
    end, {
        nargs = "*",
        complete = function(_, line)
            local l = vim.split(line:sub(1, #line - 1), "%s+")
            local n = #l - 1

            if n == 0 then
                return vim.tbl_filter(function(val)
                    return vim.startswith(val, l[1])
                end, { "generate", "config", "set_style", "set_python", "preview", "template" })
            end

            if n == 1 and l[1] == "set_style" then
                return vim.tbl_filter(function(val)
                    return vim.startswith(val, l[2])
                end, { "google", "numpy", "sphinx" })
            end

            return {}
        end,
    })
    
    -- Command aliases
    vim.api.nvim_create_user_command("NeoDocGenerate", function()
        core.generate_docstring()
    end, {})
    
    vim.api.nvim_create_user_command("NeoDocStyle", function(opts)
        local style = opts.args
        if utils.is_empty(style) then
            vim.notify("Current docstring style: " .. config.get_config().docstring_style, vim.log.levels.INFO)
            return
        end
        
        if utils.is_valid_style(style) then
            config.update_config("docstring_style", style:lower())
            vim.notify("Docstring style set to: " .. utils.capitalize(style), vim.log.levels.INFO)
        else
            vim.notify("Invalid style: " .. style .. ". Valid options are: Google, NumPy, Sphinx", vim.log.levels.ERROR)
        end
    end, {
        nargs = "?",
        complete = function()
            return {"google", "numpy", "sphinx"}
        end,
        desc = "Set docstring style (google, numpy, sphinx) or show current style if no argument"
    })
    
    vim.api.nvim_create_user_command("NeoDocConfig", function()
        ui.show_config_popup()
    end, {})
    
    vim.api.nvim_create_user_command("NeoDocSetPython", function(opts)
        config.update_config("python_interpreter", opts.args)
        vim.notify("Python interpreter set to: " .. opts.args, vim.log.levels.INFO)
    end, {nargs = 1})
    
    vim.api.nvim_create_user_command("NeoDocPreview", function()
        ui.show_preview()
    end, {})
    
    vim.api.nvim_create_user_command("NeoDocTemplate", function()
        require("neodoc.ui.template_editor").open()
    end, {})
end

-- Function to setup key mappings
function M.setup_keymaps()
    local cfg = config.get_config()
    if cfg.enable_keymaps then
        -- Set up key mapping for normal mode
        vim.keymap.set("n", cfg.keymap .. "d", function()
            -- Notice to the user about the action
            vim.notify("Generating docstring for function at cursor...", vim.log.levels.INFO)
            require("neodoc.core").generate_docstring()
        end, { noremap = true, silent = true, desc = "Generate docstring at cursor" })
        
        -- Normal mode mapping for changing docstring style
        vim.keymap.set("n", cfg.keymap .. "c", function()
            require("neodoc.commands.preview").cycle_next_style()
        end, { noremap = true, silent = true, desc = "Change docstring style" })
        
        -- Open template editor (changed from dt to de)
        vim.keymap.set("n", cfg.keymap .. "e", function()
            require("neodoc.ui.template_editor").open()
        end, { noremap = true, silent = true, desc = "Open template editor" })
    end
end

return M 