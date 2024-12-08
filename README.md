# Telescope Cycler

A neovim plugin to cycle through a set of
[telescope](https://github.com/nvim-telescope/telescope.nvim) pickers.

This plugin provides a mechanism to cycle through a list of telescope picker
configurations.

## Installation

Use your favorite plugin manager or install manually using vim packages.

For example, assuming `~/.config/nvim/` is on your `packpath`:

```sh
git clone https://github.com/heindsight/nvim-telescope-cycler.git \
    ~/.config/nvim/pack/tools/start/nvim-telescope-cycler
```

You will of course also need to have `telescope.nvim` installed.

## Usage

The `telescope_cycler.new` function creates a new cycler object. It takes
a list of picker configurations and an optional table defining the key
mappings for cycling through the pickers.

For example:

```lua
local cycler = telescope_cycler.new(
    {
        {
            name = "Find files",
            picker = telescope_builtin.find_files,
            opts = { hidden = true }
        },
        { name = "Buffers",      picker = telescope_builtin.buffers },
        { name = "Old files", picker = telescope_builtin.oldfiles },
    },
    { next = '<C-n>', prev = '<C-p>' }
)
vim.keymap.set('n', '<leader>f', cycler, { desc = 'Telescope' })
```

The above example maps `<leader>f` to launch telescope with the "Find files"
picker (with `options` set to `{ hidden = true }`). The `<C-n>` and `<C-p>`
keys will be mapped to switch to the next/previous pickers amongst "Find
Files", "Buffers", and "Old files".

If no mappings are specified, `<C-l>` and `<C-h>` will be mapped to switch to
the next/previous picker respectively.

See `:help telescope_cycler` for more information.

## Development

The plugin is written in Lua and tested with
[busted](https://lunarmodules.github.io/busted/). Development dependencies are
managed with [luarocks](https://luarocks.org/). To initialize the development
environment, run:

```sh
make init_devenv
eval $(./luarocks path )
```

Now you can run the tests with:

```sh
make spec
```

You can get a covarage report at the end of the test run with:

```sh
make coverage
```

Linting is done with [luacheck](https://luacheck.readthedocs.io/en/stable/),
[selene](https://kampfkarren.github.io/selene/), and
[stylua](https://github.com/JohnnyMorganz/StyLua). To run the linters, use:

```sh
make lint
```

To format the code using `stylua`, run:

```sh
make format
```

Please note that pull requests will not be accepted unless test coverage is
100% and all tests and lint checks pass.
