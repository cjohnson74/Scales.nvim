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
        vim.notify("Failed to configure templates", vim.log.levels.ERROR)
        return
    end
    
    -- Create example template if templates directory is empty
    local example_dir = M.config.templates_dir .. '/1_binary_search'
    if not vim.fn.isdirectory(example_dir) then
        vim.fn.mkdir(example_dir, 'p')
        local example_template = {
            "def binary_search(arr, target):",
            "    left = 0",
            "    right = len(arr) - 1",
            "    ",
            "    while left <= right:",
            "        mid = (left + right) // 2",
            "        if arr[mid] == target:",
            "            return mid",
            "        elif arr[mid] < target:",
            "            left = mid + 1",
            "        else:",
            "            right = mid - 1",
            "    ",
            "    return -1"
        }
        vim.fn.writefile(example_template, example_dir .. '/template.py')
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
    
    -- Verify stats initialization
    if not stats.practice_log then
        vim.notify("Failed to initialize stats", vim.log.levels.ERROR)
        return
    end
    
    -- Register commands
    vim.api.nvim_create_user_command('ScalesGenerate', function(args)
        core.generate_practice(args.args)
    end, {
        nargs = '?',
        complete = function()
            return M.config.patterns
        end,
        desc = 'Generate a coding practice template'
    })
    
    vim.api.nvim_create_user_command('ScalesOpen', function()
        core.open_current_practice()
    end, {
        desc = 'Open most recent practice file'
    })
    
    vim.api.nvim_create_user_command('ScalesValidate', function()
        core.validate_practice()
    end, {
        desc = 'Validate current practice against template'
    })
    
    vim.api.nvim_create_user_command('ScalesList', function()
        core.list_patterns()
    end, {
        desc = 'List available patterns'
    })
    
    vim.api.nvim_create_user_command('ScalesStats', function()
        core.show_progress()
    end, {
        desc = 'Show practice statistics'
    })
    
    vim.api.nvim_create_user_command('ScalesPeek', function()
        core.peek_template()
    end, {
        desc = 'Peek at template solution'
    })
    
    vim.api.nvim_create_user_command('ScalesNext', function()
        core.generate_practice()
    end, {
        desc = 'Generate next practice session'
    })
    
    vim.api.nvim_create_user_command('ScalesResetStats', function()
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
    
    -- Set up key mappings
    vim.keymap.set('n', '<leader>sg', '<cmd>ScalesGenerate<cr>', { desc = 'Generate practice' })
    vim.keymap.set('n', '<leader>so', '<cmd>ScalesOpen<cr>', { desc = 'Open practice' })
    vim.keymap.set('n', '<leader>sv', '<cmd>ScalesValidate<cr>', { desc = 'Validate practice' })
    vim.keymap.set('n', '<leader>sl', '<cmd>ScalesList<cr>', { desc = 'List patterns' })
    vim.keymap.set('n', '<leader>ss', '<cmd>ScalesStats<cr>', { desc = 'Show stats' })
    vim.keymap.set('n', '<leader>sp', '<cmd>ScalesPeek<cr>', { desc = 'Peek template' })
    vim.keymap.set('n', '<leader>sn', '<cmd>ScalesNext<cr>', { desc = 'Next practice' })
    vim.keymap.set('n', '<leader>sr', '<cmd>ScalesResetStats<cr>', { desc = 'Reset stats' })
    
    -- Set up autocommands for timing
    vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'practice.py',
        callback = function()
            local stats = require('scales.stats')
            stats.start_auto_pause_timer()
        end
    })
    
    vim.api.nvim_create_autocmd('BufLeave', {
        pattern = 'practice.py',
        callback = function()
            local stats = require('scales.stats')
            if stats.auto_pause_timer then
                stats.auto_pause_timer:stop()
                stats.auto_pause_timer:close()
                stats.auto_pause_timer = nil
            end
        end
    })
    
    -- Set up autocommands for activity detection
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI', 'TextChanged', 'TextChangedI'}, {
        pattern = 'practice.py',
        callback = function()
            local stats = require('scales.stats')
            stats.update_activity_time()
        end
    })
    
    -- Set up autocommands for statusline
    vim.api.nvim_create_autocmd('User', {
        pattern = 'ScalesTimingStatusChanged',
        callback = function()
            vim.cmd('redrawstatus')
        end
    })
    
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'python',
        callback = function()
            if vim.fn.expand('%:t') == 'practice.py' then
                vim.opt.statusline:append('%{luaeval("require(\'scales.stats\').get_timing_status()")}')
            end
        end
    })
    
    -- Add cleanup on VimLeave
    vim.api.nvim_create_autocmd('VimLeave', {
        callback = function()
            -- Cleanup UI
            ui.cleanup()
            
            -- Pause timing for any active practice
            local current_file = vim.fn.expand('%:p')
            if current_file:match('practice%.py$') then
                local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
                local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
                local stats = require('scales.stats')
                
                if pattern_name and pattern_name ~= '' then
                    stats.pause_timing(pattern_name)
                    vim.notify("Paused timing for " .. pattern_name .. " before quitting", vim.log.levels.INFO)
                end
            end
        end
    })
    
    -- Add autocommands for timing
    vim.api.nvim_create_autocmd('BufLeave', {
        pattern = M.config.practice_dir .. '/*/practice.py',
        callback = function()
            local current_file = vim.fn.expand('%:p')
            if not current_file:match('practice%.py$') then
                return
            end
            
            local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
            local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
            local stats = require('scales.stats')
            
            -- Only resume if we're actually in a practice file
            if pattern_name and pattern_name ~= '' then
                stats.resume_timing(pattern_name)
            end
        end
    })
    
    vim.api.nvim_create_autocmd('BufEnter', {
        pattern = M.config.practice_dir .. '/*/practice.py',
        callback = function()
            local current_file = vim.fn.expand('%:p')
            if not current_file:match('practice%.py$') then
                return
            end
            
            local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
            local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
            local stats = require('scales.stats')
            
            -- Only resume if we're actually in a practice file
            if pattern_name and pattern_name ~= '' then
                stats.resume_timing(pattern_name)
            end
        end
    })
    
    -- Start auto-pause timer when entering a practice file
    vim.api.nvim_create_autocmd('BufEnter', {
        pattern = M.config.practice_dir .. '/*/practice.py',
        callback = function()
            require('scales.stats').start_auto_pause_timer()
        end
    })

    -- Stop auto-pause timer when leaving a practice file
    vim.api.nvim_create_autocmd('BufLeave', {
        pattern = M.config.practice_dir .. '/*/practice.py',
        callback = function()
            require('scales.stats').stop_auto_pause_timer()
        end
    })
    
    -- Expose UI functions
    M.ui = ui
end

-- Auto-initialize when loaded by Packer
if vim.g.loaded_scales then
    M.setup()
end

return M