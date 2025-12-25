# SketchUp Operation Not Creating Single Undo Step - Solution

## Problem Analysis

The issue is that the `start_operation` and `commit_operation` calls in the `animdor` method are not creating a single undoable operation as expected. This happens because:

1. **`start_operation`** is called at the beginning of the method
2. **`commit_operation`** is called at the end of the method
3. **BUT**: Multiple `UI.start_timer` callbacks are started in between, which execute **asynchronously**
4. These timer callbacks continue running **AFTER** `commit_operation` has already been called
5. Therefore, any model changes made in the timer callbacks occur **outside** the operation transaction

## Root Cause

In SketchUp's API:
- `start_operation` begins a transaction that groups model changes into a single undo step
- `commit_operation` ends the transaction
- `UI.start_timer` creates callbacks that execute asynchronously in the future

The timeline looks like this:
```
Time 0ms:   start_operation called
Time 1ms:   UI.start_timer(...) called (schedules callback for future)
Time 2ms:   UI.start_timer(...) called (schedules callback for future)
Time 3ms:   commit_operation called  <-- Transaction ends here!
Time 100ms: First timer callback executes <-- Outside transaction!
Time 200ms: Second timer callback executes <-- Outside transaction!
```

## Solution

To fix this, you need to delay calling `commit_operation` until **after** all timer callbacks have completed. Here are the key changes:

### 1. Track Pending Operations
```ruby
@pending_commits ||= 0
```

### 2. Increment Counter When Starting a Timer
```ruby
@pending_commits += 1
timer_id = UI.start_timer(0.1, true) {
  # animation code...
  count += 1
  if count == 4  # when animation completes
    UI.stop_timer timer_id
    @pending_commits -= 1
    check_and_commit_operation  # Check if we can commit now
  end
}
```

### 3. Add Helper Method to Commit When Ready
```ruby
def check_and_commit_operation
  if @pending_commits == 0
    @mod.commit_operation
  end
end
```

### 4. Call Helper at End of animdor
```ruby
# At the end of animdor method, after all loops
check_and_commit_operation
```

This ensures:
- If no timers were started, commit happens immediately
- If timers were started, commit waits until all complete
- All model changes stay within the single operation transaction

## Alternative Solution (Simpler but No Animation)

If animations are not critical, you could remove the timers and perform all operations synchronously:

```ruby
if op != true
  # Instead of timer with 4 incremental steps
  # Do all 4 steps at once
  4.times do
    opn_door(e, pt, op_ang)
  end
  e.set_attribute(@dict, 'op', true)
end
```

This would ensure everything stays within the transaction, but you lose the animated effect.

## Implementation Notes

1. Make sure `@pending_commits` is initialized before use
2. Every timer that modifies the model needs to decrement the counter when done
3. The counter approach works because Ruby is single-threaded, so no race conditions
4. Test thoroughly to ensure all animation paths correctly decrement the counter

## Testing

To verify the fix:
1. Open a SketchUp model with the cabinet components
2. Run the `animdor` method
3. After animations complete, press Ctrl+Z (Undo)
4. **Expected**: All changes should undo in a single step
5. **Previously**: Only some changes would undo, leaving the model in an inconsistent state
