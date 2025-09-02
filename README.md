# vim-ime

Automatic input method management for Vim/Neovim that works with fcitx, fcitx5, and ibus.

## Installation

### Using vim-plug

```vim
Plug '4ree/vim-ime'
```

### Using Vundle

```vim
Plugin '4ree/vim-ime'
```

### Using Packer (Neovim)

```lua
use '4ree/vim-ime'
```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/4ree/vim-ime.git
   ```

2. Copy the files to your Vim configuration directory:
   ```bash
   cp -r vim-ime/* ~/.vim/
   # or for Neovim:
   cp -r vim-ime/* ~/.config/nvim/
   ```

### Default Behavior

- **Normal Mode**: Input method is automatically switched to English
- **Insert Mode**: Your previous input method is restored
- **Search Mode**: Input method is restored while searching, then switched back to English

### Commands

- `:InputMethodAutoToggle` - Temporarily enable input method in normal mode
- `:InputMethodAutoStatus` - Show current status and detected input method
- `:InputMethodAutoReset` - Reset and reinitialize the plugin

### Default Mappings

- `<leader>im` - Toggle input method temporarily (maps to `:InputMethodAutoToggle`)

## Configuration

### Basic Options

```vim
" Disable the plugin (default: 1)
let g:input_method_auto_enable = 0

" Enable debug messages (default: 0)
let g:input_method_auto_debug = 1

" Disable focus event handling (default: 1)
let g:input_method_auto_focus_events = 0

" Disable default key mappings (default: 0)
let g:input_method_auto_no_mappings = 1
```

### Custom Key Mappings

If you want to use a different key mapping:

```vim
" Disable default mappings
let g:input_method_auto_no_mappings = 1

" Create your own mapping
nmap <C-i> <Plug>InputMethodAutoToggle
```

## Supported Input Methods

- **fcitx5** - Latest version of fcitx
- **fcitx** - fcitx version 4
- **ibus** - Input Bus

The plugin automatically detects which input method system you're using and configures itself accordingly.

## Troubleshooting

### Debug Mode

Enable debug mode to see what the plugin is doing:

```vim
let g:input_method_auto_debug = 1
```

Then restart Vim and check the messages with `:messages`.

### Check Status

Use `:InputMethodAutoStatus` to see:
- Which input method was detected
- Whether the plugin is properly initialized
- Current state information

### Reset Plugin

If something goes wrong, try:

```vim
:InputMethodAutoReset
```

## License

MIT License. See LICENSE file for details.
