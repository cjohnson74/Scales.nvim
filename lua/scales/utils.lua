local M = {}

-- Format time in a human-readable way
function M.format_time(seconds)
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

-- Extract pattern name from file path
function M.get_pattern_name(file_path)
    if not file_path then
        return nil
    end
    
    local pattern_dir = vim.fn.fnamemodify(file_path, ':h')
    return vim.fn.fnamemodify(pattern_dir, ':t')
end

-- Helper function to strip comments and normalize whitespace
function M.process_line(line)
    -- Remove comments and normalize in one pass
    line = line:gsub("%s*#.*$", ""):gsub("^%s*#.*$", "")
    -- Normalize whitespace while preserving indentation
    local leading_ws = line:match("^(%s*)")
    local content = line:gsub("%s*$", ""):gsub("%s+", " ")
    return leading_ws .. content
end

return M 