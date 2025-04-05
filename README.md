# Scales.nvim

Practice coding patterns like a musician practices scales. This Neovim plugin helps you master common coding patterns through deliberate practice.

![Scales.nvim Overview](docs/scales_overview.png)
*Scales.nvim in action: Pattern selection (top-left), Practice implementation (top-right), Validation feedback (bottom)*

## ✨ Features

- Practice common coding patterns (sliding window, two pointers, etc.)
- Track your practice progress and timing
- Validate your implementations against templates
- View detailed practice statistics
- Earn achievements and badges
- Difficulty-based pattern selection
- Customizable templates and configurations

## 📦 Installation

### Prerequisites
- [Neovim](https://neovim.io/) (version 0.8.0 or higher)
- A package manager for Neovim (we recommend [packer.nvim](https://github.com/wbthomason/packer.nvim))

### Step-by-Step Installation

1. **Install Neovim** if you haven't already:
   ```bash
   # For macOS
   brew install neovim
   
   # For Ubuntu/Debian
   sudo apt install neovim
   
   # For Windows (using Chocolatey)
   choco install neovim
   ```

2. **Install a package manager** (if you don't have one):
   ```lua
   -- Add this to your init.lua (usually at ~/.config/nvim/init.lua)
   local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
   if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
     vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
   end
   ```

3. **Install Scales.nvim**:
   ```lua
   -- Add this to your init.lua
   use {
       'cjohnson74/scales.nvim',
       requires = { 'nvim-lua/plenary.nvim' },
       config = function()
           require('scales').setup()
       end
   }
   ```

4. **Sync your plugins**:
   ```vim
   :PackerSync
   ```

## ⚙️ Configuration

### Basic Setup
Add this to your `init.lua` (usually at `~/.config/nvim/init.lua`):
```lua
require('scales').setup()
```

### Advanced Configuration
You can customize the plugin with these options:
```lua
require('scales').setup({
    -- Directory to store your practice files
    practice_dir = vim.fn.stdpath('data') .. '/scales',
    
    -- Optional: Custom templates directory
    templates_dir = nil,  -- Defaults to plugin directory/templates
    
    -- UI settings
    float_border = 'rounded',  -- Border style for popup windows
    float_width = 60,          -- Width of popup windows
    float_height = 20,         -- Height of popup windows
    
    -- Key mappings (explained below)
    mappings = {
        generate = '<leader>sg',  -- Generate new practice
        open = '<leader>so',      -- Open practice file
        validate = '<leader>sv',  -- Validate your code
        list = '<leader>sl',      -- List patterns
        stats = '<leader>ss',     -- Show statistics
        peek = '<leader>sp',      -- Peek at solution
        next = '<leader>sn'       -- Next practice
    }
})
```

## 🎹 Usage

### Understanding Key Mappings
- `<leader>` is a special key in Neovim (default is `\`)
- For example, `<leader>sg` means press `\` then `s` then `g`
- You can change your leader key in your `init.lua`:
  ```lua
  vim.g.mapleader = ','  -- Change leader to comma
  ```

### Commands
You can use these commands in Neovim's command mode (press `:` to enter command mode):

- `:ScalesGenerate [pattern]` - Create a new practice file
- `:ScalesOpen` - Open your most recent practice
- `:ScalesList` - Show all available patterns
- `:ScalesStats` - View your practice statistics
- `:ScalesValidate` - Check your implementation
- `:ScalesPeek` - Look at the solution
- `:ScalesNext` - Start next practice
- `:ScalesReload` - Reload templates
- `:ScalesSetup` - Re-run plugin setup

### Quick Start Guide

1. **Start Neovim**:
   ```bash
   nvim
   ```

2. **Generate your first practice**:
   ```vim
   :ScalesGenerate
   ```
   This creates a new Python file with instructions

   ![Pattern Selection](docs/pattern-selection.png)
   *Browse available patterns with difficulty indicators*

3. **Write your code** in the practice file

   ![Practice Interface](docs/practice.png)
   *The practice interface with instructions and code area*

4. **Validate your code**:
   ```vim
   :ScalesValidate
   ```
   You'll see feedback on your implementation

   ![Validation Success](docs/validation-success.png)
   *Celebrate your success with detailed feedback*

### Practice Workflow

1. **Choose a pattern**:
   - Press `\sl` to see available patterns
   - Or use `:ScalesGenerate pattern_name` for a specific pattern
   - Or just `:ScalesGenerate` for a random pattern

2. **Practice**:
   - Write your implementation
   - Press `\sp` to peek at the solution if stuck
   - Press `\sv` to validate your code

3. **Track Progress**:
   - Press `\ss` to see your statistics
   - Earn achievements as you improve
   - Track your timing improvements

   ![Statistics View](docs/statistics.png)
   *Track your progress and achievements*

### Pattern Difficulty Levels

![Pattern Selection Interface](docs/pattern_selection.gif)
*Pattern selection interface showing difficulty levels with star ratings:*

- 🌱 **Beginner Patterns** (1-2 stars)
  - [1] Binary Search
    - Practice binary search technique
  - [2] Two Pointers Opposite Directions
    - Practice two pointers opposite directions technique
  - [2] Two Pointers Same Directions
    - Practice two pointers same directions technique

- 🌿 **Intermediate Patterns** (3-4 stars)
  - [3] Sliding Window Fixed Size
    - Practice sliding window fixed size technique
  - [3] Sliding Window Flexible Longest
    - Practice sliding window flexible longest technique
  - [3] Sliding Window Flexible Shortest
    - Practice sliding window flexible shortest technique
  - [4] Prefix Sum
    - Practice prefix sum technique
  - [5] DFS on Tree
    - Practice depth-first search on tree technique
  - [6] Backtracking
    - Practice backtracking technique
  - [7] BFS on Tree
    - Practice breadth-first search on tree technique

- 🌳 **Advanced Patterns** (5 stars)
  - [8] Topological Sort
    - Practice topological sort technique
  - [90] DP Top Down
    - Practice dp top down technique
  - [90] Union Find
    - Practice union find technique
  - [91] Trie
    - Practice trie technique
  - [92] Monotonic Stack
    - Practice monotonic stack technique

Each pattern includes:
- Visual difficulty indicator (⭐)
- Pattern ID (in brackets) for easy reference
- Clear description of the technique
- Practice instructions
- Template implementation for validation

## 🏆 Achievements

Earn badges and achievements as you practice:

- **Pattern Mastery**
  - 🏆 Master of [Pattern] - 25 practices
  - ⭐ Advanced in [Pattern] - 20 practices
  - 🎯 Intermediate in [Pattern] - 15 practices

- **Timing Achievements**
  - ⚡ Speed Demon - Fast completion
  - 🏃 Fast Learner - Quick learning
  - 🎯 Consistent Performer - Consistent timing

- **Global Achievements**
  - 🌟 Centurion - 100 total practices
  - 📚 Halfway There - 50 total practices
  - 🎓 Pattern Scholar - Master 10 patterns
  - 📖 Pattern Explorer - Master 5 patterns

## 📁 Directory Structure

The plugin creates these directories automatically:

```
~/.local/share/nvim/scales/  # Your practice files
└── <pattern_name>/
    ├── practice.py  # Your code
    └── stats.py     # Your progress
```

Templates are stored here:
```
~/.local/share/nvim/site/pack/packer/start/Scales.nvim/templates/
└── <pattern_name>/
    └── template.py  # Solution template
```

## 🚀 Tips for Success

1. **Start with easier patterns** and gradually increase difficulty
2. **Focus on understanding** the pattern before optimizing speed
3. **Practice regularly** to build muscle memory
4. **Review your mistakes** when validation fails
5. **Track your progress** using the statistics feature
6. **Aim for consistency** before speed

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Add new patterns
- Improve existing templates
- Add more test coverage
- Suggest new features

## 📝 License

MIT License - See LICENSE file for details
