# 🎸 Scales.nvim

> 🎵 *"You want to be like this in your next interview? Start with the basics."*

[![Eruption - Eddie Van Halen](https://img.youtube.com/vi/L9r-NxuYszg/0.jpg)](https://www.youtube.com/watch?v=L9r-NxuYszg&t=152)

Practice coding patterns like a musician practices scales. Just as guitarists master scales to build muscle memory and improvisation skills, this Neovim plugin helps you master common coding patterns through deliberate practice.

## 🚀 Quick Start

1. **Install the plugin** (see Installation section below)
2. **Start practicing**:
   ```vim
   :ScalesList    " Browse available patterns
   :ScalesGenerate " Start a new practice
   :ScalesPeek    " View the solution if stuck
   :ScalesValidate " Check your implementation
   :ScalesReset   " Start over with the same pattern
   ```

## 🎯 Key Features

### Essential Commands
| Command | Key | Description |
|---------|-----|-------------|
| `:ScalesList` | `\sl` | Browse available patterns |
| `:ScalesGenerate` | `\sg` | Start a new practice |
| `:ScalesPeek` | `\sp` | View the solution if stuck |
| `:ScalesValidate` | `\sv` | Check your implementation |
| `:ScalesReset` | `\sr` | Start over with the same pattern |
| `:ScalesAbout` | `\sa` | Learn about the current pattern |
| `:ScalesStats` | `\ss` | Track your progress |

### Practice Workflow
1. **Choose a pattern**:
   - Press `\sl` to browse patterns
   - Or use `:ScalesGenerate pattern_name` for a specific pattern

2. **Practice**:
   - Write your implementation
   - Press `\sp` to peek at the solution if stuck
   - Press `\sv` to validate your code
   - Press `\sr` to reset and try again

3. **Learn**:
   - Press `\sa` to learn about the current pattern
   - Press `\ss` to track your progress
   - Earn achievements as you improve

## 🎸 Why Scales.nvim?

### The Missing Step in Interview Prep
Most developers struggle with technical interviews because they're missing a crucial step: mastering the fundamental patterns. It's like trying to play complex songs without learning scales first.

### 🤔 Why Traditional Prep Falls Short
- **Problem-First Approach**: Jumping straight into solving problems without mastering patterns
- **Quantity Over Quality**: Focusing on number of problems solved rather than pattern mastery
- **Memorization Over Understanding**: Learning solutions instead of building problem-solving reflexes
- **Lack of Structure**: No clear progression from basics to advanced concepts

### 🎸 How Scales.nvim Changes That
- **Pattern-First Learning**: Master fundamental patterns before tackling complex problems
- **Deliberate Practice**: Build muscle memory through focused repetition
- **Progressive Difficulty**: Start simple and gradually increase complexity
- **Measurable Progress**: Track your improvement and build confidence
- **Integrated Workflow**: Practice in your familiar development environment

### 🎯 Why Neovim?
- **Lightning Fast Practice**
  - Open terminal and start practicing instantly
  - No website loading or setup time
  - Maximum reps in minimum time
- **Keyboard-First Workflow**
  - Execute commands at high speed
  - Focus on coding, not clicking
  - Build muscle memory for both patterns and editing
- **Always Available**
  - Practice anywhere with terminal access
  - No internet required for core features
  - Consistent experience across environments
- **100% Free & Open Source**
  - No subscription fees
  - No premium features
  - Community-driven development

## 📦 Installation

### Prerequisites
- [Neovim](https://neovim.io/) (version 0.8.0 or higher)
- A package manager for Neovim (we recommend [packer.nvim](https://github.com/wbthomason/packer.nvim))

### Installation Steps
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
Add this to your `init.lua`:
```lua
require('scales').setup()
```

### Advanced Configuration
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
})
```

## 🎸 Available Patterns

### Beginner Patterns (⭐)
- Binary Search
- Two Pointers (Same Direction)
- Two Pointers (Opposite Direction)

### Intermediate Patterns (⭐⭐)
- Sliding Window (Fixed Size)
- Sliding Window (Flexible Longest)
- Sliding Window (Flexible Shortest)
- Prefix Sum

### Advanced Patterns (⭐⭐⭐)
- DFS on Tree
- BFS on Tree
- DFS on Graph
- BFS on Graph
- BFS on Matrix
- Backtracking (Basic)
- Backtracking (Aggregation)
- Topological Sort
- Union Find
- Trie
- Monotonic Stack
- DP (Top Down)
- DP (Bottom Up)

## 🏆 Achievements

Earn badges and achievements as you practice:
- **Pattern Mastery**: Master of [Pattern], Advanced in [Pattern], etc.
- **Timing Achievements**: Speed Demon, Fast Learner, Consistent Performer
- **Global Achievements**: Centurion, Halfway There, Pattern Scholar

## 🔮 Future Features

### Pattern Recognition Quiz
- `:ScalesQuiz` command to test pattern identification
- Uses HackerRank API to fetch real interview problems
  - Problems filtered by difficulty and pattern
  - Randomized selection to prevent memorization
  - Time-limited challenges
- Track accuracy and provide hints
  - Pattern-specific hints
  - Common mistake detection
  - Progress tracking per pattern
- Build pattern recognition skills
  - Difficulty progression
  - Pattern-specific achievements
  - Performance analytics

### Template Manipulation Quiz
- Exercises for modifying templates to solve problems
- Uses HackerRank API for validation
  - Real problem constraints
  - Comprehensive test cases
  - Time/space complexity checks
- Track and provide feedback on modifications
  - Modification history
  - Success rate tracking
  - Common optimization paths
- Learn pattern variations and applications
  - Multiple solution approaches
  - Optimization techniques
  - Edge case handling

### New Pattern Templates
- Line Sweep algorithm
- Segment Trees
- More advanced competitive programming patterns
  - Heavy-Light Decomposition
  - Sparse Tables
  - Fenwick Trees

### Custom Pattern Support
- Add your own patterns and templates
  - Local pattern creation
  - Custom validation rules
  - Personal practice problems
- Share patterns with the community
  - Pattern marketplace for sharing templates
  - Rate and review community patterns
  - Search and filter patterns by difficulty/tags
  - Import patterns directly from GitHub

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Add new patterns
- Improve existing templates
- Add more test coverage
- Suggest new features

## 📝 License

MIT License - See LICENSE file for details
