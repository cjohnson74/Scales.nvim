-- Minimal Neovim configuration for testing
local plenary_path = '~/.local/share/nvim/site/pack/vendor/start/plenary.nvim'
vim.opt.runtimepath:append(plenary_path)
vim.opt.runtimepath:append('.')

-- Load Plenary modules
local ok, plenary = pcall(require, 'plenary')
if not ok then
    error('Could not load Plenary. Make sure it is installed at: ' .. plenary_path)
end

-- Load and setup Scales
require('plenary.reload').reload_module('scales')
require('scales').setup()