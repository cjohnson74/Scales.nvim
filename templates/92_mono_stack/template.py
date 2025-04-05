def mono_stack(insert_entries):
    stack = []
    for entry in insert_entries:
        # The monotonic property can only break if and only if the 
        # container is not empty and the last item, compared to the 
        # entry, breaks the property. While that is true, we pop the 
        # top item.
        while stack and stack[-1] <= entry:
            stack.pop()
            # Do something with the popped item here
        stack.append(entry)
