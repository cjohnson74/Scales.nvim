-- Configuration for luacheck
-- See https://github.com/mpeterv/luacheck#config-file-format

-- Global settings
std = "lua54"  -- Use Lua 5.4 standard library
max_line_length = 100
ignore = {
    "211",  -- Unused variable
    "212",  -- Unused argument
    "213",  -- Unused loop variable
    "611",  -- Line contains only whitespace
    "612",  -- Line contains trailing whitespace
    "613",  -- Line ends with a semicolon
    "614",  -- Line contains a tab
    "621",  -- Inconsistent indentation
    "631",  -- Line is too long
}

-- Module-specific settings
read_globals = {
    -- Neovim globals
    "vim",
    "nvim",
    -- Plugin-specific globals
    "scales",
}

-- File-specific settings
files = {
    ["lua/**/*.lua"] = {
        std = "lua54",
        globals = {
            -- Add any file-specific globals here
        }
    },
    ["tests/**/*.lua"] = {
        std = "lua54",
        globals = {
            "describe",
            "it",
            "before_each",
            "after_each",
            "assert",
        }
    }
} 