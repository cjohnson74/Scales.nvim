def sliding_window_flexible_shortest(input):
    # Initialize window and answer
    window = []
    ans = input.copy()  # Initialize with worst case (entire input)
    left = 0
    
    # Slide window through the input
    for right in range(len(input)):
        # Add current element to window
        window.append(input[right])
        
        # While window is valid, try to make it shorter
        while valid(window):
            # Update answer if current window is better
            if len(window) < len(ans):
                ans = window.copy()
            
            # Remove leftmost element to try shorter window
            window.pop(0)
            left += 1
    
    return ans
