def solve_problem(input):
    # Option 1: Dictionary for memoization
    memo = {}

    # Option 2: Using Python's built-in cache decorator
    # from functools import lru_cache
    # @lru_cache(maxsize=None)

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
