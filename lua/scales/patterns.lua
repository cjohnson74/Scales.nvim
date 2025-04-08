local M = {}

M.patterns = {}
M.config = {}  -- Will be set by core.lua
M._templates_loaded = false  -- Track if templates are already loaded

-- Load templates from filesystem
function M.load_templates()
    -- Prevent duplicate loading
    if M._templates_loaded then
        return M.patterns
    end
    
    if not M.config or not M.config.templates_dir then
        vim.notify("Templates directory not configured", vim.log.levels.ERROR)
        return {}
    end
    
    local templates_dir = M.config.templates_dir
    local patterns = {}
    
    -- Check if directory exists and is accessible
    local dir_exists = vim.fn.isdirectory(templates_dir)
    if not dir_exists then
        vim.notify("Templates directory does not exist: " .. templates_dir, vim.log.levels.ERROR)
        return patterns
    end
    
    -- Check if directory is readable
    local test_file = templates_dir .. '/1_binary_search/template.py'
    local dir_readable = vim.fn.filereadable(test_file) == 1
    
    if not dir_readable then
        vim.notify("Templates directory not readable: " .. templates_dir, vim.log.levels.ERROR)
        return patterns
    end
    
    -- Load patterns from filesystem
    local pattern_dirs = vim.fn.glob(templates_dir .. '/*', 1, 1)
    for _, dir in ipairs(pattern_dirs) do
        local pattern_name = vim.fn.fnamemodify(dir, ':t')
        local template_file = dir .. '/template.py'
        local practice_file = dir .. '/practice.py'
        
        if vim.fn.filereadable(template_file) == 1 then
            -- Read template content
            local template_content = vim.fn.readfile(template_file)
            
            -- Extract pattern name and description from directory name
            local name_parts = vim.split(pattern_name, '_')
            local name = ''
            local description = ''
            
            for i, part in ipairs(name_parts) do
                if i > 1 then  -- Skip the number prefix
                    if i == 2 then
                        name = part
                    else
                        name = name .. ' ' .. part
                    end
                end
            end
            
            -- Capitalize first letter of each word
            name = name:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
            description = "Practice " .. name:lower() .. " technique"
            
            -- Set default difficulty based on pattern name
            local difficulty = 3  -- Default to intermediate
            if name:lower():match("binary") or name:lower():match("two pointer") then
                difficulty = 2
            elseif name:lower():match("sliding window") then
                difficulty = 3
            elseif name:lower():match("dfs") or name:lower():match("bfs") then
                difficulty = 4
            elseif name:lower():match("dynamic programming") or name:lower():match("backtracking") then
                difficulty = 5
            end
            
            patterns[pattern_name] = {
                name = name,
                description = description,
                template = table.concat(template_content, '\n'),
                template_path = template_file,
                practice_path = practice_file,
                difficulty = difficulty
            }
        end
    end
    
    -- Mark templates as loaded
    M._templates_loaded = true
    M.patterns = patterns
    
    return patterns
end

