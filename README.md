# nvim-react

A reactive UI rendering framework for Neovim

<https://user-images.githubusercontent.com/18459807/212144062-28756d23-1c42-4171-9cd8-a49a866ac9e8.mp4>

## Development

Open the project

```bash
nvim -c "luafile dev/init.lua"
```

Try `<leader><leader>w` keymap

### Run tests

:ledger: Running tests requires [plenary.nvim][plenary] to be checked out in the
parent directory of _this_ repository

You can then run:

```bash
nvim \
--headless \
--noplugin \
-u tests/minimal.vim \
-c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"
```

Or if you want to run a single test file:

```bash
nvim \
--headless \
--noplugin \
-u tests/minimal.vim \
-c "PlenaryBustedDirectory tests/path_to_file.lua {minimal_init = 'tests/minimal.vim'}"
```

[plenary]: https://github.com/nvim-lua/plenary.nvim
