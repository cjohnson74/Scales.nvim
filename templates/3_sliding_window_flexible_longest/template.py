def sliding_window_flexible_longest(input):
    initialize window, ans
    left = 0
    for right in range(len(input)):
        append input[right] to window
        while invalid(window):  # update left until window is valid again
            remove input[left] from window
            left += 1
        ans = max(ans, window)  # window is guaranteed to be valid here
