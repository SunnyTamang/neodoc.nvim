# NeoDoc.nvim

A Neovim plugin for generating docstrings across multiple programming languages. Currently focused on Python with plans to expand support for more languages.

## Language Support

| Language   | Function Docstring | Class Docstring |
|------------|-------------------|-----------------|
| Python     | ✅                | ❌              |
| JavaScript | 🔜                | 🔜              |
| TypeScript | 🔜                | 🔜              |
| Go         | 🔜                | 🔜              |
| Rust       | 🔜                | 🔜              |

## Features

- Generate docstrings for functions
- Support for multiple docstring styles (Google, NumPy, Sphinx)
- Interactive template editor with live preview
- Custom template support
- Language-agnostic design (currently supporting Python, more languages coming soon)
- Easy-to-use commands and keymaps
- Customizable keybindings

## Demo

![neodoc](media/neodoc.mov)

## Installation

Using packer.nvim:
```lua
use {
    'sunnytamang/neodoc.nvim',
    config = function()
        require('neodoc').setup({
            -- your configuration here
        })
    end
}
```

Using lazy.nvim:
```lua
{
    'sunnytamang/neodoc.nvim',
    config = function()
        require('neodoc').setup({
            -- your configuration here
        })
    end
}
```

## Configuration

Configure NeoDoc using the setup function in your Neovim configuration file (init.lua):

```lua
require('neodoc').setup({
    -- Python interpreter path (default: 'python3')
    python_interpreter = 'python3',
    
    -- Default docstring style (default: 'google')
    docstring_style = 'google',
    
    -- Enable keymaps (default: true)
    enable_keymaps = true,
    
    -- Keymap prefix (default: '<leader>d')
    keymap = '<leader>d',
    
    -- Use custom template (default: false)
    use_custom_template = false
})
```

### Custom Keymappings

NeoDoc provides flexible keymapping options through the configuration:

1. **Enable/Disable Keymaps**
   ```lua
   require('neodoc').setup({
       enable_keymaps = false  -- Disable all keymaps
   })
   ```

2. **Custom Keymap Prefix**
   ```lua
   require('neodoc').setup({
       keymap = '<leader>g'  -- Change prefix to <leader>g
   })
   ```

When keymaps are enabled, the following mappings are created using your specified prefix:

| Mode    | Keymap          | Action                    |
|---------|-----------------|---------------------------|
| Normal  | `<prefix>d`     | Generate docstring        |
| Normal  | `<prefix>c`     | Change docstring style    |
| Normal  | `<prefix>e`     | Open template editor      |
| Normal  | `<prefix>s`     | Save template (in editor) |
| Normal  | `<C-q>`         | Close template editor     |

For example, if you set `keymap = '<leader>g'`, you would get:
- `<leader>gd` - Generate docstring
- `<leader>gc` - Change style
- `<leader>ge` - Open editor
- `<leader>gs` - Save template

## Usage

Position your cursor inside a function and use one of the following:
- Use the `:NeoDoc generate` command
- Press `<leader>dd` (default keymap)
- Use `:NeoDoc template` to open the template editor

## Commands

- `:NeoDoc generate` - Generate docstring at cursor
- `:NeoDoc config` - Show current configuration
- `:NeoDoc set_style <style>` - Set docstring style (google, numpy, sphinx)
- `:NeoDoc set_python <path>` - Set Python interpreter path
- `:NeoDoc template` - Open template editor
- `:NeoDoc preview` - Show docstring preview

## Template Editor

The template editor provides a split window interface with:
- Left pane: Template editor for modifying the template
- Right pane: Live preview showing how the template will look

Features:
- Live preview updates as you type
- Proper indentation handling
- Automatic template loading on startup
- Template persistence across sessions

## Custom Templates

Custom templates support the following placeholders:
- `{params}` - Function parameters
- `{return_type}` - Return type annotation

Templates are saved at: `~/.config/nvim/lua/neodoc/custom_template.lua`

Example template:
```python
"""
TODO: Add function description

Parameters:
----------
{params}

Returns:
-------
{return_type}

Raises:
------
    TODO: Add exceptions that might be raised

Examples:
--------
    >>> TODO: Add example usage
"""
```

## Future Plans

- Support for additional programming languages
- Class docstring generation
- AI-powered docstring generation
- Enhanced template customization options
- Language-specific template features
- Improved parameter type detection
- Integration with language servers
