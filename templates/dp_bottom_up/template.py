## The Univeral Bottom-Up DP Pattern

## All Bottom-UP DP solutions follow this fundamental structure

def bottom_up_dp(input):
    # 1. Define state representation:
    # What does dp[i] or dp[i][j] mean?

    # 2. Initialize DP array with base cases
    dp = [base_case_values] # could be 1D, 2D, or more

    # 3. Fill DP array in dependency order
    for i in range(start, end):
        # Calculate dp[i] based on previous states
        dp[i] = calculation_based_on_previous_states()
    
    #4. Return final answer
    return extract_answer_from_dp()
