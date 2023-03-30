vim.g.python3_host_prog = '/home/ams/.local/nvim/nvim-py3/bin/python3'

vim.g.loaded_netrw = 1
vim.g.loaded_netrwplugin = 1

require('plugins')

vim.cmd [[source ~/.vimrc]]
