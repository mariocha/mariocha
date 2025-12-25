# Visual Timeline: Problem vs Solution

## THE PROBLEM - Why Undo Doesn't Work as Expected

```
animdor() method execution:
│
├─ Time 0ms:   @mod.start_operation('Anim', true)  ◄─── Operation starts
│              ┌─────────────────────────────────────────────┐
│              │ ← Everything here SHOULD be in one undo   │
│              │                                             │
├─ Time 1ms:   │ Loop through entities                      │
│              │                                             │
├─ Time 2ms:   │ UI.start_timer { opn_door(...) }          │
│              │   (schedules callback for 100ms later)     │
│              │                                             │
├─ Time 3ms:   │ UI.start_timer { opn_drawr(...) }         │
│              │   (schedules callback for 100ms later)     │
│              │                                             │
├─ Time 4ms:   │ More loops and timers...                   │
│              │                                             │
├─ Time 5ms:   @mod.commit_operation  ◄─── Operation ends!  │
│              └─────────────────────────────────────────────┘
│              ❌ PROBLEM: Timers haven't run yet!
│
├─ Time 100ms: Timer callback 1 executes
│              opn_door modifies model ◄─── Outside operation! ❌
│
├─ Time 200ms: Timer callback 2 executes  
│              opn_door modifies model ◄─── Outside operation! ❌
│
├─ Time 300ms: Timer callback 3 executes
│              opn_drawr modifies model ◄─── Outside operation! ❌
│
└─ Time 400ms: More timer callbacks...
               All modifying model ◄─── All outside operation! ❌

RESULT: Pressing Undo only reverts the initial changes (Time 0-5ms),
        NOT the animated changes (Time 100ms+)
```

## THE SOLUTION - Delayed Commit

```
animdor() method execution:
│
├─ Time 0ms:   @mod.start_operation('Anim', true)  ◄─── Operation starts
│              ┌─────────────────────────────────────────────┐
│              │ ← Everything here IS in one undo now! ✅   │
│              │                                             │
├─ Time 1ms:   │ @pending_commits = 0                       │
│              │                                             │
├─ Time 2ms:   │ @pending_commits += 1                      │
│              │ UI.start_timer {                           │
│              │   opn_door(...)                            │
│              │   if count == 4:                           │
│              │     @pending_commits -= 1                  │
│              │     check_and_commit_operation             │
│              │ }                                           │
│              │                                             │
├─ Time 3ms:   │ @pending_commits += 1                      │
│              │ UI.start_timer {                           │
│              │   opn_drawr(...)                           │
│              │   if count == 14:                          │
│              │     @pending_commits -= 1                  │
│              │     check_and_commit_operation             │
│              │ }                                           │
│              │                                             │
├─ Time 4ms:   │ More timers, each increments counter...    │
│              │                                             │
├─ Time 5ms:   │ check_and_commit_operation                 │
│              │   if @pending_commits == 0:                │
│              │     commit_operation                       │
│              │   else:                                    │
│              │     DO NOTHING (timers still running) ✅   │
│              │                                             │
├─ Time 100ms: │ Timer callback 1 executes                  │
│              │ opn_door modifies model ◄─── Inside! ✅    │
│              │ @pending_commits -= 1 (now = 1)            │
│              │ check_and_commit_operation                 │
│              │   Still pending, don't commit yet          │
│              │                                             │
├─ Time 200ms: │ Timer callback 2 executes                  │
│              │ opn_door modifies model ◄─── Inside! ✅    │
│              │ @pending_commits -= 1 (now = 0)            │
│              │ check_and_commit_operation                 │
│              │   @pending_commits == 0, so...             │
├─ Time 201ms: @mod.commit_operation  ◄─── NOW we commit!   │
│              └─────────────────────────────────────────────┘
│
└─ Done! All changes are in the operation.

RESULT: Pressing Undo reverts EVERYTHING in a single step! ✅
```

## Key Insight

The fix ensures that `commit_operation` is called **after** the last timer completes, not before the first timer starts.

### Counter Logic
```
Start:             @pending_commits = 0
Schedule timer 1:  @pending_commits = 1
Schedule timer 2:  @pending_commits = 2
Schedule timer 3:  @pending_commits = 3

Check now:         @pending_commits = 3  ➜  Don't commit (timers running)

Timer 1 finishes:  @pending_commits = 2  ➜  Don't commit (more timers)
Timer 2 finishes:  @pending_commits = 1  ➜  Don't commit (more timers)
Timer 3 finishes:  @pending_commits = 0  ➜  COMMIT NOW! ✅
```

## Edge Case: No Timers Started
```
If no timers are started (e.g., all doors already open):
  @pending_commits stays at 0
  check_and_commit_operation sees 0
  Commits immediately
  ➜ Works correctly! ✅
```

This approach handles both animated and non-animated paths correctly.
