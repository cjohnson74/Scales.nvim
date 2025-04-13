def backtrack(start_index, *additional_states):
    if is_leaf(start_index):
        return 1
    
    ans = initial_value
    for edge in get_edges(start_index, *additional_states):
        # Update states if needed
        if additional_states:
            update_states(*additional_states)
        
        # Recurse and aggregate results
        ans = aggregate(ans, backtrack(start_index + len(edge), *additional_states))
        
        # Backtrack: revert states
        if additional_states:
            revert_states(*additional_states)
    
    return ans
