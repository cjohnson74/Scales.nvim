local M = {}

M.config = {}  -- Will be set by core.lua

-- Initialize practice log
M.practice_log = {
    total_sessions = 0,
    patterns_practiced = {},
    timing_stats = {},
    attempt_stats = {}  -- Track attempts per file
}

-- Track last activity time
local last_activity_time = os.time()
M.auto_pause_timer = nil  -- Make timer accessible
local AUTO_PAUSE_TIMEOUT = 30  -- 30 seconds of inactivity
local last_debug_time = 0  -- Track last debug message time

-- Ensure stats directory exists
local function ensure_stats_dir()
    if not M.config or not M.config.practice_dir then
        vim.notify("Practice directory not configured", vim.log.levels.ERROR)
        return false
    end
    
    -- Create practice directory if it doesn't exist
    vim.fn.mkdir(M.config.practice_dir, 'p')
    return true
end

-- Start timing a practice session
function M.start_timing(pattern_name)
    if not M.practice_log.timing_stats[pattern_name] then
        M.practice_log.timing_stats[pattern_name] = {
            start_time = os.time(),
            last_time = 0,
            best_time = 0,
            average_time = 0,
            total_practices = 0,
            first_attempt_successes = 0,
            paused_time = 0,
            is_paused = false
        }
    else
        M.practice_log.timing_stats[pattern_name].start_time = os.time()
        M.practice_log.timing_stats[pattern_name].paused_time = 0
        M.practice_log.timing_stats[pattern_name].is_paused = false
    end
end

-- Pause timing for a practice session
function M.pause_timing(pattern_name)
    if not M.practice_log.timing_stats[pattern_name] then
        return
    end
    
    local stats = M.practice_log.timing_stats[pattern_name]
    if not stats.is_paused then
        stats.paused_time = os.time()
        stats.is_paused = true
    end
end

-- Resume timing for a practice session
function M.resume_timing(pattern_name)
    if not M.practice_log.timing_stats[pattern_name] then
        return
    end
    
    local stats = M.practice_log.timing_stats[pattern_name]
    if stats.is_paused then
        local pause_duration = os.time() - stats.paused_time
        stats.start_time = stats.start_time + pause_duration
        stats.paused_time = 0
        stats.is_paused = false
        
        -- Update statusline
        vim.api.nvim_exec_autocmds('User', { pattern = 'ScalesTimingStatusChanged' })
    end
end

-- Track a validation attempt
function M.track_attempt(file_path)
    M.practice_log.attempt_stats[file_path] = (M.practice_log.attempt_stats[file_path] or 0) + 1
    return M.practice_log.attempt_stats[file_path]
end

-- Get attempt count for a file
function M.get_attempt_count(file_path)
    return M.practice_log.attempt_stats[file_path] or 0
end

-- End timing and update statistics
function M.end_timing(file_path)
    local pattern_dir = vim.fn.fnamemodify(file_path, ':h')
    local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
    local attempt_count = M.get_attempt_count(file_path)
    
    if not M.practice_log.timing_stats[pattern_name] then
        return {
            last_time = 0,
            best_time = 0,
            average_time = 0
        }
    end
    
    local stats = M.practice_log.timing_stats[pattern_name]
    local end_time = os.time()
    
    -- If paused, add the pause duration to the start time
    if stats.is_paused then
        local pause_duration = end_time - stats.paused_time
        stats.start_time = stats.start_time + pause_duration
        stats.paused_time = 0
        stats.is_paused = false
    end
    
    local time_taken = end_time - stats.start_time
    
    -- Update statistics
    stats.last_time = time_taken
    stats.total_practices = stats.total_practices + 1
    
    -- Track first-attempt successes
    if attempt_count == 1 then
        stats.first_attempt_successes = stats.first_attempt_successes + 1
    end
    
    if stats.best_time == 0 or time_taken < stats.best_time then
        stats.best_time = time_taken
    end
    
    -- Update average time
    if stats.total_practices == 1 then
        stats.average_time = time_taken
    else
        stats.average_time = (stats.average_time * (stats.total_practices - 1) + time_taken) / stats.total_practices
    end
    
    -- Update pattern practice count with attempt weighting
    local attempt_weight = 1.0 / attempt_count  -- Reduce weight based on attempts
    M.practice_log.patterns_practiced[pattern_name] = (M.practice_log.patterns_practiced[pattern_name] or 0) + attempt_weight
    M.practice_log.total_sessions = M.practice_log.total_sessions + attempt_weight
    
    -- Save stats after update
    M.save_stats()
    
    return {
        last_time = stats.last_time,
        best_time = stats.best_time,
        average_time = stats.average_time,
        first_attempt_successes = stats.first_attempt_successes
    }
