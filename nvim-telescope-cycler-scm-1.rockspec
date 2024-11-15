rockspec_format = '3.0'
package = 'nvim-telescope-cycler'
version = 'scm-1'

source = {
    url = 'git://github.com/heindsight/nvim-telescope-cycler',
}

description = {
    summary = 'Cycle through Telescope pickers',
    homepage = "https://github.com/heindsight/nvim-telescope-cycler.git",
    license = "BSD-2-Clause",
    labels = { 'neovim', 'plugin', },
}

dependencies = {
    'lua == 5.1',
    'telescope.nvim',
}

build = {
    type = 'builtin',
}
