# 🎸 Scales.nvim

> 🎵 *"You want to be like this in your next interview? Start with the basics."*

[![Eruption - Eddie Van Halen](https://img.youtube.com/vi/L9r-NxuYszg/0.jpg)](https://www.youtube.com/watch?v=L9r-NxuYszg&t=152)

Practice coding patterns like a musician practices scales. Just as guitarists master scales to build muscle memory and improvisation skills, this Neovim plugin helps you master common coding patterns through deliberate practice.

## 🎯 The Missing Step in Interview Prep

Most developers struggle with technical interviews because they're missing a crucial step: mastering the fundamental patterns. It's like trying to play complex songs without learning scales first.

### 🤔 Why Traditional Prep Falls Short

- **Problem-First Approach**: Jumping straight into solving problems without mastering patterns (like trying to play solos without learning scales)
- **Quantity Over Quality**: Focusing on number of problems solved rather than pattern mastery (like playing many songs poorly instead of mastering a few)
- **Memorization Over Understanding**: Learning solutions instead of building problem-solving reflexes (like memorizing tabs instead of understanding music theory)
- **Lack of Structure**: No clear progression from basics to advanced concepts (like trying to play advanced techniques without proper foundation)

### 🎸 How Scales.nvim Changes That

- **Pattern-First Learning**: Master fundamental patterns before tackling complex problems (like learning scales before solos)
- **Deliberate Practice**: Build muscle memory through focused repetition (like practicing scales with a metronome)
- **Progressive Difficulty**: Start simple and gradually increase complexity (like learning basic scales before advanced techniques)
- **Measurable Progress**: Track your improvement and build confidence (like tracking your speed and accuracy)
- **Integrated Workflow**: Practice in your familiar development environment (like practicing in your favorite music room)

> 🎵 *"You wouldn't try to play ['Eruption'](https://youtu.be/L9r-NxuYszg?si=ZiNbsVDLcTxvqY40&t=307) without learning your scales first. Don't try to solve complex problems without mastering the basics."*

## ✨ Features

> 🎵 *"Building your foundation to rock any interview"*

- 🎯 **Pattern Mastery**
  - Practice common coding patterns (like practicing scales)
  - Build muscle memory for problem-solving (like building finger memory)
  - Understand pattern variations and applications (like learning scale modes)

- ⏱️ **Progress Tracking**
  - Track your practice time (like a metronome)
  - Monitor improvement over time (like tracking your speed)
  - Build confidence through measurable progress (like seeing your progress in practice)

- ✅ **Validation & Feedback**
  - Validate your implementations (like playing along with a backing track)
  - Get immediate feedback on your solutions (like having a teacher correct your technique)
  - Learn from mistakes and improve (like refining your playing)

- 📊 **Achievement System**
  - Earn badges and achievements (like earning music grades)
  - Track your mastery of different patterns (like mastering different scales)
  - Stay motivated through your journey (like working towards a performance)

- 🧱 **Structured Learning**
  - Difficulty-based pattern selection (like progressive exercises)
  - Clear progression path (like learning scales in order of difficulty)
  - Focus on fundamentals before complexity (like mastering basics before advanced techniques)

## 🎸 Scales vs. Solos

> 🎵 *"Master the scales, and the solos will follow"*

| Scales (Fundamentals) | Solos (Complex Problems) |
|----------------------|-------------------------|
| Binary Search | Find Peak Element |
| Two Pointers | Container With Most Water |
| Sliding Window | Longest Substring Without Repeating Characters |
| Prefix Sum | Subarray Sum Equals K |

*Each fundamental pattern (scale) builds the foundation for solving more complex problems (solos). Master the scales first, and the solos will become much easier to play!*

## 🎸 Understanding Scales: From Music to Code

### Musical Scales: The Building Blocks of Music
A musical scale is a sequence of notes that forms the foundation of melodies and solos. For example, the A minor pentatonic scale consists of just five notes: A, C, D, E, G. These simple notes become the building blocks for creating complex solos and songs.

Take Eddie Van Halen's "Eruption" - while it sounds incredibly complex, it's built on these fundamental scales. The fast runs, the tapping, the hammer-ons - they all follow patterns derived from scales. When you practice scales, you're not just learning notes; you're building the muscle memory and understanding needed to create music.

### Coding Templates: The Building Blocks of Algorithms
Just like musical scales, coding templates are fundamental patterns that form the building blocks of more complex algorithms. Here are some examples from our templates:

<details>
<summary>1. Binary Search Template</summary>

```python
def binary_search(arr: List[int], target: int) -> int:
    left, right = 0, len(arr) - 1
    first_true_index = -1
    while left <= right:
        mid = (left + right) // 2
        if feasible(mid):
            first_true_index = mid
            right = mid - 1
        else:
            left = mid + 1
    
    return first_true_index
```

**Example Problem: Find First Bad Version**
```python
def isBadVersion(version: int) -> bool:
    # API function provided by the system
    pass

def firstBadVersion(n: int) -> int:
    left, right = 1, n
    first_bad = n
    while left <= right:
        mid = (left + right) // 2
        if isBadVersion(mid):
            first_bad = mid
            right = mid - 1
        else:
            left = mid + 1
    return first_bad
```
</details>

<details>
<summary>2. Two Pointers (Same Direction) Template</summary>

```python
def two_pointers_same(arr):
    slow, fast = 0, 0
    while fast < len(arr):
        # Process current elements
        current = process(arr[slow], arr[fast])

        # Update pointers based on condition
        if condition(arr[slow], arr[fast]):
            slow += 1

        # Fast pointer always moves forward
        fast += 1
```

**Example Problem: Remove Duplicates from Sorted Array**
```python
def removeDuplicates(nums: List[int]) -> int:
    slow = 0
    for fast in range(len(nums)):
        if nums[fast] != nums[slow]:
            slow += 1
            nums[slow] = nums[fast]
    return slow + 1
```
</details>

<details>
<summary>3. Sliding Window (Fixed Size) Template</summary>

```python
def sliding_window_fixed(input, window_size):
    ans = window = input[0:window_size]
    for right in range(window_size, len(input)):
        left = right - window_size
        remove input[left] from window
        append input[right] to window
        ans = optimal(ans, window)
    return ans
```

**Example Problem: Maximum Average Subarray**
```python
def findMaxAverage(nums: List[int], k: int) -> float:
    window_sum = sum(nums[:k])
    max_sum = window_sum
    
    for right in range(k, len(nums)):
        left = right - k
        window_sum = window_sum - nums[left] + nums[right]
        max_sum = max(max_sum, window_sum)
    
    return max_sum / k
```
</details>

<details>
<summary>4. Prefix Sum Template</summary>

```python
def build_prefix_sum(arr):
    n = len(arr)
    prefix_sum = [0] * n
    prefix_sum[0] = arr[0]
    for i in range(1, n):
        prefix_sum[i] = prefix_sum[i-1] + arr[i]
    return prefix_sum

# Query sum of range [left, right] (inclusive)
def query_range(prefix_sum, left, right):
    if left == 0:
        return prefix_sum[right]
    return prefix_sum[right] - prefix_sum[left-1]
```

**Example Problem: Subarray Sum Equals K**
```python
def subarraySum(nums: List[int], k: int) -> int:
    prefix_sum = {0: 1}
    current_sum = 0
    count = 0
    
    for num in nums:
        current_sum += num
        if current_sum - k in prefix_sum:
            count += prefix_sum[current_sum - k]
        prefix_sum[current_sum] = prefix_sum.get(current_sum, 0) + 1
    
    return count
```
</details>

<details>
<summary>5. DFS on Tree Template</summary>

```python
def dfs(root, target):
    if root is None:
        return None
    if root.val == target:
        return root
    left = dfs(root.left, target)
    if left is not None:
        return left
    return dfs(root.right, target)
```

**Example Problem: Path Sum**
```python
def hasPathSum(root: TreeNode, targetSum: int) -> bool:
    if not root:
        return False
    if not root.left and not root.right:
        return targetSum == root.val
    return (hasPathSum(root.left, targetSum - root.val) or 
            hasPathSum(root.right, targetSum - root.val))
```
</details>

<details>
<summary>6. BFS on Tree Template</summary>

```python
def bfs(root):
    queue = deque([root])
    while len(queue) > 0:
        node = queue.popleft()
        for child in node.children:
            if is_goal(child):
                return FOUND(child)
            queue.append(child)
    return NOT_FOUND
```

**Example Problem: Binary Tree Level Order Traversal**
```python
def levelOrder(root: TreeNode) -> List[List[int]]:
    if not root:
        return []
    
    result = []
    queue = deque([root])
    
    while queue:
        level_size = len(queue)
        level = []
        for _ in range(level_size):
            node = queue.popleft()
            level.append(node.val)
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        result.append(level)
    
    return result
```
</details>

<details>
<summary>7. Backtracking Template</summary>

```python
ans = []
def dfs(start_index, path, [...additional states]):
    if is_leaf(start_index):
        ans.append(path[:]) # add a copy of the path to the result
        return
    for edge in get_edges(start_index, [...additional states]):
        # prune if needed
        if not is_valid(edge):
            continue
        path.add(edge)
        if additional states:
            update(...additional states)
        dfs(start_index + len(edge), path, [...additional states])
        # revert(...additional states) if necessary e.g permutations
        path.pop()
```

**Example Problem: Subsets**
```python
def subsets(nums: List[int]) -> List[List[int]]:
    result = []
    
    def backtrack(start, path):
        result.append(path[:])
        for i in range(start, len(nums)):
            path.append(nums[i])
            backtrack(i + 1, path)
            path.pop()
    
    backtrack(0, [])
    return result
```
</details>

<details>
<summary>8. Dynamic Programming (Top-Down) Template</summary>

```python
def solve_problem(input):
    # Option 1: Dictionary for memoization
    memo = {}

    def dp(state):
        # 1. Base cases - when we can answer directly
        if is_base_case(state):
            return base_case_result

        # 2. Check if already computed
        if state in memo:
            return memo[state]

        # 3. Recursive case - explore all possibilities
        result = initial_value # Often 0, float('-inf'), float('inf'), etc.

        for next_state in get_possible_next_states(state):
            # Calculate result for this choice
            subproblem_result = dp(next_state)

            # Combine with current result (min, max, sum, etc.)
            result = combine(result, subproblem_result)

        # 4. Cache result and return
        memo[state] = result
        return result

    # 5. Start recursion from the initial state
    return dp(starting_state)
```

**Example Problem: Climbing Stairs**
```python
def climbStairs(n: int) -> int:
    memo = {}
    
    def dp(steps):
        if steps <= 2:
            return steps
        if steps in memo:
            return memo[steps]
        memo[steps] = dp(steps - 1) + dp(steps - 2)
        return memo[steps]
    
    return dp(n)
```
</details>

Each template follows a consistent pattern that can be applied to various problems. By practicing these scales, you build the muscle memory needed to recognize and implement these patterns quickly and accurately.

## 🚀 Getting Started

> 🎸 *"Time to tune up your coding skills"*

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

3. **Write your code** in the practice file

4. **Validate your code**:
   ```vim
   :ScalesValidate
   ```
3. **Practice Regularly**
   - Focus on understanding the pattern (like learning a new scale)
   - Build muscle memory through repetition (like practicing scales daily)
   - Track your progress with `:ScalesStats` (like keeping a practice log)

4. **Progress Naturally**
   - Move to more complex patterns as you master the basics (like learning advanced scales)
   - Apply patterns to real problems (like improvising with scales)
   - Build confidence through measurable improvement (like seeing your progress)

### Practice Tips

- 🎯 **Focus on Fundamentals**
  - Master basic patterns before moving to complex ones (like learning major scales before modes)
  - Understand the "why" behind each pattern (like understanding scale theory)
  - Practice variations of each pattern (like practicing scales in different positions)

- ⏱️ **Build Consistency**
  - Practice regularly, even for short periods (like daily scale practice)
  - Track your timing and accuracy (like using a metronome)
  - Celebrate small improvements (like mastering a new scale)

- 🎸 **Learn Like a Musician**
  - Start slow and build speed gradually (like practicing scales slowly)
  - Focus on accuracy before speed (like playing clean before fast)
  - Practice deliberately and with purpose (like focused practice sessions)

## 📦 Installation

> 🎸 *"Time to tune up your coding skills"*

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

> 🎵 *"Practice until you can play it in your sleep"*

### Available Commands

Run these commands in Neovim's command mode (press `:` to enter command mode):

| Command | Description |
|---------|-------------|
| `:ScalesGenerate [pattern]` | Start a new practice session (optionally specify a pattern) |
| `:ScalesOpen` | Open your most recent practice file |
| `:ScalesList` | Browse available patterns |
| `:ScalesStats` | Check your practice progress |
| `:ScalesValidate` | Test your implementation |
| `:ScalesPeek` | Look at the solution |
| `:ScalesNext` | Move to next practice |
| `:ScalesReset` | Reset current practice file to start fresh |
| `:ScalesReload` | Refresh templates |
| `:ScalesCommands` | Show all available commands and key mappings |

### Key Mappings

These key mappings are available in normal mode:

| Mapping | Command | Description |
|---------|---------|-------------|
| `\sg` | `:ScalesGenerate` | Generate new practice |
| `\so` | `:ScalesOpen` | Open practice file |
| `\sv` | `:ScalesValidate` | Validate your code |
| `\sl` | `:ScalesList` | List patterns |
| `\ss` | `:ScalesStats` | Show statistics |
| `\sn` | `:ScalesNext` | Next practice |
| `\sp` | `:ScalesPeek` | Peek at solution |
| `\sr` | `:ScalesReset` | Reset current practice file |

> 💡 Tip: You can view all commands and mappings at any time by running `:ScalesCommands`

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

> 🎸 *"The more you practice, the luckier you get"*

### Pattern Difficulty Levels

- 🎸 **Beginner Patterns** (2 stars)
  - [1] Binary Search
    - Practice binary search technique
  - [2] Two Pointers Same Directions
    - Practice two pointers same directions technique
  - [2] Two Pointers Opposite Directions
    - Practice two pointers opposite directions technique

- 🎵 **Intermediate Patterns** (3-4 stars)
  - [3] Sliding Window Fixed Size
    - Practice sliding window fixed size technique
  - [3] Sliding Window Flexible Longest
    - Practice sliding window flexible longest technique
  - [3] Sliding Window Flexible Shortest
    - Practice sliding window flexible shortest technique
  - [4] DFS on Tree
    - Practice depth-first search on tree technique
  - [4] BFS on Tree
    - Practice breadth-first search on tree technique
  - [4] DFS on Graph
    - Practice depth-first search on graph technique
  - [4] BFS on Graph
    - Practice breadth-first search on graph technique
  - [4] BFS on Matrix
    - Practice breadth-first search on matrix technique
  - [4] Prefix Sum
    - Practice prefix sum technique

- 🎼 **Advanced Patterns** (5 stars)
  - [5] Backtracking Basic
    - Practice basic backtracking technique
  - [5] Backtracking Aggregation
    - Practice backtracking with aggregation
  - [5] Topological Sort
    - Practice topological sort technique
  - [5] Union Find
    - Practice union find technique
  - [5] Trie
    - Practice trie technique
  - [5] Monotonic Stack
    - Practice monotonic stack technique
  - [5] DP Top Down
    - Practice dynamic programming top-down technique
  - [5] DP Bottom Up
    - Practice dynamic programming bottom-up technique

## 🏆 Achievements

> 🎵 *"Practice until you can't get it wrong"*

Earn badges and achievements as you practice:

- **Pattern Mastery**
  - 🎸 Master of [Pattern] - 25 practices
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

> 🎸 *"The secret to getting ahead is getting started"*

1. **Start with easier patterns** and gradually increase difficulty (like learning scales)
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
