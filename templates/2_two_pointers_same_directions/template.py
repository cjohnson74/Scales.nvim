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
