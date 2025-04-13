# Initialize result list
ans = []
def backtrack(start_index, path, *additional_states):
    if is_leaf(start_index):
        ans.append(path[:])  # Create a copy of the path
        return
    
    # Explore all possible edges from current state
    for edge in get_edges(start_index, *additional_states):
        # Prune invalid branches
        if not is_valid(edge):
            continue
        
        # Add edge to path and update states
        path.append(edge)
        if additional_states:
            update_states(*additional_states)
        
        # Recurse to explore this branch
        backtrack(start_index + len(edge), path, *additional_states)
        
        # Backtrack: revert states and remove edge from path
        if additional_states:
            revert_states(*additional_states)  # Only needed when modifying shared state (e.g. permutations)
        path.pop()  # Remove the edge we just added