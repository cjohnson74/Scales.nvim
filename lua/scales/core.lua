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
    -- Check if current buffer has unsaved changes
    if vim.bo.modified then
        vim.cmd('write')
    end

    -- End timing for current pattern if we're in a practice file
    local current_file = vim.fn.expand('%:p')
    if current_file:match('practice%.py$') then
        local current_pattern_dir = vim.fn.fnamemodify(current_file, ':h')
        local current_pattern_name = vim.fn.fnamemodify(current_pattern_dir, ':t')
        if current_pattern_name and current_pattern_name ~= '' then
            stats.end_timing(current_file)
        end
    end

    -- Reset session validation tracker
    stats.reset_session_validation()

    -- If no pattern specified, choose randomly
    if not pattern_name or pattern_name == "" then
        local pattern_keys = vim.tbl_keys(patterns.patterns)
        if #pattern_keys == 0 then
            vim.notify("No patterns available. Check your templates directory.", vim.log.levels.ERROR)
            return
        end
        pattern_name = pattern_keys[math.random(#pattern_keys)]
    end
    
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
    stats.reset_current_timing()
end

-- Reset current practice file
function M.reset_practice()
    local current_file = vim.fn.expand('%:p')
    if not current_file:match('practice%.py$') then
        vim.notify("Not in a practice file", vim.log.levels.ERROR)
        return
    end
    
    -- Check if current buffer has unsaved changes
    if vim.bo.modified then
        vim.cmd('write')
    end
    
    local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
    local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
    
    -- Reset the practice file with instructions
    local instructions = {
        string.format("# Practice: %s", pattern_name),
        "# Implement the pattern from scratch",
        "# When ready, run :ScalesValidate to check your implementation",
        "",
        "# Your implementation goes here:",
        ""
    }
    vim.fn.writefile(instructions, current_file)
    
    -- Reset timing for this practice
    stats.reset_current_timing()
    
    -- Reset attempt counts
    validation.reset_attempts(current_file)
    
    -- Open the reset file
    vim.cmd('edit ' .. current_file)
end

-- Show pattern information
function M.show_about()
    local current_file = vim.fn.expand('%:p')
    if not current_file:match('practice%.py$') then
        vim.notify("Not in a practice file", vim.log.levels.ERROR)
        return
    end
    
    local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
    local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
    
    if not pattern_name or pattern_name == '' then
        vim.notify("Could not determine pattern name", vim.log.levels.ERROR)
        return
    end
    
    local patterns = require('scales.patterns')
    patterns.show_about(pattern_name)
end

return M