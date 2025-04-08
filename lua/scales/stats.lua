local M = {}

M.config = {}  -- Will be set by core.lua

-- Initialize practice log
M.practice_log = {
    total_sessions = 0,
    patterns_practiced = {},
    timing_stats = {},
    attempt_stats = {}  -- Track attempts per file
}

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
            total_practices = 0,
            first_attempt_successes = 0
        }
    else
        M.practice_log.timing_stats[pattern_name].start_time = os.time()
    end
end

-- Pause timing for a practice session
function M.pause_timing(pattern_name)
    if not M.practice_log.timing_stats[pattern_name] then
        return
    end
    
    local stats = M.practice_log.timing_stats[pattern_name]
    local current_time = os.time()
    local time_elapsed = current_time - stats.start_time
    
    -- Update last time if it's better than the current best
    if stats.best_time == 0 or time_elapsed < stats.best_time then
        stats.best_time = time_elapsed
    end
    
    stats.last_time = time_elapsed
    stats.start_time = current_time  -- Reset start time for next session
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
            improvement = 0
        }
    end
    
    local stats = M.practice_log.timing_stats[pattern_name]
    local end_time = os.time()
    local time_taken = end_time - stats.start_time
    
    -- Update statistics
    local old_best = stats.best_time
    stats.last_time = time_taken
    stats.total_practices = stats.total_practices + 1
    
    -- Track first-attempt successes
    if attempt_count == 1 then
        stats.first_attempt_successes = stats.first_attempt_successes + 1
    end
    
    -- Update best time if this is better
    local is_new_best = false
    if stats.best_time == 0 or time_taken < stats.best_time then
        stats.best_time = time_taken
        is_new_best = true
    end
    
    -- Calculate improvement in seconds
    local improvement = 0
    if old_best > 0 and time_taken < old_best then
        improvement = old_best - time_taken
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
        improvement = improvement,
        is_new_best = is_new_best
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
            total_practices = 0,
            first_attempt_successes = 0
        }
        M.save_stats()
        vim.notify("Reset timing for " .. pattern_name, vim.log.levels.INFO)
    end
end

return M 