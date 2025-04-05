def sliding_window_flexible_shortest(input):
    initialize window, ans
    left = 0
    for right in range(len(input)):
        append input[right] to window
        while valid(window):
            ans = min(ans, window)  # window is guaranteed to be valid here
            remove input[left] from window
            left += 1
    return ans
