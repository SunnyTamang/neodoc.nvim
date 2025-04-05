local M = {}
local utils = require("neodoc.utils")
local config = require("neodoc.config")

-- State for preview window
local preview_state = {
    bufnr = nil,
    win_id = nil,
    current_style = 1,
    styles = { "google", "numpy", "sphinx" }
}

-- Function to show configuration popup menu
function M.show_config_popup()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local width = 60
    local height = 10
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(bufnr, 'filetype', 'neodoc-config')
    
    -- Create the window
    local win_opts = utils.create_centered_window(width, height, " NeoDoc Configuration ")
    local win_id = vim.api.nvim_open_win(bufnr, true, win_opts)
    
    -- Set up the content
    local content = {
        "NeoDoc Configuration",
        "──────────────────",
        "1. Style: " .. config.get_config().docstring_style,
        "2. Python Interpreter: " .. config.get_config().python_interpreter,
        "3. Custom Template: " .. (config.get_config().use_custom_template and "enabled" or "disabled"),
        "4. Keymaps: " .. (config.get_config().enable_keymaps and "enabled" or "disabled"),
        "",
        "Press number to edit, q to close"
    }
    
    -- Set the content
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    
    -- Set up key mappings
    local function close_popup()
        if vim.api.nvim_win_is_valid(win_id) then
            vim.api.nvim_win_close(win_id, true)
        end
    end
    
    -- Map keys for editing
    vim.keymap.set('n', 'q', close_popup, { buffer = bufnr, noremap = true })
    vim.keymap.set('n', '<Esc>', close_popup, { buffer = bufnr, noremap = true })
    
    -- Style selection
    vim.keymap.set('n', '1', function()
        close_popup()
        vim.ui.input({
            prompt = "Select style (google/numpy/sphinx): ",
            default = config.get_config().docstring_style
        }, function(input)
            if input and utils.is_valid_style(input) then
                config.update_config("docstring_style", input:lower())
                vim.notify("Docstring style set to: " .. utils.capitalize(input), vim.log.levels.INFO)
            end
        end)
    end, { buffer = bufnr, noremap = true })
    
    -- Python interpreter
    vim.keymap.set('n', '2', function()
        close_popup()
        vim.ui.input({
            prompt = "Set Python interpreter path: ",
            default = config.get_config().python_interpreter
        }, function(input)
            if input then
                config.update_config("python_interpreter", input)
                vim.notify("Python interpreter set to: " .. input, vim.log.levels.INFO)
            end
        end)
    end, { buffer = bufnr, noremap = true })
    
    -- Custom template toggle
    vim.keymap.set('n', '3', function()
        local current = config.get_config().use_custom_template
        config.update_config("use_custom_template", not current)
        vim.notify("Custom template " .. (not current and "enabled" or "disabled"), vim.log.levels.INFO)
        close_popup()
    end, { buffer = bufnr, noremap = true })
    
    -- Keymaps toggle
    vim.keymap.set('n', '4', function()
        local current = config.get_config().enable_keymaps
        config.update_config("enable_keymaps", not current)
        vim.notify("Keymaps " .. (not current and "enabled" or "disabled"), vim.log.levels.INFO)
        close_popup()
    end, { buffer = bufnr, noremap = true })
end

-- Function to generate preview content
local function generate_preview_content(style)
    local template_map = {
        google = "neodoc.templates.google",
        numpy = "neodoc.templates.numpy",
        sphinx = "neodoc.templates.sphinx"
    }
    
    local template = require(template_map[style])
    local sample_func = utils.get_sample_function()
    local docstring = template.generate(sample_func)
    
    local lines = {
        "-- Press Tab/Shift+Tab to cycle through styles, q or Esc to close",
        "-- Current Style: " .. utils.capitalize(style),
        "",
        "def sample_function(param1: int, param2: str, param3: List[float]) -> Dict[str, Any]:"
    }
    
    local docstring_lines = vim.split(docstring, "\n", { trimempty = false })
    for _, line in ipairs(docstring_lines) do
        table.insert(lines, "    " .. line)
    end
    
    table.insert(lines, "    result = {}")
    table.insert(lines, "    for i, p in enumerate(param3):")
    table.insert(lines, "        result[param2 + str(i)] = param1 * p")
    table.insert(lines, "    return result")
    
    return lines
end

-- Function to update preview content
local function update_preview_content()
    local style = preview_state.styles[preview_state.current_style]
    local content = generate_preview_content(style)
    
    vim.api.nvim_buf_set_lines(preview_state.bufnr, 0, -1, false, content)
    vim.api.nvim_buf_set_name(preview_state.bufnr, "NeoDoc Preview: " .. style .. " Style")
end

-- Function to cycle to the next style
local function cycle_next_style()
    preview_state.current_style = preview_state.current_style % #preview_state.styles + 1
    update_preview_content()
end

-- Function to cycle to the previous style
local function cycle_prev_style()
    preview_state.current_style = (preview_state.current_style - 2) % #preview_state.styles + 1
    update_preview_content()
end

-- Function to show preview
function M.show_preview(initial_style)
    if initial_style and initial_style ~= "all" then
        for i, style in ipairs(preview_state.styles) do
            if style == initial_style:lower() then
                preview_state.current_style = i
                break
            end
        end
    else
        preview_state.current_style = 1
    end
    
    if not preview_state.bufnr or not vim.api.nvim_buf_is_valid(preview_state.bufnr) then
        preview_state.bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(preview_state.bufnr, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_option(preview_state.bufnr, 'filetype', 'python')
        
        -- Set up key mappings
        vim.api.nvim_buf_set_keymap(preview_state.bufnr, 'n', '<Tab>', '', {
            noremap = true, 
            callback = cycle_next_style
        })
        vim.api.nvim_buf_set_keymap(preview_state.bufnr, 'n', '<S-Tab>', '', {
            noremap = true, 
            callback = cycle_prev_style
        })
        vim.api.nvim_buf_set_keymap(preview_state.bufnr, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(preview_state.bufnr, 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true })
        
        -- Add style navigation keybindings
        for i = 1, #preview_state.styles do
            vim.api.nvim_buf_set_keymap(preview_state.bufnr, 'n', tostring(i), '', {
                noremap = true,
                callback = function()
                    preview_state.current_style = i
                    update_preview_content()
                end
            })
        end
    end
    
    update_preview_content()
    
    if not preview_state.win_id or not vim.api.nvim_win_is_valid(preview_state.win_id) then
        local win_opts = utils.create_centered_window(80, 20, "NeoDoc Preview (Tab/Shift+Tab to switch styles)")
        preview_state.win_id = vim.api.nvim_open_win(preview_state.bufnr, true, win_opts)
    end
end

return M 