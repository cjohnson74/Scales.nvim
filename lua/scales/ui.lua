local M = {}

M.config = {}  -- Will be set by core.lua

-- Import required modules
local patterns = require('scales.patterns')
local stats = require('scales.stats')
local utils = require('scales.utils')

-- Constants
local BORDER = {
    TOP_LEFT = "╭",
    TOP_RIGHT = "╮",
    BOTTOM_LEFT = "╰",
    BOTTOM_RIGHT = "╯",
    HORIZONTAL = "─",
    VERTICAL = "│"
}

local EMOJI = {
    SUCCESS = "🎉",
    PATTERN = "🎸",
    TIME = "⏱️",
    TROPHY = "🏆",
    UP = "📈",
    DOWN = "📉",
    STATS = "📊",
    TARGET = "🎯",
    STAR = "⭐",
    LIGHT = "💡"
}

-- Track open windows for cleanup
local open_windows = {}

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
        table.insert(display_content, string.format("%s%s%s", BORDER.TOP_LEFT, string.rep(BORDER.HORIZONTAL, 58), BORDER.TOP_RIGHT))
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
            name = "Supreme",
            min_practices = 200,
            min_success_rate = 90,
            progress_func = function() return progress_width end
        },
        {
            name = "Grandmaster",
            min_practices = 150,
            min_success_rate = 85,
            progress_func = function(practices)
                return math.floor(progress_width * math.min((practices - 150) / 50, 1))
            end
        },
        {
            name = "Expert",
            min_practices = 100,
            min_success_rate = 80,
            progress_func = function(practices)
                return math.floor(progress_width * math.min((practices - 100) / 50, 1))
            end
        },
        {
            name = "Advanced",
            min_practices = 50,
            min_success_rate = 70,
            progress_func = function(practices)
                return math.floor(progress_width * math.min((practices - 50) / 50, 1))
            end
        },
        {
            name = "Intermediate",
            min_practices = 25,
            min_success_rate = 60,
            progress_func = function(practices)
                return math.floor(progress_width * math.min((practices - 25) / 25, 1))
            end
        },
        {
            name = "Novice",
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
    local patterns = require('scales.patterns')
    local stats = require('scales.stats')
    
    -- Calculate overall progress
    local total_patterns = vim.tbl_count(patterns.patterns)
    local patterns_mastered = 0
    local total_attempts = 0
    local successful_attempts = 0
    local pattern_progress = {}
    
    -- Calculate progress for each pattern
    for pattern_name, _ in pairs(patterns.patterns) do
        local timing_stats = stats.practice_log.timing_stats[pattern_name] or {}
        local total_practices = timing_stats.total_practices or 0
        local first_attempt_successes = timing_stats.first_attempt_successes or 0
        local attempts = stats.practice_log.attempt_stats[pattern_name] or 0
        local successes = stats.practice_log.validated_practices[pattern_name] and 1 or 0
        
        -- Calculate progress percentage based on first-attempt successes
        local progress = 0
        if total_practices > 0 then
            progress = math.floor((first_attempt_successes / total_practices) * 100)
        end
        
        -- Count as mastered if progress is 100%
        if progress == 100 then
            patterns_mastered = patterns_mastered + 1
        end
        
        -- Update attempt statistics
        total_attempts = total_attempts + attempts
        successful_attempts = successful_attempts + successes
        
        -- Store pattern progress
        pattern_progress[pattern_name] = {
            progress = progress,
            attempts = attempts,
            successes = successes,
            total_practices = total_practices,
            first_attempt_successes = first_attempt_successes,
            timing_stats = timing_stats
        }
    end
    
    -- Calculate overall progress
    local overall_progress = math.floor((patterns_mastered / total_patterns) * 100)
    
    -- Calculate success rate
    local success_rate = total_attempts > 0 and math.floor((successful_attempts / total_attempts) * 100) or 0
    
    local content = {
        "╭──────────────────────────────────────────────────────────────────────────────╮",
        "│                                📊 PRACTICE PROGRESS 📊                        │",
        "╰──────────────────────────────────────────────────────────────────────────────╯",
        "",
        string.format("  🎯 Overall Progress: %d%%", overall_progress),
        string.format("  🎸 Patterns Mastered: %d/%d", patterns_mastered, total_patterns),
        "",
        "  🎯 Pattern Progress",
        "  ═════════════════════════════════════════════════════════════════════════════"
    }
    
    -- Sort patterns by progress percentage
    local sorted_patterns = {}
    for pattern, data in pairs(pattern_progress) do
        table.insert(sorted_patterns, {
            name = pattern,
            progress = data.progress,
            attempts = data.attempts,
            successes = data.successes,
            total_practices = data.total_practices,
            first_attempt_successes = data.first_attempt_successes,
            timing_stats = data.timing_stats
        })
    end
    
    table.sort(sorted_patterns, function(a, b)
        return a.progress > b.progress
    end)
    
    -- Add pattern progress
    local progress_width = 30
    for _, item in ipairs(sorted_patterns) do
        local pattern_name = item.name
        local data = pattern_progress[pattern_name]
        local display_name = patterns.get_display_name(pattern_name)
        local progress = data.progress
        local progress_filled = math.floor(progress * progress_width / 100)
        local progress_empty = progress_width - progress_filled
        
        -- Get achievement level
        local level_name, level_emoji = stats.get_achievement_level(
            data.total_practices,
            data.first_attempt_successes
        )
        
        -- Add pattern progress line
        table.insert(content, string.format("  %s %s: [%s%s] %d%% (%d/%d)",
            level_emoji,
            display_name,
            string.rep("█", progress_filled),
            string.rep("░", progress_empty),
            progress,
            data.first_attempt_successes,
            data.total_practices
        ))
        
        -- Add detailed timing stats if available
        if data.timing_stats and data.timing_stats.total_practices and data.timing_stats.total_practices > 0 then
            -- Add practice count and success rate
            local success_rate = (data.first_attempt_successes / data.total_practices) * 100
            table.insert(content, string.format("    • Practices: %d (%.1f%% first-attempt success)", 
                data.total_practices,
                success_rate
            ))
            
            -- Add timing information
            if data.timing_stats.best_time and data.timing_stats.best_time > 0 then
                table.insert(content, string.format("    • Best Time: %.3f seconds", data.timing_stats.best_time))
            end
            if data.timing_stats.last_time and data.timing_stats.last_time > 0 then
                table.insert(content, string.format("    • Last Time: %.3f seconds", data.timing_stats.last_time))
            end
            
            -- Add achievement level
            table.insert(content, string.format("    • Level: %s %s", level_emoji, level_name))
            
            -- Add next level requirements
            if level_name == "Hatchling" then
                table.insert(content, "    • Next: 10 practices with 50% first-attempt success → Soaring Eagle")
            elseif level_name == "Soaring Eagle" then
                table.insert(content, "    • Next: 25 practices with 60% first-attempt success → Rising Phoenix")
            elseif level_name == "Rising Phoenix" then
                table.insert(content, "    • Next: 50 practices with 70% first-attempt success → Noble Lion")
            elseif level_name == "Noble Lion" then
                table.insert(content, "    • Next: 100 practices with 80% first-attempt success → Mystic Unicorn")
            elseif level_name == "Mystic Unicorn" then
                table.insert(content, "    • Next: 150 practices with 85% first-attempt success → Elder Dragon")
            elseif level_name == "Elder Dragon" then
                table.insert(content, "    • Next: 200 practices with 90% first-attempt success → Celestial Dragon")
            elseif level_name == "Celestial Dragon" then
                table.insert(content, "    • ⭐ You have reached the highest level! ⭐")
            end
        end
        
        table.insert(content, "")
    end
    
    -- Add attempt statistics with fancy header
    table.insert(content, "  🎯 Global Statistics")
    table.insert(content, "  ═════════════════════════════════════════════════════════════════════════════")
    table.insert(content, string.format("    • Total Attempts: %d", total_attempts))
    table.insert(content, string.format("    • Successful Attempts: %d", successful_attempts))
    table.insert(content, string.format("    • Success Rate: %d%%", success_rate))
    
    -- Add footer
    table.insert(content, "")
    table.insert(content, "╭──────────────────────────────────────────────────────────────────────────────╮")
    table.insert(content, "│ Press q or <Esc> to close                                                  │")
    table.insert(content, "╰──────────────────────────────────────────────────────────────────────────────╯")
    
    -- Create and show the floating window
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
    
    local width = 80  -- Increased width to prevent wrapping
    local height = #content
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded"
    })
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(bufnr, "readonly", true)
    vim.api.nvim_buf_set_option(bufnr, "wrap", false)  -- Disable text wrapping
    
    -- Add keymaps for closing
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', {
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_win_close(win_id, true)
        end
    })
    
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Esc>', '', {
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_win_close(win_id, true)
        end
    })
