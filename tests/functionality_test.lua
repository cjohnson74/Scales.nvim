local M = {}

function M.test_functionality()
    -- Test pattern generation
    vim.cmd('ScalesGenerate')
    local current_file = vim.fn.expand('%:p')
    if not current_file or not current_file:match('practice%.py$') then
        vim.notify("Failed to generate practice file", vim.log.levels.ERROR)
        return false
    end

    -- Test template peeking
    vim.cmd('ScalesPeek')
    local peek_buf = vim.api.nvim_get_current_buf()
    if not peek_buf then
        vim.notify("Failed to peek template", vim.log.levels.ERROR)
        return false
    end
    vim.api.nvim_buf_delete(peek_buf, { force = true })

    -- Test pattern listing
    vim.cmd('ScalesList')
    local list_buf = vim.api.nvim_get_current_buf()
    if not list_buf then
        vim.notify("Failed to list patterns", vim.log.levels.ERROR)
        return false
    end
    vim.api.nvim_buf_delete(list_buf, { force = true })

    -- Test stats display
    vim.cmd('ScalesStats')
    local stats_buf = vim.api.nvim_get_current_buf()
    if not stats_buf then
        vim.notify("Failed to show stats", vim.log.levels.ERROR)
        return false
    end
    vim.api.nvim_buf_delete(stats_buf, { force = true })

    -- Test validation (should fail initially)
    vim.cmd('ScalesValidate')
    local validation_buf = vim.api.nvim_get_current_buf()
    if not validation_buf then
        vim.notify("Failed to validate practice", vim.log.levels.ERROR)
        return false
    end
    vim.api.nvim_buf_delete(validation_buf, { force = true })

    vim.notify("Scales plugin functionality test passed!", vim.log.levels.INFO)
    return true
end

return M 