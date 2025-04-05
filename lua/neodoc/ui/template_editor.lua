local M = {}

-- Constants for UI layout
local UI = {
    EDITOR_WIDTH = 0.5,  -- 50% of the screen width
    PREVIEW_WIDTH = 0.5, -- 50% of the screen width
    MIN_WIDTH = 80,      -- Minimum width for each pane
    MIN_HEIGHT = 10,     -- Minimum height for the window
}

-- State for the template editor
local state = {
    editor_buf = nil,
    editor_win = nil,
    preview_buf = nil,
    preview_win = nil,
    is_open = false,
    buffer_counter = 0,  -- Counter for unique buffer names
}

-- Get the current custom template content
local function get_current_template()
    -- Try to load the saved custom template
    local custom_template_path = vim.fn.stdpath("config") .. "/lua/neodoc/custom_template.lua"
    
    -- Check if the custom template file exists
    if vim.fn.filereadable(custom_template_path) == 1 then
        -- Clear cache to ensure we get the latest version
        package.loaded["neodoc.custom_template"] = nil
        
        local ok, custom_template = pcall(require, "neodoc.custom_template")
        if ok then
            -- Call generate with empty params to get the template structure
            local template = custom_template.generate({}, "")
            if template then
                return template
            end
        end
    end
    
    -- Fall back to default template if custom template doesn't exist or can't be loaded
    local template_lines = {
        '"""',
        "TODO: Add function description",
        "",
        "Parameters:",
        "----------",
        "{params}",
        "",
        "Returns:",
        "-------",
        "{return_type}",
        "",
        "Raises:",
        "------",
        "    TODO: Add exceptions that might be raised",
        "",
        "Examples:",
        "--------",
        "    >>> TODO: Add example usage",
        '"""'
    }
    
    return table.concat(template_lines, "\n")
end

-- Create a sample function for preview
local function get_sample_function()
    local template_content = get_current_template()
    return [[
def calculate_total(items, tax_rate):
    ]] .. template_content:gsub("\n", "\n    ") .. [[

    total = sum(items)
    return total * (1 + tax_rate)
]]
end

-- Update the preview with the current template
local function update_preview()
    if not state.is_open or not state.preview_buf then
        return
    end
    
    -- Get the current template content
    local lines = vim.api.nvim_buf_get_lines(state.editor_buf, 0, -1, false)
    local template_content = table.concat(lines, "\n")
    
    -- Create a sample function with the current template and proper indentation
    local sample_function = [[
def calculate_total(items, tax_rate):
    ]] .. template_content:gsub("\n", "\n    ") .. [[

    total = sum(items)
    return total * (1 + tax_rate)
]]
    
    -- Update the preview buffer
    vim.api.nvim_buf_set_option(state.preview_buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(state.preview_buf, 0, -1, false, vim.split(sample_function, '\n'))
    vim.api.nvim_buf_set_option(state.preview_buf, 'modifiable', false)
end

-- Create the editor buffer
local function create_editor_buffer()
    -- Increment buffer counter for unique names
    state.buffer_counter = state.buffer_counter + 1
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'python')
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_name(buf, '[NeoDoc Template Editor ' .. state.buffer_counter .. ']')
    
    -- Set the content
    local template_content = get_current_template()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(template_content, '\n'))
    
    -- Make sure the buffer is modifiable for editing
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    
    -- Set up autocmd to ensure buffer is modifiable when entering insert mode
    local augroup = vim.api.nvim_create_augroup("NeoDocTemplateEditor" .. state.buffer_counter, { clear = true })
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = augroup,
        buffer = buf,
        callback = function()
            vim.api.nvim_buf_set_option(buf, 'modifiable', true)
        end,
    })
    
    -- Set up autocmd for live preview updates
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
        group = augroup,
        buffer = buf,
        callback = function()
            update_preview()
        end,
    })
    
    return buf
end

-- Create the preview buffer
local function create_preview_buffer()
    -- Increment buffer counter for unique names
    state.buffer_counter = state.buffer_counter + 1
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'python')
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_name(buf, '[NeoDoc Template Preview ' .. state.buffer_counter .. ']')
    
    -- Set the content
    local sample_function = get_sample_function()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(sample_function, '\n'))
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    return buf
end

