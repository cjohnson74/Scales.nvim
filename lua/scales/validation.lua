local M = {}

M.config = {}  -- Will be set by core.lua

local stats = require('scales.stats')
local ui = require('scales.ui')

-- Track validated practices
local validated_practices = {}  -- Only tracks successful validations

-- Format time in a human-readable way
local function format_time(seconds)
    if not seconds or seconds <= 0 then
        return "0 seconds"
    end
    
    local minutes = math.floor(seconds / 60)
    local remaining_seconds = math.floor(seconds % 60)
    
    if minutes > 0 then
        return string.format("%d minutes and %d seconds", minutes, remaining_seconds)
    else
        return string.format("%d seconds", remaining_seconds)
    end
end

-- Validate practice implementation
function M.validate_practice()
    -- Get the current buffer
    local current_buf = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buf)
    
    if not current_file or current_file == '' then
        vim.notify("No file is currently open", vim.log.levels.ERROR)
        return
    end
    
    -- Write the buffer to ensure we have the latest changes
    if vim.api.nvim_buf_get_option(current_buf, 'modified') then
        local success = pcall(vim.api.nvim_buf_call, current_buf, function()
            vim.cmd('write')
        end)
        if not success then
            vim.notify("Failed to save file before validation", vim.log.levels.ERROR)
            return
        end
    end
    
    local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
    local template_file = pattern_dir .. "/template.py"
    
    if vim.fn.filereadable(template_file) == 0 then
        vim.notify("Template file not found: " .. template_file, vim.log.levels.ERROR)
        return
    end
    
    -- Get pattern name for stats
    local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
    
    -- Track this attempt
    local attempt_count = stats.track_attempt(current_file)
    
    -- Read template content
    local template_content = vim.fn.readfile(template_file)
    if not template_content then
        vim.notify("Failed to read template file", vim.log.levels.ERROR)
        return
    end
    
    -- Read practice content
    local practice_content = vim.fn.readfile(current_file)
    if not practice_content then
        vim.notify("Failed to read practice file", vim.log.levels.ERROR)
        return
    end
    
    -- Filter out comments and empty lines
    local template_lines = {}
    local practice_lines = {}
    
    for _, line in ipairs(template_content) do
        if not line:match("^%s*#") and not line:match("^%s*$") then
            table.insert(template_lines, line)
        end
    end
    
    for _, line in ipairs(practice_content) do
        if not line:match("^%s*#") and not line:match("^%s*$") then
            table.insert(practice_lines, line)
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
        -- Check if this is the first successful validation
        local is_first_success = attempt_count == 1
        
        -- Update stats
        local timing_stats = stats.end_timing(current_file)
        if timing_stats then
            vim.notify(string.format("Practice completed in %s", format_time(timing_stats.last_time)), vim.log.levels.INFO)
        end
        
        ui.show_success_message(pattern_name, is_first_success)
    else
        -- Show differences
        local diff_lines = {"❌ Your implementation doesn't match the template:"}
        
        for _, diff in ipairs(differences) do
            table.insert(diff_lines, string.format("Line %d:", diff.line))
            table.insert(diff_lines, string.format("  Expected: %s", diff.template))
            table.insert(diff_lines, string.format("  Got:      %s", diff.practice))
            table.insert(diff_lines, "")
        end
        
        ui.show_popup(diff_lines, {
            title = "Practice Validation",
            border = "rounded"
        })
    end
end

return M 