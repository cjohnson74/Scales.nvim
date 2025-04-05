-- Only load once
if vim.g.loaded_scales then
    return
end

-- Initialize the plugin
local scales = require('scales')

-- Set the global flag after requiring the module but before setup
vim.g.loaded_scales = true

-- Setup the plugin
scales.setup()

-- Define commands
vim.api.nvim_create_user_command('ScalesGenerate', function(opts)
    local core = require('scales.core')
    core.generate_practice(opts.args)
end, { nargs = '?' })

vim.api.nvim_create_user_command('ScalesOpen', function()
    local core = require('scales.core')
    core.open_current_practice()
end, {})

vim.api.nvim_create_user_command('ScalesList', function()
    local core = require('scales.core')
    core.list_patterns()
end, {})

vim.api.nvim_create_user_command('ScalesStats', function()
    local core = require('scales.core')
    core.show_progress()
end, {})

vim.api.nvim_create_user_command('ScalesValidate', function()
    local core = require('scales.core')
    core.validate_practice()
end, {})

vim.api.nvim_create_user_command('ScalesReload', function()
    local core = require('scales.core')
    core.reload_templates()
end, {})

vim.api.nvim_create_user_command('ScalesNext', function()
    local core = require('scales.core')
    core.generate_practice()
end, {})

vim.api.nvim_create_user_command('ScalesPeek', function()
    local core = require('scales.core')
    core.peek_template()
end, {})

vim.api.nvim_create_user_command('ScalesSetup', function()
    require('scales').setup()
end, {})

-- Set default key mappings
vim.keymap.set('n', '<leader>sg', ':ScalesGenerate<CR>', { silent = true })
vim.keymap.set('n', '<leader>so', ':ScalesOpen<CR>', { silent = true })
vim.keymap.set('n', '<leader>sv', ':ScalesValidate<CR>', { silent = true })
vim.keymap.set('n', '<leader>sl', ':ScalesList<CR>', { silent = true })
vim.keymap.set('n', '<leader>ss', ':ScalesStats<CR>', { silent = true })
vim.keymap.set('n', '<leader>sn', ':ScalesNext<CR>', { silent = true })
vim.keymap.set('n', '<leader>sp', ':ScalesPeek<CR>', { silent = true })