end

-- Load statistics from file
function M.load_stats()
    if not ensure_stats_dir() then
        return
    end
    
    local stats_file = M.config.practice_dir .. "/stats.json"
    
    -- Initialize with default values
    M.practice_log = {
        total_sessions = 0,
        patterns_practiced = {},
        timing_stats = {},
        attempt_stats = {}
    }
    
    -- Check if file exists and is readable
    if vim.fn.filereadable(stats_file) == 1 then
        local success, data = pcall(vim.fn.json_decode, vim.fn.readfile(stats_file))
        if success and data then
            -- Convert arrays to tables if needed
            if type(data.patterns_practiced) == "table" then
                if #data.patterns_practiced > 0 then
                    -- Convert array to table
                    local new_patterns = {}
                    for _, pattern in ipairs(data.patterns_practiced) do
                        new_patterns[pattern] = 1
                    end
                    data.patterns_practiced = new_patterns
                end
            end
            
            if type(data.timing_stats) == "table" then
                if #data.timing_stats > 0 then
                    -- Convert array to table
                    local new_timing = {}
                    for _, stat in ipairs(data.timing_stats) do
                        new_timing[stat.pattern] = stat
                    end
                    data.timing_stats = new_timing
                end
            end
            
            if type(data.attempt_stats) == "table" then
                if #data.attempt_stats > 0 then
                    -- Convert array to table
                    local new_attempts = {}
                    for _, attempt in ipairs(data.attempt_stats) do
                        new_attempts[attempt.file] = attempt.count
                    end
                    data.attempt_stats = new_attempts
                end
            end
            
            -- Merge with default values
            M.practice_log = vim.tbl_deep_extend("force", M.practice_log, data)
        else
            vim.notify("Failed to load stats file: " .. tostring(data), vim.log.levels.ERROR)
        end
    else
        -- Initialize new stats file
        M.save_stats()
    end
end

-- Save statistics to file
function M.save_stats()
    if not ensure_stats_dir() then
        return
    end
    
    local stats_file = M.config.practice_dir .. "/stats.json"
    
    -- Ensure data is in the correct format before saving
    local save_data = {
        total_sessions = M.practice_log.total_sessions or 0,
        patterns_practiced = M.practice_log.patterns_practiced or {},
        timing_stats = M.practice_log.timing_stats or {},
        attempt_stats = M.practice_log.attempt_stats or {}
    }
    
    local success, err = pcall(function()
        vim.fn.writefile({vim.fn.json_encode(save_data)}, stats_file)
    end)
    
    if not success then
        vim.notify("Failed to save stats: " .. tostring(err), vim.log.levels.ERROR)
    end
end

-- Get formatted time string
function M.format_time(seconds)
    if seconds < 60 then
        return string.format("%.1f seconds", seconds)
    else
        local minutes = math.floor(seconds / 60)
        local remaining_seconds = seconds % 60
        return string.format("%d minutes and %.1f seconds", minutes, remaining_seconds)
    end
end

-- Get achievement level based on practice count and first-attempt success rate
function M.get_achievement_level(practice_count, first_attempt_successes)
    if practice_count == 0 then
        return "Beginner", "🌱"
    end
    
    local success_rate = first_attempt_successes / practice_count
    
    if practice_count >= 100 and success_rate >= 0.8 then
        return "Master", "🏆"
    elseif practice_count >= 50 and success_rate >= 0.7 then
        return "Expert", "🌟"
    elseif practice_count >= 25 and success_rate >= 0.6 then
        return "Advanced", "⭐"
    elseif practice_count >= 10 and success_rate >= 0.5 then
        return "Intermediate", "🌱"
    else
        return "Beginner", "🌱"
    end
