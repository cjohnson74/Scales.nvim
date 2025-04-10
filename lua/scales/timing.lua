local utils = require('scales.utils')

-- Remove the format_time function since we're using utils.format_time now

function M.get_timing_stats()
    local stats = {
        best_time = best_times[current_pattern],
        last_time = last_times[current_pattern],
        total_practices = total_practices[current_pattern] or 0,
        average_time = calculate_average_time(current_pattern)
    }
    return stats
end

function M.calculate_average_time(pattern)
    if not pattern or not practice_times[pattern] or #practice_times[pattern] == 0 then
        return nil
    end
    
    local sum = 0
    for _, time in ipairs(practice_times[pattern]) do
        sum = sum + time
    end
    return sum / #practice_times[pattern]
end

function M.show_timing_stats()
    local stats = M.get_timing_stats()
    local message = "Timing Statistics:\n"
    
    if stats.best_time then
        message = message .. "Best time: " .. utils.format_time(stats.best_time) .. "\n"
    end
    
    if stats.last_time then
        message = message .. "Last time: " .. utils.format_time(stats.last_time) .. "\n"
    end
    
    if stats.average_time then
        message = message .. "Average time: " .. utils.format_time(stats.average_time) .. "\n"
    end
    
    message = message .. "Total practices: " .. stats.total_practices
    
    vim.notify(message, vim.log.levels.INFO)
end 