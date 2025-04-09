local M = {}

M.config = {}  -- Will be set by core.lua

-- Track open windows for cleanup
local open_windows = {}

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

-- Cleanup function to close all open windows
function M.cleanup()
    for _, win in ipairs(open_windows) do
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end
    open_windows = {}
end

-- Create a floating window
function M.create_float(contents, opts)
    opts = opts or {}
    
    -- Default options
    local default_opts = {
        relative = 'editor',
        width = M.config.float_width or 60,
        height = M.config.float_height or 20,
        style = 'minimal',
        border = M.config.float_border or 'rounded'
    }
    
    -- Merge default and user options
    opts = vim.tbl_deep_extend('force', default_opts, opts)
    
    -- Calculate window position (centered)
    opts.row = math.floor((vim.o.lines - opts.height) / 2)
    opts.col = math.floor((vim.o.columns - opts.width) / 2)
    
    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    if not buf then
        vim.notify("Failed to create buffer", vim.log.levels.ERROR)
        return nil, nil
    end
    
    -- Set buffer contents
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
    
    -- Create window
    local win = vim.api.nvim_open_win(buf, true, opts)
    if not win then
        vim.notify("Failed to create window", vim.log.levels.ERROR)
        return nil, nil
    end
    
    -- Track window for cleanup
    table.insert(open_windows, win)
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'readonly', true)
    
    -- Set window options
    vim.api.nvim_win_set_option(win, 'wrap', true)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:NormalFloat')
    
    return buf, win
end

-- Show a popup with content and title
function M.show_popup(content, opts)
    opts = opts or {}
    
    -- Convert content to table if it's a string
    if type(content) == "string" then
        content = vim.split(content, "\n")
    end
    
    -- Add title if provided
    local display_content = {}
    if opts.title then
        local title_text = type(opts.title) == "table" and opts.title.title or opts.title
        table.insert(display_content, "╭" .. string.rep("─", 58) .. "╮")
        table.insert(display_content, "│" .. string.rep(" ", math.floor((58 - #title_text) / 2)) .. title_text .. string.rep(" ", math.ceil((58 - #title_text) / 2)) .. "│")
        table.insert(display_content, "╰" .. string.rep("─", 58) .. "╯")
        table.insert(display_content, "")
    end
    
    -- Add content
    for _, line in ipairs(content) do
        table.insert(display_content, line)
    end
    
    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    if not buf then
        vim.notify("Failed to create buffer", vim.log.levels.ERROR)
        return
    end
    
    -- Set buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_content)
    
    -- Calculate dimensions
    local width = M.config.float_width or 60
    local height = math.min(#display_content + 2, vim.o.lines - 4)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    -- Create window
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = M.config.float_border or 'rounded'
    })
    
    if not win then
        vim.notify("Failed to create window", vim.log.levels.ERROR)
        return
    end
    
    -- Track window for cleanup
    table.insert(open_windows, win)
    
    -- Set window options
    vim.api.nvim_win_set_option(win, 'wrap', true)
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:NormalFloat')
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'readonly', true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Add keymaps
    local keymaps = {
        ['q'] = 'close',
        ['<Esc>'] = 'close',
        ['<C-c>'] = 'close',
        ['j'] = 'scroll_down',
        ['k'] = 'scroll_up',
        ['<Down>'] = 'scroll_down',
        ['<Up>'] = 'scroll_up',
        ['<C-d>'] = 'scroll_half_page_down',
        ['<C-u>'] = 'scroll_half_page_up',
        ['<C-f>'] = 'scroll_page_down',
        ['<C-b>'] = 'scroll_page_up',
        ['gg'] = 'scroll_top',
        ['G'] = 'scroll_bottom'
    }
    
    for key, action in pairs(keymaps) do
        vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
            noremap = true,
            silent = true,
            callback = function()
                if action == 'close' then
                    vim.api.nvim_win_close(win, true)
                    -- Remove window from tracking
                    for i, w in ipairs(open_windows) do
                        if w == win then
                            table.remove(open_windows, i)
                            break
                        end
                    end
                elseif action == 'scroll_down' then
                    vim.api.nvim_win_call(win, function()
                        vim.cmd('normal! j')
                    end)
                elseif action == 'scroll_up' then
                    vim.api.nvim_win_call(win, function()
                        vim.cmd('normal! k')
                    end)
                elseif action == 'scroll_half_page_down' then
                    vim.api.nvim_win_call(win, function()
                        vim.cmd('normal! <C-d>')
                    end)
                elseif action == 'scroll_half_page_up' then
                    vim.api.nvim_win_call(win, function()
                        vim.cmd('normal! <C-u>')
                    end)
                elseif action == 'scroll_page_down' then
                    vim.api.nvim_win_call(win, function()
                        vim.cmd('normal! <C-f>')
                    end)
                elseif action == 'scroll_page_up' then
                    vim.api.nvim_win_call(win, function()
                        vim.cmd('normal! <C-b>')
                    end)
                elseif action == 'scroll_top' then
                    vim.api.nvim_win_call(win, function()
                        vim.cmd('normal! gg')
                    end)
                elseif action == 'scroll_bottom' then
                    vim.api.nvim_win_call(win, function()
                        vim.cmd('normal! G')
                    end)
                end
            end
        })
    end
    
    return {
        buf = buf,
        win = win
    }