-- Create the UI windows
local function create_ui_windows()
    -- Get the current window dimensions
    local width = vim.o.columns
    local height = vim.o.lines
    
    -- Calculate window dimensions
    local editor_width = math.floor(width * UI.EDITOR_WIDTH)
    local preview_width = width - editor_width
    
    -- Create the editor window
    local editor_buf = create_editor_buffer()
    local editor_win = vim.api.nvim_open_win(editor_buf, true, {
        relative = 'editor',
        width = editor_width,
        height = height - 2,
        row = 0,
        col = 0,
        style = 'minimal',
        border = 'single',
        title = ' Template Editor ',
        title_pos = 'center',
    })
    
    -- Create the preview window
    local preview_buf = create_preview_buffer()
    local preview_win = vim.api.nvim_open_win(preview_buf, false, {
        relative = 'editor',
        width = preview_width,
        height = height - 2,
        row = 0,
        col = editor_width,
        style = 'minimal',
        border = 'single',
        title = ' Preview ',
        title_pos = 'center',
    })
    
    -- Set window options
    vim.api.nvim_win_set_option(editor_win, 'wrap', false)
    vim.api.nvim_win_set_option(editor_win, 'number', true)
    vim.api.nvim_win_set_option(editor_win, 'cursorline', true)
    
    vim.api.nvim_win_set_option(preview_win, 'wrap', false)
    vim.api.nvim_win_set_option(preview_win, 'number', true)
    vim.api.nvim_win_set_option(preview_win, 'cursorline', true)
    
    -- Update state
    state.editor_buf = editor_buf
    state.editor_win = editor_win
    state.preview_buf = preview_buf
    state.preview_win = preview_win
    state.is_open = true
    
    -- Set up autocommands to close the UI when leaving the buffers
    local augroup = vim.api.nvim_create_augroup("NeoDocTemplateEditorClose" .. state.buffer_counter, { clear = true })
    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        buffer = editor_buf,
        callback = function()
            M.close()
        end,
    })
    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        buffer = preview_buf,
        callback = function()
            M.close()
        end,
    })
    
    -- Set up keymaps
    vim.api.nvim_buf_set_keymap(editor_buf, 'n', '<leader>ds', ':lua require("neodoc.ui.template_editor").save()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(editor_buf, 'n', '<C-q>', ':lua require("neodoc.ui.template_editor").close()<CR>', { noremap = true, silent = true })
    
    -- Focus the editor window
    vim.api.nvim_set_current_win(editor_win)
end

-- Close the UI windows
function M.close()
    if state.is_open then
        if vim.api.nvim_win_is_valid(state.editor_win) then
            vim.api.nvim_win_close(state.editor_win, true)
        end
        if vim.api.nvim_win_is_valid(state.preview_win) then
            vim.api.nvim_win_close(state.preview_win, true)
        end
        state.is_open = false
    end
end

-- Save the template
function M.save()
    if not state.is_open or not state.editor_buf then
        return
    end
    
    -- Get the template content
    local lines = vim.api.nvim_buf_get_lines(state.editor_buf, 0, -1, false)
    
    -- Create the custom_template.lua file content
    local file_content = string.format([[
local M = {}

-- Custom docstring template
function M.generate(params, return_type)
    local lines = {
%s
    }
    return table.concat(lines, "\n")
end

return M]], table.concat(vim.tbl_map(function(line)
        -- Properly quote each line and handle empty lines
        if line == "" then
            return '        "",'
        else
            return string.format('        %q,', line)
        end
    end, lines), "\n"))
    
    -- Get the plugin directory
    local plugin_dir = vim.fn.stdpath("config") .. "/lua/neodoc"
    local custom_template_path = plugin_dir .. "/custom_template.lua"
    
    -- Create directories if they don't exist
    vim.fn.mkdir(plugin_dir, "p")
    
    -- Write the file
    local success = vim.fn.writefile(vim.split(file_content, "\n"), custom_template_path)
    
    if success == -1 then
        vim.notify("Failed to save template: Could not write to file", vim.log.levels.ERROR)
        return
    end
    
    -- Update the config to use the custom template
    local config = require("neodoc.config")
    config.update_config("use_custom_template", true)
    
    -- Clear the package.loaded cache to force reload of the custom template
    package.loaded["neodoc.custom_template"] = nil
    
    -- Notify the user
    vim.notify("Template saved successfully! Custom template is now enabled.", vim.log.levels.INFO)
    
    -- Update the preview
    update_preview()
end

-- Open the template editor
function M.open()
    if state.is_open then
        return
    end
    
    create_ui_windows()
end

return M 