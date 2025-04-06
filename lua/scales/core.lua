local M = {}

-- Import modules
local patterns = require('scales.patterns')
local stats = require('scales.stats')
local ui = require('scales.ui')
local validation = require('scales.validation')

-- Initialize plugin
function M.setup(opts)
    -- Validate config
    if not opts then
        vim.notify("No configuration provided", vim.log.levels.ERROR)
        return
    end
    
    -- Share config with other modules
    patterns.config = opts
    stats.config = opts
    ui.config = opts
    validation.config = opts
    
    -- Create required directories
    vim.fn.mkdir(opts.practice_dir, 'p')
    
    -- Initialize patterns first
    patterns.patterns = patterns.load_templates()
    if not patterns.patterns or vim.tbl_count(patterns.patterns) == 0 then
        vim.notify("No patterns found in templates directory", vim.log.levels.ERROR)
        return
    end
    
    -- Initialize stats
    stats.load_stats()
    
    -- Verify stats initialization
    if not stats.practice_log then
        vim.notify("Failed to initialize stats", vim.log.levels.ERROR)
        return
    end
    
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
                
                if pattern_name and pattern_name ~= '' then
                    stats.pause_timing(pattern_name)
                end
            end
        end
    })
    
    -- Add autocommands for timing
    vim.api.nvim_create_autocmd('BufEnter', {
        pattern = opts.practice_dir .. '/*/practice.py',
        callback = function()
            local current_file = vim.fn.expand('%:p')
            if not current_file:match('practice%.py$') then
                return
            end
            
            local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
            local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
            
            if pattern_name and pattern_name ~= '' then
                stats.start_timing(pattern_name)
            end
        end
    })
    
    vim.api.nvim_create_autocmd('BufLeave', {
        pattern = opts.practice_dir .. '/*/practice.py',
        callback = function()
            local current_file = vim.fn.expand('%:p')
            if not current_file:match('practice%.py$') then
                return
            end
            
            local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
            local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
            
            if pattern_name and pattern_name ~= '' then
                stats.pause_timing(pattern_name)
            end
        end
    })
end

-- Generate a practice session
function M.generate_practice(pattern_name)
    patterns.generate_practice(pattern_name)
end

-- Open the most recently generated practice file
function M.open_current_practice()
    patterns.open_current_practice()
end

-- List available patterns
function M.list_patterns()
    patterns.list_patterns()
end

-- Peek at the template
function M.peek_template()
    patterns.peek_template()
end

-- Validate practice implementation
function M.validate_practice()
    validation.validate_practice()
end

-- Show practice progress
function M.show_progress()
    ui.show_progress()
end

-- Reset current practice stats
function M.reset_current_stats()
    local stats = require('scales.stats')
    stats.reset_current_timing()
end

return M