end

-- Show practice patterns menu
function M.show_patterns_menu()
    local patterns = require('scales.patterns').patterns
    local menu_contents = {"Scales Practice Patterns", ""}
    
    -- Build menu
    for pattern_name, pattern_info in pairs(patterns) do
        table.insert(menu_contents, string.format("%s - %s", 
            pattern_name, 
            pattern_info.description
        ))
    end
    
    -- Create floating window
    local buf, win = M.create_float(menu_contents)
    if not buf or not win then
        return
    end
    
    -- Optional: Add keymaps for selection
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
        noremap = true,
        silent = true,
        callback = function()
            local cursor_pos = vim.api.nvim_win_get_cursor(win)
            local line_nr = cursor_pos[1] - 1  -- 0-based line number
            local pattern_name = menu_contents[line_nr + 1]:match("^([^%s]+)")
            
            if pattern_name then
                vim.api.nvim_win_close(win, true)
                -- Remove window from tracking
                for i, w in ipairs(open_windows) do
                    if w == win then
                        table.remove(open_windows, i)
                        break
                    end
                end
                vim.cmd('redraw')
                vim.api.nvim_echo({{"Selected pattern: " .. pattern_name, "Normal"}}, false, {})
                
                -- Check if current buffer has unsaved changes
                if vim.bo.modified then
                    vim.cmd('write')
                end
                
                require('scales.core').generate_practice(pattern_name)
            end
        end
    })
end

-- Show practice session details
function M.show_practice_details(practice_info)
    local details = {
        "Practice Session Details",
        "",
        string.format("Pattern: %s", practice_info.pattern),
        string.format("Template: %s", practice_info.template_name),
        string.format("Timestamp: %s", practice_info.timestamp)
    }
    
    M.create_float(details)
end

