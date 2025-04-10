local M = {}

M.config = {}  -- Will be set by core.lua

local stats = require('scales.stats')
local ui = require('scales.ui')
local utils = require('scales.utils')

-- Track attempt counts
local attempt_counts = {}  -- Track attempts per file

-- Reset attempt counts for a file
function M.reset_attempts(file_path)
    attempt_counts[file_path] = nil
end

-- Validate practice implementation
function M.validate_practice()
    -- Get the current buffer
    local current_buf = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buf)
    
    if not current_file or current_file == '' then
        vim.notify("No file open", vim.log.levels.ERROR)
        return
    end
    
    -- Write the buffer to ensure we have the latest changes
    if vim.api.nvim_buf_get_option(current_buf, 'modified') then
        vim.cmd('write')
    end
    
    local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
    local template_file = pattern_dir .. "/template.py"
    
    if vim.fn.filereadable(template_file) == 0 then
        vim.notify("Template not found", vim.log.levels.ERROR)
        return
    end
    
    -- Get pattern name for stats
    local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
    
    -- Increment attempt count for this file
    attempt_counts[current_file] = (attempt_counts[current_file] or 0) + 1
    local current_attempt = attempt_counts[current_file]
    
    -- Read template content
    local template_content = vim.fn.readfile(template_file)
    if not template_content then
        vim.notify("Failed to read template", vim.log.levels.ERROR)
        return
    end
    
    -- Read practice content
    local practice_content = vim.fn.readfile(current_file)
    if not practice_content then
        vim.notify("Failed to read practice file", vim.log.levels.ERROR)
        return
    end
    
    -- Process lines in parallel
    local template_lines = {}
    local practice_lines = {}
    
    for _, line in ipairs(template_content) do
        local processed = utils.process_line(line)
        if not processed:match("^%s*$") then
            table.insert(template_lines, processed)
        end
    end
    
    for _, line in ipairs(practice_content) do
        local processed = utils.process_line(line)
        if not processed:match("^%s*$") then
            table.insert(practice_lines, processed)
        end
    end
    
    -- Compare lines
    local differences = {}
    local max_lines = math.max(#template_lines, #practice_lines)
    
    for i = 1, max_lines do
        local template_line = template_lines[i] or ""
        local practice_line = practice_lines[i] or ""
        
        if template_line ~= practice_line then
            table.insert(differences, {
                line = i,
                template = template_line,
                practice = practice_line
            })
        end
    end
    
    -- Show results
    if #differences == 0 then
        -- Track this attempt
        local is_first_success = current_attempt == 1
        
        -- Record the successful validation with the current attempt count
        local timing_stats = stats.record_validation(pattern_name, current_attempt)
        
        -- Show success message with timing information
        ui.show_success_message(pattern_name, is_first_success, timing_stats.last_time)
    else
        -- Show differences
        local diff_lines = {"❌ Your implementation doesn't match the template:"}
        
        for _, diff in ipairs(differences) do
            table.insert(diff_lines, string.format("Line %d:", diff.line))
            table.insert(diff_lines, string.format("  Expected: %s", diff.template))
            table.insert(diff_lines, string.format("  Got:      %s", diff.practice))
            table.insert(diff_lines, "")
        end
        
        -- Add timing information for failed attempts
        local timing_stats = stats.practice_log.timing_stats[pattern_name]
        if timing_stats and timing_stats.start_time then
            local current_time = (vim.loop.hrtime() / 1e9) - timing_stats.start_time
            table.insert(diff_lines, "")
            table.insert(diff_lines, string.format("⏱️ Current session time: %.3f seconds", current_time))
            
            -- Show previous time if available
            if timing_stats.last_time > 0 then
                table.insert(diff_lines, string.format("⏱️ Previous successful time: %.3f seconds", timing_stats.last_time))
            end
        end
        
        ui.show_popup(diff_lines, {
            title = "Practice Validation",
            border = "rounded"
        })
    end
end

return M 