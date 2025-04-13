local M = {}

M.config = {}  -- Will be set by core.lua

-- Initialize practice log
M.practice_log = {
    total_sessions = 0,
    patterns_practiced = {},
    timing_stats = {},
    attempt_stats = {},  -- Track attempts per file
    previous_times = {},  -- Track previous attempt times per pattern
    validated_practices = {}
}

-- Track successful validations per session
local session_validation_tracker = {}

-- Reset session validation tracker
function M.reset_session_validation()
    session_validation_tracker = {}
end

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
        -- Initialize with default values, preserving any existing stats
        M.practice_log.timing_stats[pattern_name] = {
            start_time = vim.loop.hrtime() / 1e9,  -- Convert to seconds immediately
            last_time = 0,
            best_time = 0,
            total_practices = 0,
            first_attempt_successes = 0,
            previous_time = 0
        }
    else
        -- Just update the start time for existing pattern
        M.practice_log.timing_stats[pattern_name].start_time = vim.loop.hrtime() / 1e9
    end
end

-- Pause timing for a practice session
function M.pause_timing(pattern_name)
    if not M.practice_log.timing_stats[pattern_name] then
        return
    end
    
    local stats = M.practice_log.timing_stats[pattern_name]
    local current_time = vim.loop.hrtime() / 1e9  -- Convert to seconds immediately
    local time_elapsed = current_time - stats.start_time
    
    -- Only update last time, not best time
    stats.last_time = time_elapsed
    -- Don't reset start_time, so we preserve the total time spent
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

