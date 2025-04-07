-- Plugin initialization
local M = {}

-- Default configuration
M.config = {
    -- Default settings for the Scales plugin
    practice_dir = vim.fn.stdpath('data') .. '/scales',
    templates_dir = nil,  -- Will be set relative to plugin directory
    patterns = {},  -- Will be populated from templates directory
    -- UI settings
    float_border = 'rounded',
    float_width = 60,
    float_height = 20,
    -- Debug settings
    debug = false  -- Disable debug logging by default
}

-- Track if plugin is already initialized
M._initialized = false

-- Helper function to configure templates directory
local function configure_templates_dir()
    if not M.config.templates_dir then
        -- Find the plugin directory in runtimepath
        local plugin_path = nil
        for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/scales/init.lua', true)) do
            plugin_path = vim.fn.fnamemodify(path, ':h:h:h')  -- Go up three levels: lua/scales -> lua -> plugin root
            break
        end
        
        if not plugin_path then
            vim.notify("Could not find plugin directory", vim.log.levels.ERROR)
            return false
        end
        
        -- Set templates directory to the templates folder in the plugin's root
        M.config.templates_dir = plugin_path .. '/templates'
    end
    
    -- Create required directories
    vim.fn.mkdir(M.config.templates_dir, 'p')
    vim.fn.mkdir(M.config.practice_dir, 'p')
    
    -- Verify templates directory is accessible
    if not vim.fn.isdirectory(M.config.templates_dir) then
        vim.notify("Templates directory not accessible", vim.log.levels.ERROR)
        return false
    end
    
    return true
end

-- Register commands
vim.api.nvim_create_user_command('ScalesGenerate', function(args)
    local core = require('scales.core')
    core.generate_practice(args.args)
end, {
    nargs = '?',
    complete = function()
        return M.config.patterns
    end,
    desc = 'Generate a coding practice template'
})

vim.api.nvim_create_user_command('ScalesOpen', function()
    local core = require('scales.core')
    core.open_current_practice()
end, {
    desc = 'Open most recent practice file'
})

vim.api.nvim_create_user_command('ScalesValidate', function()
    local core = require('scales.core')
    core.validate_practice()
end, {
    desc = 'Validate current practice against template'
})

vim.api.nvim_create_user_command('ScalesList', function()
    local core = require('scales.core')
    core.list_patterns()
end, {
    desc = 'List available patterns'
})

vim.api.nvim_create_user_command('ScalesStats', function()
    local core = require('scales.core')
    core.show_progress()
end, {
    desc = 'Show practice statistics'
})

vim.api.nvim_create_user_command('ScalesPeek', function()
    local core = require('scales.core')
    core.peek_template()
end, {
    desc = 'Peek at template solution'
})

vim.api.nvim_create_user_command('ScalesNext', function()
    local core = require('scales.core')
    core.generate_practice()
end, {
    desc = 'Generate next practice session'
})

vim.api.nvim_create_user_command('ScalesResetStats', function()
    local core = require('scales.core')
    core.reset_current_stats()
end, {
    desc = 'Reset statistics for current practice'
})

vim.api.nvim_create_user_command('ScalesReload', function()
    -- Clear cached modules
    package.loaded['scales.core'] = nil
    package.loaded['scales.patterns'] = nil
    package.loaded['scales.stats'] = nil
    package.loaded['scales.validation'] = nil
    package.loaded['scales.ui'] = nil
    
    -- Reset templates loaded flag
    local patterns = require('scales.patterns')
    patterns._templates_loaded = false
    
    -- Re-run setup
    M.setup(M.config)
    vim.notify("Scales plugin reloaded", vim.log.levels.INFO)
end, {
    desc = 'Reload Scales plugin'
})

vim.api.nvim_create_user_command('ScalesCommands', function()
    local ui = require('scales.ui')
    ui.show_commands()
end, {
    desc = 'Show all available commands and key mappings'
})

-- Set up key mappings
vim.keymap.set('n', '<leader>sg', ':ScalesGenerate<CR>', { silent = true, desc = 'Scales: Generate Practice' })
vim.keymap.set('n', '<leader>so', ':ScalesOpen<CR>', { silent = true, desc = 'Scales: Open Practice' })
vim.keymap.set('n', '<leader>sv', ':ScalesValidate<CR>', { silent = true, desc = 'Scales: Validate Practice' })
vim.keymap.set('n', '<leader>sl', ':ScalesList<CR>', { silent = true, desc = 'Scales: List Patterns' })
vim.keymap.set('n', '<leader>ss', ':ScalesStats<CR>', { silent = true, desc = 'Scales: Show Stats' })
vim.keymap.set('n', '<leader>sn', ':ScalesNext<CR>', { silent = true, desc = 'Scales: Next Practice' })
vim.keymap.set('n', '<leader>sp', ':ScalesPeek<CR>', { silent = true, desc = 'Scales: Peek Template' })
vim.keymap.set('n', '<leader>sr', ':ScalesResetStats<CR>', { silent = true, desc = 'Scales: Reset Stats' })

-- Setup function
function M.setup(opts)
    -- Prevent multiple initializations
    if M._initialized then
        return
    end
    
    -- Merge user config with default config
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    
    -- Configure templates directory first
    if not configure_templates_dir() then
        vim.notify("Failed to configure templates directory", vim.log.levels.ERROR)
        return
    end
    
    -- Clear any cached modules
    package.loaded['scales.core'] = nil
    package.loaded['scales.patterns'] = nil
    package.loaded['scales.stats'] = nil
    package.loaded['scales.validation'] = nil
    package.loaded['scales.ui'] = nil
    
    -- Mark as initialized before loading modules to prevent circular dependencies
    M._initialized = true
    
    -- Initialize core module first
    local core = require('scales.core')
    core.setup(M.config)
    
    -- Initialize other modules
    local patterns = require('scales.patterns')
    local stats = require('scales.stats')
    local validation = require('scales.validation')
    local ui = require('scales.ui')
    
    -- Set config for all modules
    patterns.config = M.config
    stats.config = M.config
    validation.config = M.config
    ui.config = M.config
    
    -- Load patterns and stats
    patterns.patterns = patterns.load_templates()
    M.config.patterns = vim.tbl_keys(patterns.patterns)
    stats.load_stats()
    
    -- Expose UI functions
    M.ui = ui
end

-- Auto-initialize when loaded by Packer
if vim.g.loaded_scales then
    M.setup()
end

return M 