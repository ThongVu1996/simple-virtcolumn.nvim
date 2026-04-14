# simple-virtcolumn.nvim

A lightweight, bare-bones, and hardware-optimized Neovim plugin to display a virtual vertical guide at your `colorcolumn`.

Perfect for dotfiles "hackers" and Nix users who prefer absolute control, zero bloat, and minimal dependencies. It delivers core rendering perfection in just ~90 lines of pure Lua.

## Features

- **Hardware-level performance:** Uses Neovim's low-level `decoration_provider` C-engine. The column markers are ephemeral and drawn strictly during the screen redraw cycle (0 ms delay).
- **Smart occlusion:** Does not hide or overlay characters. The virtual column seamlessly skips over folded lines and lines extending past the column width. This plays perfectly with custom UI fold plugins such as [ThongVu1996/simple-fold.nvim](https://github.com/ThongVu1996/simple-fold.nvim) without any visual clipping or glitches.
- **Split-friendly:** Automatically handles multiple split windows.

## Installation

Using `lazy.nvim`:

```lua
return {
    "ThongVu1996/simple-virtcolumn.nvim",
    event = "UIEnter",
    opts = {},
    config = function(_, opts)
        require("simple-virtcolumn").setup(opts)
    end
}
```

## Configuration

The plugin comes with sensible defaults. You can customize the symbol and columns:

```lua
require("simple-virtcolumn").setup({
    symbol = "┆", -- Or "│", "┊", etc.
    -- Optional: explicitly define multiple columns
    -- Accepts a Number (80), String ("80,120"), or Lua array ({ 80, 120 })
    -- If nil or omitted, the plugin falls back to reading vim.wo.colorcolumn
    -- If colorcolumn is not set, it defaults to a virtual guide at column 80.
    column = nil,
})
```

## Credits & Inspiration

Massive thanks and direct credits to the original mechanism designed in [lukas-reineke/virt-column.nvim](https://github.com/lukas-reineke/virt-column.nvim). This plugin was born out of a desire to implement the same underlying render tech in a hyper-minimal, maintainable dotfiles snippet.
