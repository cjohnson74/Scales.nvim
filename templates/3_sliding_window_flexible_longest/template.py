def sliding_window_flexible_longest(input):
    # Initialize window and answer
    window = []
    ans = []
    left = 0
    
    # Slide window through the input
    for right in range(len(input)):
        # Add current element to window
        window.append(input[right])
        
        # Update left boundary until window is valid
        while invalid(window):
            window.pop(0)  # Remove leftmost element
            left += 1
        
        # Update answer if current window is better
        if len(window) > len(ans):
            ans = window.copy()
    
    return ans
