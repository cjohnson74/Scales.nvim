local M = {}

function M.test_installation()
    -- Test if plugin is loaded
    if not vim.g.loaded_scales then
        vim.notify("Scales plugin not loaded", vim.log.levels.ERROR)
        return false
    end

    -- Test if commands are registered
    local commands = {
        'ScalesGenerate',
        'ScalesOpen',
        'ScalesValidate',
        'ScalesList',
        'ScalesStats',
        'ScalesPeek',
        'ScalesNext',
        'ScalesReload',
        'ScalesSetup'
    }

    for _, cmd in ipairs(commands) do
        if not vim.fn.exists(':' .. cmd) then
            vim.notify("Command not found: " .. cmd, vim.log.levels.ERROR)
            return false
        end
    end

    -- Test if keymaps are set
    local keymaps = {
        '<leader>sg',  -- Generate
        '<leader>so',  -- Open practice
        '<leader>sv',  -- Validate
        '<leader>sl',  -- List
        '<leader>ss',  -- Stats
        '<leader>sp',  -- Peek
        '<leader>sn'   -- Next
    }

    for _, keymap in ipairs(keymaps) do
        local mapping = vim.fn.maparg(keymap, 'n')
        if mapping == '' then
            vim.notify("Keymap not found: " .. keymap, vim.log.levels.ERROR)
            return false
        end
    end

    -- Test if directories are created
    local required_dirs = {
        vim.fn.stdpath('data') .. '/scales',
        vim.fn.stdpath('data') .. '/scales/templates'
    }

    for _, dir in ipairs(required_dirs) do
        if vim.fn.isdirectory(dir) == 0 then
            vim.notify("Directory not found: " .. dir, vim.log.levels.ERROR)
            return false
        end
    end

    vim.notify("Scales plugin installation test passed!", vim.log.levels.INFO)
    return true
end

return M 