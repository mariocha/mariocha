# README - SketchUp One-Step Undo Fix

## 📖 Documentation Navigation

**This repository contains a complete solution for the SketchUp one-step undo issue.**

### Start Here
👉 **[INDEX.md](INDEX.md)** - Main documentation index with multiple learning paths

### Quick Access
- **[QUICK_FIX_GUIDE.md](QUICK_FIX_GUIDE.md)** - 3-step implementation guide
- **[VISUAL_TIMELINE.md](VISUAL_TIMELINE.md)** - Visual explanation of the problem
- **[SOLUTION_EXPLANATION.md](SOLUTION_EXPLANATION.md)** - Technical deep dive
- **[SUMMARY.md](SUMMARY.md)** - Complete overview
- **[animdor_fix.rb](animdor_fix.rb)** - Fixed code implementation

## The Problem
The `animdor` method uses `start_operation` and `commit_operation`, but `UI.start_timer` callbacks execute **after** `commit_operation` is called. This means animated changes happen outside the undo transaction, requiring multiple undo steps.

## The Solution
Track pending timer operations with a counter (`@pending_commits`) and delay calling `commit_operation` until all timers complete. This ensures all changes stay within a single undo transaction.

## How to Use
1. Choose your path in [INDEX.md](INDEX.md)
2. Follow the implementation steps in [QUICK_FIX_GUIDE.md](QUICK_FIX_GUIDE.md)
3. Reference [animdor_fix.rb](animdor_fix.rb) for the complete corrected code
4. Integrate the fix into your SketchUp plugin

## Result
After implementing the fix, pressing Ctrl+Z (Undo) will revert **all** changes in a single step! ✅

---

For the original profile README, see the bottom of this repository's main README.md file.
