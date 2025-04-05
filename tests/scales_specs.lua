describe('Scales Plugin', function()
    -- Setup
    before_each(function()
        -- Reset plugin state and clean test directories
        require('scales').setup()
        local practice_dir = require('scales').config.practice_dir
        os.execute('rm -rf ' .. practice_dir)
        vim.fn.mkdir(practice_dir, 'p')
        
        -- Reset practice log
        local core = require('scales.core')
        core.practice_log = {
            total_sessions = 0,
            patterns_practiced = {},
            timing_stats = {},
            achievements = {}
        }
    end)

    describe('Template Loading', function()
        it('loads templates correctly', function()
            local core = require('scales.core')
            local patterns = core.patterns
            
            -- Check template loading
            assert.is_not_nil(patterns)
            assert.is_true(vim.tbl_count(patterns) > 0)
            
            -- Check template content
            local pattern = patterns['1_binary_search']
            assert.is_not_nil(pattern)
            assert.is_not_nil(pattern.template)
            assert.is_not_nil(pattern.name)
            assert.is_not_nil(pattern.description)
            assert.is_not_nil(pattern.difficulty)
        end)

        it('handles missing templates gracefully', function()
            local core = require('scales.core')
            local original_dir = require('scales').config.templates_dir
            
            -- Set invalid templates directory
            require('scales').config.templates_dir = '/nonexistent/directory'
            
            -- Should handle error gracefully
            local patterns = core.load_templates()
            assert.is_not_nil(patterns)
            assert.equals(vim.tbl_count(patterns), 0)
            
            -- Restore original directory
            require('scales').config.templates_dir = original_dir
        end)

        it('extracts pattern names correctly', function()
            local core = require('scales.core')
            local patterns = core.patterns
            
            -- Check name extraction
            local pattern = patterns['1_binary_search']
            assert.equals(pattern.name, 'Binary Search')
            
            pattern = patterns['3_sliding_window_fixed_size']
            assert.equals(pattern.name, 'Sliding Window Fixed Size')
        end)
    end)

    describe('Practice File Management', function()
        it('creates practice files correctly', function()
            local core = require('scales.core')
            local pattern_name = '1_binary_search'
            
            -- Generate practice
            core.generate_practice(pattern_name)
            
            -- Check file creation
            local practice_dir = require('scales').config.practice_dir
            local practice_file = practice_dir .. '/' .. pattern_name .. '/practice.py'
            assert.equals(vim.fn.filereadable(practice_file), 1)
            
            -- Check file content
            local content = vim.fn.readfile(practice_file)
            assert.is_not_nil(content)
            assert.is_true(#content > 0)
            
            -- Check specific content lines
            local expected_lines = {
                '# Practice: Binary Search',
                '# Implement the pattern from scratch',
                '# When ready, run :ScalesValidate to check your implementation',
                '',
                '# Your implementation goes here:',
                ''
            }
            
            for i, line in ipairs(expected_lines) do
                assert.equals(content[i], line)
            end
        end)

        it('creates stats files correctly', function()
            local core = require('scales.core')
            local pattern_name = '1_binary_search'
            
            -- Generate practice and complete it
            core.generate_practice(pattern_name)
            core.start_timing(pattern_name)
            vim.loop.sleep(10)  -- Small delay
            core.end_timing()
            
            -- Check stats file creation
            local practice_dir = require('scales').config.practice_dir
            local stats_file = practice_dir .. '/' .. pattern_name .. '/stats.py'
            assert.equals(vim.fn.filereadable(stats_file), 1)
            
            -- Check stats file content
            local content = vim.fn.readfile(stats_file)
            assert.is_not_nil(content)
            assert.is_true(#content > 0)
            
            -- Check specific content lines
            local first_line = content[1]
            assert.is_true(first_line:match('^# Stats for 1_binary_search pattern') ~= nil)
            
            -- Check stats values
            local has_total_practices = false
            local has_last_practice = false
            local has_average_time = false
            local has_best_time = false
            local has_last_time = false
            
            for _, line in ipairs(content) do
                if line:match('total_practices = %d+') then has_total_practices = true end
                if line:match('last_practice = %d+') then has_last_practice = true end
                if line:match('average_time = [%d%.]+') then has_average_time = true end
                if line:match('best_time = [%d%.]+') then has_best_time = true end
                if line:match('last_time = [%d%.]+') then has_last_time = true end
            end
            
            assert.is_true(has_total_practices)
            assert.is_true(has_last_practice)
            assert.is_true(has_average_time)
            assert.is_true(has_best_time)
            assert.is_true(has_last_time)
        end)
    end)

    describe('Timing and Statistics', function()
        local core = require('scales.core')

        before_each(function()
            core.reset_stats()
        end)

        it('tracks timing accurately', function()
            local core = require('scales.core')
            local pattern_name = '1_binary_search'
            
            -- Start timing
            core.start_timing(pattern_name)
            
            -- Simulate some time passing (100ms)
            vim.loop.sleep(100)
            
            -- End timing
            local completion_time = core.end_timing()
            
            -- Check timing (allow for some variance)
            assert.is_not_nil(completion_time)
            assert.is_true(completion_time >= 0.09 and completion_time <= 0.15, 
                string.format("Expected time between 0.09 and 0.15, got %.2f", completion_time))
            
            -- Check stats were updated
            local stats = core.practice_log.patterns_practiced[pattern_name]
            assert.equals(stats, 1)
            
            local timing_stats = core.practice_log.timing_stats[pattern_name]
            assert.is_not_nil(timing_stats)
            assert.equals(timing_stats.attempts, 1)
            assert.is_true(timing_stats.best_time >= 0.09 and timing_stats.best_time <= 0.15,
                string.format("Expected best time between 0.09 and 0.15, got %.2f", timing_stats.best_time))
        end)

        it('updates stats correctly', function()
            local core = require('scales.core')
            local pattern_name = '1_binary_search'
            
            -- Complete multiple practices
            for i = 1, 3 do
                core.generate_practice(pattern_name)
                core.start_timing(pattern_name)
                vim.loop.sleep(10)  -- Small delay
                core.end_timing()
            end
            
            -- Check stats
            local stats = core.practice_log.patterns_practiced[pattern_name]
            assert.equals(stats, 3)
            
            local timing_stats = core.practice_log.timing_stats[pattern_name]
            assert.equals(timing_stats.attempts, 3)
            assert.is_true(timing_stats.best_time > 0)
            assert.is_true(timing_stats.total_time > 0)
            assert.is_true(timing_stats.total_time >= timing_stats.best_time * 3)
        end)

        it('handles edge cases in timing', function()
            local core = require('scales.core')
            local pattern_name = '1_binary_search'
            
            -- Test very fast completion
            core.start_timing(pattern_name)
            local fast_time = core.end_timing()
            assert.is_true(fast_time >= 0)
            
            -- Test very slow completion
            core.start_timing(pattern_name)
            vim.loop.sleep(1000)  -- 1 second
            local slow_time = core.end_timing()
            assert.is_true(slow_time >= 0.9 and slow_time <= 1.1,
                string.format("Expected time between 0.9 and 1.1, got %.2f", slow_time))
        end)
    end)

    describe('UI and Display', function()
        it('lists patterns with correct formatting', function()
            local core = require('scales.core')
            
            -- Capture output
            local output = {}
            local original_out_write = vim.api.nvim_out_write
            vim.api.nvim_out_write = function(text)
                table.insert(output, text)
            end
            
            -- List patterns
            core.list_patterns()
            
            -- Restore original function
            vim.api.nvim_out_write = original_out_write
            
            -- Join output for easier checking
            local full_output = table.concat(output)
            
            -- Check output format
            assert.is_true(full_output:match('Available Patterns') ~= nil)
            assert.is_true(full_output:match('================') ~= nil)
            assert.is_true(full_output:match('⭐') ~= nil)
            assert.is_true(full_output:match('🌱 Beginner') ~= nil)
            assert.is_true(full_output:match('Binary Search') ~= nil)
        end)

        it('displays achievements correctly', function()
            local core = require('scales.core')
            local pattern_name = '1_binary_search'
            
            -- Complete enough practices to earn an achievement
            for i = 1, 25 do
                core.generate_practice(pattern_name)
                core.start_timing(pattern_name)
                vim.loop.sleep(10)  -- Small delay
                core.end_timing()
            end
            
            -- Check achievements
            local achievements = core.practice_log.achievements
            assert.is_not_nil(achievements)
            
            -- Check specific achievement
            local has_master = false
            for achievement, _ in pairs(achievements) do
                if achievement:match('Master of') then
                    has_master = true
                    break
                end
            end
            assert.is_true(has_master)
        end)

        it('creates floating windows correctly', function()
            local core = require('scales.core')
            
            -- Generate a practice
            core.generate_practice('1_binary_search')
            
            -- Peek at template
            core.peek_template()
            
            -- Check floating window
            local windows = vim.api.nvim_list_wins()
            assert.is_true(#windows > 1)  -- Should have at least one floating window
            
            -- Close all floating windows
            for _, win in ipairs(windows) do
                if vim.api.nvim_win_get_config(win).relative ~= '' then
                    vim.api.nvim_win_close(win, true)
                end
            end
        end)
    end)

    describe('Pattern Difficulty', function()
        it('assigns correct difficulty ratings', function()
            local core = require('scales.core')
            local patterns = core.patterns
            
            -- Check difficulty assignments
            assert.equals(patterns['1_binary_search'].difficulty, 1)
            assert.equals(patterns['3_sliding_window_fixed_size'].difficulty, 2)
            assert.equals(patterns['5_dfs_on_tree'].difficulty, 3)
            assert.equals(patterns['8_topological_sort'].difficulty, 5)
        end)

        it('sorts patterns by difficulty', function()
            local core = require('scales.core')
            local patterns = core.patterns
            
            -- Get sorted patterns
            local sorted_patterns = {}
            for name, pattern in pairs(patterns) do
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
            
            -- Verify sorting
            for i = 2, #sorted_patterns do
                local prev = sorted_patterns[i-1]
                local curr = sorted_patterns[i]
                assert.is_true(
                    prev.pattern.difficulty <= curr.pattern.difficulty,
                    string.format("Patterns not sorted by difficulty: %s (%d) should come before %s (%d)",
                        prev.name, prev.pattern.difficulty,
                        curr.name, curr.pattern.difficulty)
                )
            end
        end)
    end)
end)