-- Generate a practice session
function M.generate_practice(pattern_name)
    -- Check if current buffer has unsaved changes
    if vim.bo.modified then
        vim.cmd('write')
    end

    -- If no pattern specified, choose randomly
    if not pattern_name or pattern_name == "" then
        local pattern_keys = vim.tbl_keys(M.patterns)
        if #pattern_keys == 0 then
            vim.notify("No patterns available. Check your templates directory.", vim.log.levels.ERROR)
            return
        end
        pattern_name = pattern_keys[math.random(#pattern_keys)]
    end
    
    local pattern = M.patterns[pattern_name]
    if not pattern then
        vim.notify("Pattern not found: " .. pattern_name, vim.log.levels.ERROR)
        return
    end
    
    -- Create pattern directory if it doesn't exist
    local pattern_dir = string.format("%s/%s", 
        M.config.practice_dir,
        pattern_name
    )
    vim.fn.mkdir(pattern_dir, 'p')
    
    -- Create template file if it doesn't exist
    local template_file = pattern_dir .. "/template.py"
    if vim.fn.filereadable(template_file) == 0 then
        vim.fn.writefile(vim.split(pattern.template, "\n"), template_file)
    end
    
    -- Create practice file with instructions
    local practice_file = pattern_dir .. "/practice.py"
    local instructions = {
        string.format("# Practice: %s", pattern.name),
        "# Implement the pattern from scratch",
        "# When ready, run :ScalesValidate to check your implementation",
        "",
        "# Your implementation goes here:",
        ""
    }
    vim.fn.writefile(instructions, practice_file)
    
    -- Start timing before opening the file
    local stats = require('scales.stats')
    stats.start_timing(pattern_name)
    
    -- Open the practice file with noautocmd to avoid triggering auto-commands that might cause issues
    vim.cmd('noautocmd edit ' .. practice_file)
end

-- Open the most recently generated practice file
function M.open_current_practice()
    -- Check if current buffer has unsaved changes
    if vim.bo.modified then
        vim.cmd('write')
    end

    local practice_dir = M.config.practice_dir
    
    -- Get list of pattern directories
    local patterns = vim.fn.glob(practice_dir .. "/*", true, true)
    
    if #patterns == 0 then
        vim.notify("No practice patterns found. Generate a practice first.", vim.log.levels.WARN)
        return
    end
    
    -- Find the most recently modified practice file
    local most_recent = nil
    local most_recent_time = 0
    
    for _, pattern in ipairs(patterns) do
        local practice_file = pattern .. "/practice.py"
        if vim.fn.filereadable(practice_file) == 1 then
            local mtime = vim.fn.getftime(practice_file)
            if mtime > most_recent_time then
                most_recent_time = mtime
                most_recent = practice_file
            end
        end
    end
    
    if most_recent then
        vim.cmd('noautocmd edit ' .. most_recent)
    else
        vim.notify("No practice files found. Generate a practice first.", vim.log.levels.WARN)
    end
end

-- List available patterns
function M.list_patterns()
    local patterns = M.patterns
    if vim.tbl_count(patterns) == 0 then
        vim.api.nvim_err_write("No patterns available\n")
        return
    end
    
    -- Sort patterns by difficulty
    local sorted_patterns = {}
    for name, pattern in pairs(patterns) do
        -- Ensure difficulty is set
        pattern.difficulty = pattern.difficulty or 3  -- Default to intermediate if not set
        table.insert(sorted_patterns, {
            name = name,
            pattern = pattern
        })
    end
    
    table.sort(sorted_patterns, function(a, b)
        if a.pattern.difficulty ~= b.pattern.difficulty then
            return a.pattern.difficulty < b.pattern.difficulty
        end
        return a.name < b.name
    end)
    
    -- Group patterns by difficulty
    local beginner_patterns = {}
    local intermediate_patterns = {}
    local advanced_patterns = {}
    
    for _, item in ipairs(sorted_patterns) do
        if item.pattern.difficulty <= 2 then
            table.insert(beginner_patterns, item)
        elseif item.pattern.difficulty <= 4 then
            table.insert(intermediate_patterns, item)
        else
            table.insert(advanced_patterns, item)
        end
    end
    
    -- Create buffer for pattern display
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = {}
    local pattern_map = {}  -- Maps line numbers to pattern names
    local current_line = 0
    
    -- Add header
    table.insert(lines, "╭────────────────────────────────────────────╮")
    table.insert(lines, "│            🧠 SCALES PATTERNS 🧠            │")
    table.insert(lines, "╰────────────────────────────────────────────╯")
    table.insert(lines, "")
    current_line = current_line + 4
    
    -- Add beginner patterns
    if #beginner_patterns > 0 then
        table.insert(lines, "🌱 BEGINNER PATTERNS 🌱")
        table.insert(lines, "════════════════════════")
        current_line = current_line + 2
        
        for _, item in ipairs(beginner_patterns) do
            local stars = string.rep("⭐", item.pattern.difficulty)
            local pattern_id = item.name:match("^%d+")
            local line_idx = #lines + 1
            
            table.insert(lines, string.format("  %s [%s] %s", 
                stars, 
                pattern_id or "?", 
                item.pattern.name))
                
            pattern_map[current_line] = item.name
            current_line = current_line + 1
            
            table.insert(lines, string.format("     └─ %s", item.pattern.description))
            current_line = current_line + 1
            
            -- Add practice stats if available
            local stats = require('scales.stats').practice_log.patterns_practiced[item.name]
            if stats and stats > 0 then
                table.insert(lines, string.format("     └─ 📊 Practiced %d times", stats))
                current_line = current_line + 1
            end
            
            table.insert(lines, "")
            current_line = current_line + 1
        end
    end
    
    -- Add intermediate patterns
    if #intermediate_patterns > 0 then
        table.insert(lines, "🌿 INTERMEDIATE PATTERNS 🌿")
        table.insert(lines, "═════════════════════════════")
        current_line = current_line + 2
        
        for _, item in ipairs(intermediate_patterns) do
            local stars = string.rep("⭐", item.pattern.difficulty)
            local pattern_id = item.name:match("^%d+")
            
            table.insert(lines, string.format("  %s [%s] %s", 
                stars, 
                pattern_id or "?", 
                item.pattern.name))
                
            pattern_map[current_line] = item.name
            current_line = current_line + 1
            
            table.insert(lines, string.format("     └─ %s", item.pattern.description))
            current_line = current_line + 1
            
            -- Add practice stats if available
            local stats = require('scales.stats').practice_log.patterns_practiced[item.name]
            if stats and stats > 0 then
                table.insert(lines, string.format("     └─ 📊 Practiced %d times", stats))
                current_line = current_line + 1
            end
            
            table.insert(lines, "")
            current_line = current_line + 1
        end
    end
    
    -- Add advanced patterns
    if #advanced_patterns > 0 then
        table.insert(lines, "🌳 ADVANCED PATTERNS 🌳")
        table.insert(lines, "════════════════════════")
        current_line = current_line + 2
        
        for _, item in ipairs(advanced_patterns) do
            local stars = string.rep("⭐", item.pattern.difficulty)
            local pattern_id = item.name:match("^%d+")
            
            table.insert(lines, string.format("  %s [%s] %s", 
                stars, 
                pattern_id or "?", 
                item.pattern.name))
                
            pattern_map[current_line] = item.name
            current_line = current_line + 1
            
            table.insert(lines, string.format("     └─ %s", item.pattern.description))
            current_line = current_line + 1
            
            -- Add practice stats if available
            local stats = require('scales.stats').practice_log.patterns_practiced[item.name]
            if stats and stats > 0 then
                table.insert(lines, string.format("     └─ 📊 Practiced %d times", stats))
                current_line = current_line + 1
            end
            
            table.insert(lines, "")
            current_line = current_line + 1
        end
    end
    
    -- Add footer
    table.insert(lines, "╭────────────────────────────────────────────────────────────╮")
    table.insert(lines, "│ 📝 USAGE: Press Enter on a pattern to start practicing     │")
    table.insert(lines, "│  • Or use :ScalesGenerate [pattern]                        │")
    table.insert(lines, "╰────────────────────────────────────────────────────────────╯")
    
    -- Set the buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Apply syntax highlighting
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
    
    -- Create a window with border
    local width = 70
    local height = math.min(#lines, vim.o.lines - 4)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    })
    
    -- Set window options
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:NormalFloat')
    
    -- Add highlights for different sections
    vim.api.nvim_buf_add_highlight(buf, -1, 'Title', 1, 13, 40)  -- Header
    
    -- Add highlights for pattern categories
    for i, line in ipairs(lines) do
        if line:match("^🌱 BEGINNER") then
            vim.api.nvim_buf_add_highlight(buf, -1, 'Question', i-1, 0, -1)
        elseif line:match("^🌿 INTERMEDIATE") then
            vim.api.nvim_buf_add_highlight(buf, -1, 'MoreMsg', i-1, 0, -1)
        elseif line:match("^🌳 ADVANCED") then
            vim.api.nvim_buf_add_highlight(buf, -1, 'ErrorMsg', i-1, 0, -1) 
        elseif line:match("^═+$") then
            vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', i-1, 0, -1)
        elseif line:match("^%s+└─%s+") then
            vim.api.nvim_buf_add_highlight(buf, -1, 'String', i-1, 0, -1)
        elseif line:match("📊 Practiced") then
            vim.api.nvim_buf_add_highlight(buf, -1, 'Number', i-1, 0, -1)
        elseif line:match("^%s+⭐") then
            vim.api.nvim_buf_add_highlight(buf, -1, 'Function', i-1, 0, -1)
            if line:match("%[%d+%]") then
                local start_idx, end_idx = line:find("%[%d+%]")
                vim.api.nvim_buf_add_highlight(buf, -1, 'LineNr', i-1, start_idx-1, end_idx)
            end
        elseif line:match("^╭") or line:match("^╰") or line:match("^│") then
            vim.api.nvim_buf_add_highlight(buf, -1, 'SpecialComment', i-1, 0, -1)
        end
    end
    
    -- Keymaps for pattern selection
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
        noremap = true,
        silent = true,
        callback = function()
            local cursor_pos = vim.api.nvim_win_get_cursor(win)
            local line_nr = cursor_pos[1] - 1  -- 0-based line number
            
            local pattern_name = pattern_map[line_nr]
            if pattern_name then
                vim.api.nvim_win_close(win, true)
                vim.cmd('redraw')
                vim.api.nvim_echo({{"Selected pattern: " .. pattern_name, "Normal"}}, false, {})
                
                -- Check if current buffer has unsaved changes
                if vim.bo.modified then
                    vim.cmd('write')
                end
                
                M.generate_practice(pattern_name)
            end
        end
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        noremap = true,
        silent = true,
        callback = function()
            -- Force close the window regardless of buffer state
            pcall(vim.api.nvim_win_close, win, true)
        end
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
        noremap = true,
        silent = true,
        callback = function()
            -- Force close the window regardless of buffer state
            pcall(vim.api.nvim_win_close, win, true)
        end
    })
    
    -- Return so buffer is not immediately closed
    return {
        buf = buf,
        win = win,
        pattern_map = pattern_map
    }
end

-- Peek at the template
function M.peek_template()
    local current_file = vim.fn.expand('%:p')
    local pattern_dir = vim.fn.fnamemodify(current_file, ':h')
    local template_file = pattern_dir .. "/template.py"
    
    if vim.fn.filereadable(template_file) == 0 then
        vim.api.nvim_err_write("Template file not found\n")
        return
    end
    
    -- Read template content
    local template_content = vim.fn.readfile(template_file)
    
    -- Create floating window
    local width = 60
    local height = 20
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
    })
    
    -- Set buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, template_content)
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'filetype', 'python')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    -- Add keymap to close window
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', {noremap = true, silent = true})
    
    -- Set window options
    vim.api.nvim_win_set_option(win, 'winhl', 'Normal:NormalFloat')
