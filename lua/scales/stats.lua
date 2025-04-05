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
        vim.notify(string.format("Paused timing for %s at %d", pattern_name, stats.paused_time), vim.log.levels.INFO)
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
        vim.notify(string.format("Resumed timing for %s after %d seconds", pattern_name, pause_duration), vim.log.levels.INFO)
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
        vim.notify(string.format("Ending timing for %s after %d seconds of pause", pattern_name, pause_duration), vim.log.levels.INFO)
    end
    
    local time_taken = end_time - stats.start_time
    vim.notify(string.format("Total time taken for %s: %d seconds", pattern_name, time_taken), vim.log.levels.INFO)
    
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

return M 