# vim-ime

Automatic input method management for Vim/Neovim that works with fcitx, fcitx5, and ibus.

## Branches

| Branch | Runtime | Description |
|--------|---------|-------------|
| `master` | Neovim (Lua) | Lua rewrite using native Neovim APIs, `setup()` pattern |
| `vim` | Vim / Neovim (VimScript) | Original VimScript version, compatible with both Vim and Neovim |

```bash
# For Neovim (Lua)
git clone https://github.com/4ree/vim-ime.git

# For Vim / legacy Neovim (VimScript)
git clone -b vim https://github.com/4ree/vim-ime.git
```

## Changelog

### v1.0 — Initial release (2025-09-01)

- Auto-detect input method system (fcitx5, fcitx4, ibus)
- Auto switch to English when entering Normal mode
- Restore previous input method when entering Insert mode
- Restore previous input method when entering Search mode (`/`, `?`)
- Switch back to English when leaving Search mode
- FocusLost/FocusGained: switch to English on focus change
- Commands: `:InputMethodAutoToggle`, `:InputMethodAutoStatus`, `:InputMethodAutoReset`
- Default mapping: `<leader>im` to toggle input method
- Debug mode via `g:input_method_auto_debug`
- Configurable via `g:input_method_auto_enable`, `g:input_method_auto_no_mappings`

### v1.1 — Fix events handling (2025-09-02)

- Rewrote ibus engine save/restore logic: properly handles engine changes made during Normal mode
- Removed FocusLost/FocusGained autocmds (caused issues with some terminal emulators)

### v1.2 — fzf integration (2025-12-18)

- Added fzf.vim integration: input method auto-enabled in fzf buffers
- Allows searching in native language (Vietnamese, Chinese, Japanese, Korean, etc.) inside `:Files`, `:Rg`, `:Buffers`, `:History`, etc.

### v2.0 — Lua rewrite (2026-02-17)

- Full rewrite from VimScript to Lua using native Neovim APIs
- `require("ime").setup()` configuration pattern
- `nvim_create_autocmd` / `nvim_create_augroup` / `nvim_create_user_command` / `vim.keymap.set`
- Backwards compatible with `g:input_method_auto_*` global variables
- Original VimScript version preserved on `vim` branch

---

## Installation (Lua — master branch)

### Using lazy.nvim

```lua
{
  "4ree/vim-ime",
  event = "VeryLazy",
  opts = {},
}
```

### Using packer.nvim

```lua
use {
  "4ree/vim-ime",
  config = function()
    require("ime").setup()
  end,
}
```

### Using vim-plug

```vim
Plug '4ree/vim-ime'
```

## Installation (VimScript — vim branch)

### Using vim-plug

```vim
Plug '4ree/vim-ime', { 'branch': 'vim' }
```

### Using Vundle

```vim
Plugin '4ree/vim-ime'
```

### Using packer.nvim

```lua
use { "4ree/vim-ime", branch = "vim" }
```

## Default Behavior

- **Normal Mode**: Input method is automatically switched to English
- **Insert Mode**: Your previous input method is restored
- **Search Mode**: Input method is restored while searching, then switched back to English
- **fzf Integration**: Input method is automatically enabled in fzf buffers (when using fzf.vim)

## Commands

- `:InputMethodAutoToggle` - Temporarily enable input method in normal mode
- `:InputMethodAutoStatus` - Show current status and detected input method
- `:InputMethodAutoReset` - Reset and reinitialize the plugin

## Default Mappings

- `<leader>im` - Toggle input method temporarily

## Configuration

### Lua (master branch)

```lua
require("ime").setup({
  enable = true,       -- Enable the plugin (default: true)
  debug = false,       -- Enable debug messages (default: false)
  no_mappings = false, -- Disable default key mappings (default: false)
})
```

### VimScript (vim branch)

```vim
let g:input_method_auto_enable = 0     " Disable the plugin
let g:input_method_auto_debug = 1      " Enable debug messages
let g:input_method_auto_no_mappings = 1 " Disable default key mappings
```

### Custom Key Mappings

Lua:
```lua
require("ime").setup({ no_mappings = true })
vim.keymap.set("n", "<C-i>", require("ime").toggle, { desc = "Toggle input method" })
```

VimScript:
```vim
let g:input_method_auto_no_mappings = 1
nmap <C-i> <Plug>InputMethodAutoToggle
```

## Supported Input Methods

- **fcitx5** - Latest version of fcitx
- **fcitx** - fcitx version 4
- **ibus** - Input Bus

The plugin automatically detects which input method system you're using and configures itself accordingly.

## fzf Integration

The plugin automatically enables your input method when using fzf.vim commands like:
- `:Files` - Search for files
- `:Rg` - Search for text using ripgrep
- `:Buffers` - Search through open buffers
- `:History` - Search command history
- Any other fzf.vim command

This allows you to search using your native language (Vietnamese, Chinese, Japanese, Korean, etc.) just like you would in Insert or Search mode.

## Troubleshooting

### Debug Mode

Lua:
```lua
require("ime").setup({ debug = true })
```

VimScript:
```vim
let g:input_method_auto_debug = 1
```

Then restart and check the messages with `:messages`.

### Check Status

Use `:InputMethodAutoStatus` to see which input method was detected and whether the plugin is initialized.

### Reset Plugin

```vim
:InputMethodAutoReset
```

## License

MIT License. See LICENSE file for details.