end

-- Add about information to pattern data structure
local function load_pattern_about(pattern_name)
    local about_file = M.config.templates_dir .. '/' .. pattern_name .. '/about.md'
    if vim.fn.filereadable(about_file) == 1 then
        return vim.fn.readfile(about_file)
    end
    return {
        "No about information available for this pattern.",
        "Consider adding an about.md file in the pattern's template directory."
    }
end

-- Show pattern information
function M.show_about(pattern_name)
    local pattern = M.patterns[pattern_name]
    if not pattern then
        vim.notify("Pattern not found: " .. pattern_name, vim.log.levels.ERROR)
        return
    end
    
    local about_content = load_pattern_about(pattern_name)
    local ui = require('scales.ui')
    
    local content = {
        "╭────────────────────────────────────────────╮",
        "│            🎸 PATTERN OVERVIEW 🎸           │",
        "╰────────────────────────────────────────────╯",
        "",
        string.format("Pattern: %s", pattern.name),
        string.format("Difficulty: %s", string.rep("⭐", pattern.difficulty)),
        "",
        "Description:",
        "════════════════════════",
        pattern.description,
        "",
        "About:",
        "════════════════════════"
    }
    
    -- Add about content
    for _, line in ipairs(about_content) do
        table.insert(content, line)
    end
    
    -- Add usage instructions
    table.insert(content, "")
    table.insert(content, "Usage:")
    table.insert(content, "════════════════════════")
    table.insert(content, "1. Press \\sp to peek at the template")
    table.insert(content, "2. Implement the pattern from scratch")
    table.insert(content, "3. Press \\sv to validate your implementation")
    table.insert(content, "4. Press \\sr to reset and try again")
    
    ui.show_popup(content, {
        title = "Pattern Information",
        border = "rounded"
    })
end

return M 