end

-- Update last activity time
function M.update_activity_time()
    local old_time = last_activity_time
    last_activity_time = os.time()
    vim.schedule(function()
        vim.notify(string.format("Activity detected - Old time: %d, New time: %d, Time since last activity: %d", 
            old_time, 
            last_activity_time,
            last_activity_time - old_time), 
            vim.log.levels.INFO)
    end)
end

-- Check if timing is paused for current pattern
function M.is_timing_paused()
    local current_file = vim.fn.expand('%:p')
    if not current_file:match('practice%.py$') then
        return false
    end
    
    local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
    local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
    
    if not pattern_name or pattern_name == '' then
        return false
    end
    
    local stats = M.practice_log.timing_stats[pattern_name]
    return stats and stats.is_paused or false
end

-- Get timing status for statusline
function M.get_timing_status()
    if M.is_timing_paused() then
        return "⏸️ Paused"
    end
    return "▶️ Timing"
end

-- Start auto-pause timer
function M.start_auto_pause_timer()
    -- Stop any existing timer
    if M.auto_pause_timer then
        M.auto_pause_timer:stop()
        M.auto_pause_timer:close()
        M.auto_pause_timer = nil
    end
    
    -- Reset activity tracking
    last_activity_time = os.time()
    last_debug_time = os.time()
    
    vim.notify("Starting timer with last_activity_time: " .. last_activity_time, vim.log.levels.INFO)
    
    -- Create and start new timer
    M.auto_pause_timer = vim.loop.new_timer()
    M.auto_pause_timer:start(1000, 1000, function()  -- Check every second
        local current_time = os.time()
        local inactive_time = current_time - last_activity_time
        
        -- Debug: Always show current state
        vim.schedule(function()
            vim.notify(string.format("Timer running - Current time: %d, Last activity: %d, Inactive for: %d seconds, Auto-pause timeout: %d", 
                current_time, 
                last_activity_time, 
                inactive_time,
                AUTO_PAUSE_TIMEOUT), 
                vim.log.levels.INFO)
        end)
        
        -- Only show debug message every 5 seconds
        if current_time - last_debug_time >= 5 then
            last_debug_time = current_time
            -- Use vim.schedule to safely update UI
            vim.schedule(function()
                vim.notify(string.format("Inactive for %d seconds", inactive_time), vim.log.levels.INFO)
            end)
        end
        
        if inactive_time >= AUTO_PAUSE_TIMEOUT then
            -- Get current file and pattern
            local current_file = vim.fn.expand('%:p')
            if current_file:match('practice%.py$') then
                local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
                local pattern_name = vim.fn.fnamemodify(pattern_dir, ':t')
                
                if pattern_name and pattern_name ~= '' then
                    -- Only pause if not already paused
                    local stats = M.practice_log.timing_stats[pattern_name]
                    if stats and not stats.is_paused then
                        M.pause_timing(pattern_name)
                        -- Use vim.schedule to safely update UI
                        vim.schedule(function()
                            vim.notify(string.format("Auto-paused timing for %s after %d seconds of inactivity", 
                                pattern_name, 
                                inactive_time), 
                                vim.log.levels.INFO)
                            -- Update statusline
                            vim.api.nvim_exec_autocmds('User', { pattern = 'ScalesTimingStatusChanged' })
                        end)
                    end
                end
            end
        end
    end)
end

-- Stop auto-pause timer
function M.stop_auto_pause_timer()
    if M.auto_pause_timer then
        M.auto_pause_timer:stop()
        M.auto_pause_timer:close()
        M.auto_pause_timer = nil
    end
end

-- Reset timing for current practice session
function M.reset_current_timing()
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
    
    -- Reset timing stats for this pattern
    if M.practice_log.timing_stats[pattern_name] then
        M.practice_log.timing_stats[pattern_name] = {
            start_time = os.time(),
            last_time = 0,
            best_time = 0,
            average_time = 0,
            total_practices = 0,
            first_attempt_successes = 0,
            paused_time = 0,
            is_paused = false
        }
        M.save_stats()
        vim.notify("Reset timing for " .. pattern_name, vim.log.levels.INFO)
    end
end

return M 