-- Helper function to calculate progress
local function calculate_progress(total_practices, first_attempt_successes)
    local success_rate = total_practices > 0 and (first_attempt_successes / total_practices) * 100 or 0
    local progress_width = 20
    local progress_filled = 0
    
    -- Define level requirements and progress calculations
    local levels = {
        {
            name = "Master",
            min_practices = 100,
            min_success_rate = 80,
            progress_func = function() return progress_width end
        },
        {
            name = "Expert",
            min_practices = 50,
            min_success_rate = 70,
            progress_func = function(practices)
                return math.floor(progress_width * math.min((practices - 50) / 50, 1))
            end
        },
        {
            name = "Advanced",
            min_practices = 25,
            min_success_rate = 60,
            progress_func = function(practices)
                return math.floor(progress_width * math.min((practices - 25) / 25, 1))
            end
        },
        {
            name = "Intermediate",
            min_practices = 10,
            min_success_rate = 50,
            progress_func = function(practices)
                return math.floor(progress_width * math.min((practices - 10) / 15, 1))
            end
        },
        {
            name = "Beginner",
            min_practices = 0,
            min_success_rate = 0,
            progress_func = function(practices)
                return math.floor(progress_width * math.min(practices / 10, 1))
            end
        }
    }
    
    -- Find current level
    local current_level = levels[#levels]  -- Default to Beginner
    for _, level in ipairs(levels) do
        if total_practices >= level.min_practices and success_rate >= level.min_success_rate then
            current_level = level
            break
        end
    end
    
    -- Calculate progress for current level
    progress_filled = current_level.progress_func(total_practices)
    
    -- Ensure at least one block is shown if there's any progress
    if progress_filled == 0 and total_practices > 0 then
        progress_filled = 1
    end
    
    return progress_filled, progress_width
end

-- Show practice progress
function M.show_progress()
    local stats = require('scales.stats')
    local progress = stats.practice_log
    
    local progress_contents = {
        "╭────────────────────────────────────────────╮",
        "│            📊 PRACTICE PROGRESS 📊          │",
        "╰────────────────────────────────────────────╯",
        ""
    }
    
    -- Add total sessions with more detail
    table.insert(progress_contents, string.format("Total Practice Sessions: %.1f", progress.total_sessions or 0))
    table.insert(progress_contents, string.format("Total Patterns Practiced: %d", vim.tbl_count(progress.patterns_practiced or {})))
    table.insert(progress_contents, "")
    
    -- Add pattern-specific stats
    table.insert(progress_contents, "Pattern Statistics:")
    table.insert(progress_contents, "════════════════════════")
    
    -- Sort patterns by practice count
    local sorted_patterns = {}
    for pattern_name, practice_count in pairs(progress.patterns_practiced or {}) do
        table.insert(sorted_patterns, {
            name = pattern_name,
            count = practice_count
        })
    end
    
    table.sort(sorted_patterns, function(a, b)
        return a.count > b.count
    end)
    
    for _, pattern in ipairs(sorted_patterns) do
        local pattern_name = pattern.name
        local pattern_stats = (progress.timing_stats or {})[pattern_name] or {}
        local level, emoji = stats.get_achievement_level(
            pattern_stats.total_practices or 0,
            pattern_stats.first_attempt_successes or 0
        )
        
        table.insert(progress_contents, string.format("%s %s:", emoji, pattern_name))
        table.insert(progress_contents, string.format("  • Times Practiced: %.1f", pattern.count))
        
        if pattern_stats.total_practices and pattern_stats.total_practices > 0 then
            table.insert(progress_contents, string.format("  • Total Practices: %d", pattern_stats.total_practices))
        end
        
        if pattern_stats.first_attempt_successes and pattern_stats.first_attempt_successes > 0 then
            local success_rate = (pattern_stats.first_attempt_successes / pattern_stats.total_practices) * 100
            table.insert(progress_contents, string.format("  • First Attempt Success Rate: %.1f%%", success_rate))
        end
        
        if pattern_stats.best_time and pattern_stats.best_time > 0 then
            table.insert(progress_contents, string.format("  • Best Time: %s", format_time(pattern_stats.best_time)))
        end
        
        if pattern_stats.last_time and pattern_stats.last_time > 0 then
            local improvement = 0
            if pattern_stats.last_time > 0 and pattern_stats.best_time > 0 then
                improvement = ((pattern_stats.last_time - pattern_stats.best_time) / pattern_stats.last_time) * 100
            end
            local improvement_emoji = improvement > 0 and "📈" or "📉"
            table.insert(progress_contents, string.format("  • Last Time: %s (%s %.1f%%)", 
                format_time(pattern_stats.last_time),
                improvement_emoji,
                improvement))
        end
        
        table.insert(progress_contents, string.format("  • Level: %s", level))
        
        -- Add progress bar
        local total_practices = pattern_stats.total_practices or 0
        local first_attempt_successes = pattern_stats.first_attempt_successes or 0
        local progress_filled, progress_width = calculate_progress(total_practices, first_attempt_successes)
        
        local progress_bar = string.rep("█", progress_filled) .. string.rep("░", progress_width - progress_filled)
        table.insert(progress_contents, string.format("  • Progress: [%s]", progress_bar))
        
        -- Add next level requirements
        if level == "Beginner" then
            table.insert(progress_contents, "  • Next Level: 10 practices with 50% first-attempt success")
        elseif level == "Intermediate" then
            table.insert(progress_contents, "  • Next Level: 25 practices with 60% first-attempt success")
        elseif level == "Advanced" then
            table.insert(progress_contents, "  • Next Level: 50 practices with 70% first-attempt success")
        elseif level == "Expert" then
            table.insert(progress_contents, "  • Next Level: 100 practices with 80% first-attempt success")
        end
        
        table.insert(progress_contents, "")
    end
    
    -- Add attempt statistics
    if vim.tbl_count(progress.attempt_stats or {}) > 0 then
        table.insert(progress_contents, "Attempt Statistics:")
        table.insert(progress_contents, "════════════════════════")
        
        local total_attempts = 0
        local total_files = 0
        for _, attempts in pairs(progress.attempt_stats) do
            total_attempts = total_attempts + attempts
            total_files = total_files + 1
        end
        
        if total_files > 0 then
            table.insert(progress_contents, string.format("  • Average Attempts per File: %.1f", total_attempts / total_files))
        end
        table.insert(progress_contents, "")
    end
    
    -- Add footer
    table.insert(progress_contents, "╭────────────────────────────────────────────╮")
    table.insert(progress_contents, "│ Press q or <Esc> to close                  │")
    table.insert(progress_contents, "╰────────────────────────────────────────────╯")
    
    M.show_popup(progress_contents, {
        title = "Practice Progress",
        border = "rounded"
    })
end

-- Show success message
function M.show_success_message(pattern_name, is_first_validation, current_time)
    local stats = require('scales.stats')
    
    local success_message = {
        "✅ Perfect match!",
        "",
        string.format("Pattern: %s", pattern_name),
    }
    
    -- Add timing information if available
    local timing_stats = stats.practice_log.timing_stats[pattern_name]
    if timing_stats and timing_stats.last_time > 0 then
        -- Add current attempt time with milliseconds
        local time_str = string.format("%.3f seconds", timing_stats.last_time)
        table.insert(success_message, string.format("Time taken: %s", time_str))
        
        -- Add best time with comparison
        if timing_stats.best_time > 0 then
            -- Calculate time difference with milliseconds
            local time_diff = math.abs(timing_stats.last_time - timing_stats.best_time)
            local time_diff_str = string.format("%.3f seconds", time_diff)
            
            if timing_stats.last_time == timing_stats.best_time then
                table.insert(success_message, string.format("Best time: %s (🎉 New best time!)", 
                    string.format("%.3f seconds", timing_stats.best_time)))
            else
                if timing_stats.last_time > timing_stats.best_time then
                    -- Current attempt is slower than best
                    table.insert(success_message, string.format("Best time: %s (⏱️ %s to beat)", 
                        string.format("%.3f seconds", timing_stats.best_time),
                        time_diff_str))
                else
                    -- Current attempt is faster than best
                    table.insert(success_message, string.format("Best time: %s (⏱️ %s improvement)", 
                        string.format("%.3f seconds", timing_stats.best_time),
                        time_diff_str))
                end
            end
        end
        
        -- Always show previous time if available
        local previous_time = stats.practice_log.previous_times[pattern_name]
        if previous_time and previous_time > 0 and previous_time ~= timing_stats.last_time then
            local improvement = previous_time - timing_stats.last_time
            local improvement_str = string.format("%.3f seconds", math.abs(improvement))
            if improvement > 0 then
                table.insert(success_message, string.format("Previous time: %s (📈 %s faster than last time!)", 
                    string.format("%.3f seconds", previous_time),
                    improvement_str))
            else
                table.insert(success_message, string.format("Previous time: %s (📉 %s slower than last time)", 
                    string.format("%.3f seconds", previous_time),
                    improvement_str))
            end
        end
        
        -- Add practice progress
        local total_practices = timing_stats.total_practices or 0
        local first_attempt_successes = timing_stats.first_attempt_successes or 0
        local success_rate = total_practices > 0 and (first_attempt_successes / total_practices) * 100 or 0
        
        table.insert(success_message, "")
        table.insert(success_message, "📊 Practice Progress:")
        table.insert(success_message, string.format("  • Total Practices: %d", total_practices))
        table.insert(success_message, string.format("  • First Attempt Success Rate: %.1f%%", success_rate))
        
        -- Get current level and calculate progress toward next level
        local level, emoji = stats.get_achievement_level(total_practices, first_attempt_successes)
        local progress_filled, progress_width = calculate_progress(total_practices, first_attempt_successes)
        
        local progress_bar = string.rep("█", progress_filled) .. string.rep("░", progress_width - progress_filled)
        table.insert(success_message, string.format("  • Mastery Level: %s %s", emoji, level))
        table.insert(success_message, string.format("  • Progress: [%s]", progress_bar))
        
        -- Add next level requirements
        if level == "Beginner" then
            table.insert(success_message, "  • Next Level: 10 practices with 50% first-attempt success")
        elseif level == "Intermediate" then
            table.insert(success_message, "  • Next Level: 25 practices with 60% first-attempt success")
        elseif level == "Advanced" then
            table.insert(success_message, "  • Next Level: 50 practices with 70% first-attempt success")
        elseif level == "Expert" then
            table.insert(success_message, "  • Next Level: 100 practices with 80% first-attempt success")
        end
    end
    
    table.insert(success_message, "")
    table.insert(success_message, is_first_validation and "🎉 First attempt success!" or "💡 Practice makes perfect!")
    table.insert(success_message, "")
    table.insert(success_message, "Next steps:")
    
    -- Add appropriate next steps based on whether it's first attempt
    if is_first_validation then
        table.insert(success_message, "  • Try implementing the pattern from memory")
    else
        table.insert(success_message, "  • Try implementing faster next time")
    end
    table.insert(success_message, "  • Experiment with different approaches")
    table.insert(success_message, "  • Move on to a more challenging pattern")
    
    M.show_popup(success_message, {
        title = "Practice Validation",
        border = "rounded"
    })
end

-- Show commands and key mappings
function M.show_commands()
    local commands = {
        "╭────────────────────────────────────────────╮",
        "│            🎸 SCALES COMMANDS 🎸            │",
        "╰────────────────────────────────────────────╯",
        "",
        "Commands:",
        "════════════════════════",
        "  :ScalesGenerate [pattern]  - Start new practice",
        "  :ScalesOpen               - Open recent practice",
        "  :ScalesList               - Browse patterns",
        "  :ScalesStats              - Show progress",
        "  :ScalesValidate           - Test implementation",
        "  :ScalesPeek               - View solution",
        "  :ScalesNext               - Next practice",
        "  :ScalesReload             - Refresh templates",
        "  :ScalesSetup              - Re-run setup",
        "  :ScalesResetStats         - Reset current stats",
        "",
        "Key Mappings:",
        "════════════════════════",
        "  \\sg  - Generate practice",
        "  \\so  - Open practice",
        "  \\sv  - Validate code",
        "  \\sl  - List patterns",
        "  \\ss  - Show stats",
        "  \\sn  - Next practice",
        "  \\sp  - Peek solution",
        "",
        "╭────────────────────────────────────────────╮",
        "│ Press q or <Esc> to close                  │",
        "╰────────────────────────────────────────────╯"
    }
    
    M.show_popup(commands, {
        title = "Scales Commands",
        border = "rounded"
    })
end

return M