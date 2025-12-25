# Quick Fix Reference

## The Problem
Your `animdor` method calls `commit_operation` before timer callbacks finish, so animated changes happen outside the undo transaction.

## The Fix (3 Steps)

### Step 1: Add instance variable at the top of your class
```ruby
def initialize
  # ... your existing code ...
  @pending_commits = 0
end
```

### Step 2: Wrap ALL timer callbacks that were problematic

**BEFORE:**
```ruby
timer_id = UI.start_timer(0.1, true) {
  opn_door(e, pt, op_ang)
  count += 1
  UI.stop_timer timer_id if count == 4
}
```

**AFTER:**
```ruby
@pending_commits += 1  # Add this line
timer_id = UI.start_timer(0.1, true) {
  opn_door(e, pt, op_ang)
  count += 1
  if count == 4
    UI.stop_timer timer_id
    @pending_commits -= 1           # Add this line
    check_and_commit_operation      # Add this line
  end
}
```

### Step 3: Add helper method and update animdor

**Add this method:**
```ruby
def check_and_commit_operation
  if @pending_commits == 0
    @mod.commit_operation
  end
end
```

**Replace the last line of animdor:**
```ruby
# OLD: @mod.commit_operation
# NEW:
check_and_commit_operation
```

## Complete List of Timers to Fix

In your `animdor` method, you have these timer blocks that need the fix:
1. Door opening (count == 4)
2. Drawer opening (count == 14)
3. SOS opening (count == 8)
4. Return door corner opening (count == 4)
5. Return door coinup opening (count == 4)
6. Width door corner opening (count == 4)
7. Width door coinup opening (count == 4)

Each of these 7 timer blocks needs:
- `@pending_commits += 1` before the timer
- `@pending_commits -= 1` and `check_and_commit_operation` when the timer completes

## That's It!

Now all animations will complete before the operation commits, making it a true single-step undo.