end

-- Show success message
function M.show_success_message(pattern_name, is_first_validation, timing_stats)
    local stats = require('scales.stats')
    
    local success_message = {
        "╭────────────────────────────────────────────╮",
        "│            🎉 PERFECT MATCH! 🎉             │",
        "╰────────────────────────────────────────────╯",
        "",
        string.format("  🎸 Pattern: %s", pattern_name),
    }
    
    -- Add timing information if available
    if timing_stats and type(timing_stats) == "table" and timing_stats.last_time > 0 then
        -- Add current attempt time with milliseconds
        local time_str = string.format("%.3f seconds", timing_stats.last_time)
        table.insert(success_message, string.format("  ⏱️ Time taken: %s", time_str))
        
        -- Add best time with comparison
        if timing_stats.best_time > 0 then
            -- Calculate time difference with milliseconds
            local time_diff = math.abs(timing_stats.last_time - timing_stats.best_time)
            local time_diff_str = string.format("%.3f seconds", time_diff)
            
            if timing_stats.last_time == timing_stats.best_time then
                table.insert(success_message, string.format("  🏆 Best time: %s (🎉 New best time!)", 
                    string.format("%.3f seconds", timing_stats.best_time)))
            else
                if timing_stats.last_time > timing_stats.best_time then
                    -- Current attempt is slower than best
                    table.insert(success_message, string.format("  🏆 Best time: %s (⏱️ %s to beat)", 
                        string.format("%.3f seconds", timing_stats.best_time),
                        time_diff_str))
                else
                    -- Current attempt is faster than best
                    table.insert(success_message, string.format("  🏆 Best time: %s (⏱️ %s improvement)", 
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
                table.insert(success_message, string.format("  ⏱️ Previous time: %s (📈 %s faster than last time!)", 
                    string.format("%.3f seconds", previous_time),
                    improvement_str))
            else
                table.insert(success_message, string.format("  ⏱️ Previous time: %s (📉 %s slower than last time)", 
                    string.format("%.3f seconds", previous_time),
                    improvement_str))
            end
        end
    end
    
    -- Add practice progress
    local total_practices = timing_stats.total_practices or 0
    local first_attempt_successes = timing_stats.first_attempt_successes or 0
    local success_rate = total_practices > 0 and (first_attempt_successes / total_practices) * 100 or 0
    
    table.insert(success_message, "")
    table.insert(success_message, "  📊 Practice Progress")
    table.insert(success_message, "  ════════════════════════════════════════════")
    table.insert(success_message, string.format("    • Total Practices: %d", total_practices))
    table.insert(success_message, string.format("    • First Attempt Success Rate: %.1f%%", success_rate))
    
    -- Get current level and calculate progress toward next level
    local level_name, level_emoji = stats.get_achievement_level(total_practices, first_attempt_successes)
    local progress_filled, progress_width = calculate_progress(total_practices, first_attempt_successes)
    
    local progress_bar = string.rep("█", progress_filled) .. string.rep("░", progress_width - progress_filled)
    table.insert(success_message, string.format("    • Mastery Level: %s %s", level_emoji, level_name))
    table.insert(success_message, string.format("    • Progress: [%s]", progress_bar))
    
    -- Add next level requirements with fancy arrows
    if level_name == "Hatchling" then
        table.insert(success_message, "    • Next Level: 10 practices with 50% first-attempt success → Soaring Eagle")
    elseif level_name == "Soaring Eagle" then
        table.insert(success_message, "    • Next Level: 25 practices with 60% first-attempt success → Rising Phoenix")
    elseif level_name == "Rising Phoenix" then
        table.insert(success_message, "    • Next Level: 50 practices with 70% first-attempt success → Noble Lion")
    elseif level_name == "Noble Lion" then
        table.insert(success_message, "    • Next Level: 100 practices with 80% first-attempt success → Mystic Unicorn")
    elseif level_name == "Mystic Unicorn" then
        table.insert(success_message, "    • Next Level: 150 practices with 85% first-attempt success → Elder Dragon")
    elseif level_name == "Elder Dragon" then
        table.insert(success_message, "    • Next Level: 200 practices with 90% first-attempt success → Celestial Dragon")
    elseif level_name == "Celestial Dragon" then
        table.insert(success_message, "    • ⭐ You have reached the highest level! ⭐")
        table.insert(success_message, "    • 🎉 Congratulations on achieving mastery! 🎉")
        table.insert(success_message, "    • ✨ Your dedication has been rewarded ✨")
    end
    
    table.insert(success_message, "")
    table.insert(success_message, "  🎯 Next Steps")
    table.insert(success_message, "  ════════════════════════════════════════════")
    
    -- Add appropriate next steps based on whether it's first attempt
    if is_first_validation then
        table.insert(success_message, "    • 🎉 First attempt success!")
        table.insert(success_message, "    • Try implementing the pattern from memory")
    else
        table.insert(success_message, "    • 💡 Practice makes perfect!")
        table.insert(success_message, "    • Try implementing faster next time")
        table.insert(success_message, "    • Note: This attempt doesn't count toward your progress")
        table.insert(success_message, "      because the goal is to get it right on the first try")
        table.insert(success_message, "      to build true pattern recognition skills")
    end
    
    -- Common next steps for all attempts
    table.insert(success_message, "    • Experiment with different approaches")
    table.insert(success_message, "    • Move on to a more challenging pattern")
    
    -- Add footer
    table.insert(success_message, "")
    table.insert(success_message, "╭────────────────────────────────────────────╮")
    table.insert(success_message, "│ Press q or <Esc> to close                  │")
    table.insert(success_message, "╰────────────────────────────────────────────╯")
    
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