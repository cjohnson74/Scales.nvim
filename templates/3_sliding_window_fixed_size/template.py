def sliding_window_fixed(input, window_size):
    # Initialize window with first window_size elements
    window = input[:window_size]
    ans = window
    
    # Slide window through the input
    for right in range(window_size, len(input)):
        left = right - window_size
        # Remove leftmost element and append new element
        window = window[1:] + [input[right]]
        # Update answer based on window
        ans = optimal(ans, window)
    
    return ans