-- End timing and record the practice session
function M.end_timing(pattern_name, success)
    if not M.practice_log.timing_stats[pattern_name] then
        return
    end

    local stats = M.practice_log.timing_stats[pattern_name]
    local end_time = vim.loop.hrtime() / 1e9
    local duration = end_time - stats.start_time

    -- Update timing stats
    stats.last_time = duration

    -- Only update previous time if this was a successful validation
    if success then
        stats.previous_time = stats.last_time
    end

    -- Only update best time if this is better than previous best
    if stats.best_time == 0 or duration < stats.best_time then
        stats.best_time = duration
    end

    -- Increment total practices
    stats.total_practices = stats.total_practices + 1

    -- Update first attempt success if this was a first attempt
    if success and not M.practice_log.validated_practices[pattern_name] then
        stats.first_attempt_successes = stats.first_attempt_successes + 1
    end

    -- Mark as validated if successful
    if success then
        M.practice_log.validated_practices[pattern_name] = true
    end

    -- Calculate improvement
    local improvement = 0
    if stats.best_time > 0 then
        improvement = stats.best_time - duration
    end
    
    -- Update pattern practice count with attempt weighting
    local attempt_weight = 1.0 / (M.practice_log.attempt_stats[pattern_name] or 1)  -- Reduce weight based on attempts
    M.practice_log.patterns_practiced[pattern_name] = (M.practice_log.patterns_practiced[pattern_name] or 0) + attempt_weight
    M.practice_log.total_sessions = M.practice_log.total_sessions + attempt_weight
    
    -- Save stats after update
    M.save_stats()
    
    return {
        last_time = stats.last_time,
        best_time = stats.best_time,
        previous_time = stats.previous_time,
        improvement = improvement,
        is_new_best = stats.best_time == duration
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
        attempt_stats = {},
        previous_times = {},
        validated_practices = {}
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
            
            if type(data.previous_times) == "table" then
                if #data.previous_times > 0 then
                    -- Convert array to table
                    local new_previous_times = {}
                    for _, time in ipairs(data.previous_times) do
                        new_previous_times[data.timing_stats[time.pattern].pattern] = time.time
                    end
                    data.previous_times = new_previous_times
                end
            end
            
            if type(data.validated_practices) == "table" then
                if #data.validated_practices > 0 then
                    -- Convert array to table
                    local new_validated_practices = {}
                    for _, practice in ipairs(data.validated_practices) do
                        new_validated_practices[practice] = true
                    end
                    data.validated_practices = new_validated_practices
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
        attempt_stats = M.practice_log.attempt_stats or {},
        previous_times = M.practice_log.previous_times or {},
        validated_practices = M.practice_log.validated_practices or {}
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
        return "Hatchling", "🐣"
    end
    
    local success_rate = first_attempt_successes / practice_count
    
    if practice_count >= 200 and success_rate >= 0.9 then
        return "Celestial Dragon", "🐲"  -- Supreme mastery, mythical and powerful
    elseif practice_count >= 150 and success_rate >= 0.85 then
        return "Elder Dragon", "🐉"  -- Ancient wisdom and experience
    elseif practice_count >= 100 and success_rate >= 0.8 then
        return "Mystic Unicorn", "🦄"  -- Rare and exceptional skill
    elseif practice_count >= 50 and success_rate >= 0.7 then
        return "Noble Lion", "🦁"  -- Strong and confident
    elseif practice_count >= 25 and success_rate >= 0.6 then
        return "Rising Phoenix", "🦚"  -- Reborn through practice
    elseif practice_count >= 10 and success_rate >= 0.5 then
        return "Soaring Eagle", "🦅"  -- Gaining altitude in skills
    else
        return "Hatchling", "🐣"  -- Just starting the journey
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
    
    -- Only reset the current session's timing stats
    if M.practice_log.timing_stats[pattern_name] then
        -- Preserve historical stats
        local historical_stats = {
            total_practices = M.practice_log.timing_stats[pattern_name].total_practices,
            first_attempt_successes = M.practice_log.timing_stats[pattern_name].first_attempt_successes,
            best_time = M.practice_log.timing_stats[pattern_name].best_time
        }
        
        -- Reset only the current session's timing
        M.practice_log.timing_stats[pattern_name] = {
            start_time = vim.loop.hrtime() / 1e9,  -- Convert to seconds immediately
            last_time = 0,
            best_time = historical_stats.best_time,  -- Keep historical best time
            total_practices = historical_stats.total_practices,  -- Keep total practices
            first_attempt_successes = historical_stats.first_attempt_successes,  -- Keep first attempt successes
            previous_time = 0
        }
        
        M.save_stats()
        vim.notify("Reset current session for " .. pattern_name, vim.log.levels.INFO)
    end
end

-- Record successful validation without ending the timer
function M.record_validation(pattern_name, attempt_count)
    -- Check if this pattern was already validated in this session
    if session_validation_tracker[pattern_name] then
        -- Return current stats without updating
        local stats = M.practice_log.timing_stats[pattern_name] or {
            last_time = 0,
            best_time = 0,
            previous_time = 0,
            total_practices = 0,
            first_attempt_successes = 0
        }
        return {
            last_time = stats.last_time,
            best_time = stats.best_time,
            previous_time = stats.previous_time,
            total_practices = stats.total_practices,
            first_attempt_successes = stats.first_attempt_successes
        }
    end

    if not M.practice_log.timing_stats[pattern_name] then
        M.practice_log.timing_stats[pattern_name] = {
            start_time = vim.loop.hrtime() / 1e9,  -- Convert to seconds immediately
            last_time = 0,
            best_time = 0,
            total_practices = 0,
            first_attempt_successes = 0,
            previous_time = 0
        }
    end
    
    local stats = M.practice_log.timing_stats[pattern_name]
    local current_time = (vim.loop.hrtime() / 1e9) - stats.start_time  -- Convert to seconds immediately
    
    -- Store previous time before updating
    local previous_time = stats.last_time or 0
    stats.previous_time = previous_time
    M.practice_log.previous_times[pattern_name] = previous_time
    
    -- Update statistics
    stats.last_time = current_time
    
    -- Increment practice count for every successful validation
    stats.total_practices = (stats.total_practices or 0) + 1
    
    -- Only count as first attempt success if this is the first attempt
    if attempt_count == 1 then
        stats.first_attempt_successes = (stats.first_attempt_successes or 0) + 1
    end
    
    -- Update best time if this is better
    if stats.best_time == 0 or current_time < stats.best_time then
        stats.best_time = current_time
    end
    
    -- Mark this pattern as validated in this session
    session_validation_tracker[pattern_name] = true
    
    -- Save stats after update
    M.save_stats()
    
    return {
        last_time = stats.last_time,
        best_time = stats.best_time,
        previous_time = previous_time,
        total_practices = stats.total_practices,
        first_attempt_successes = stats.first_attempt_successes
    }
end

return M 