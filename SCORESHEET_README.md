# Score Sheet Application

## Overview

This is a score sheet application with 10 rows and 4 input columns (M, L, B columns plus calculated totals). It implements cascading updates so that when you edit values in earlier rows, all subsequent rows are automatically recalculated.

## Problem Solved

The original implementation had individual `checkValues` functions for each row (e.g., `checkValues11`, `checkValues21`, etc.), which meant that editing an earlier row didn't trigger recalculation of later rows. This resulted in incorrect cumulative totals when corrections were made to previous inputs.

## Solution

The new implementation uses a **centralized event handling system** with the following key features:

1. **Single Initialization Function**: `initScoreSheet()` sets up all event listeners for all 10 rows
2. **Global Recalculation**: `recalculateFromRow(startRow)` recalculates all rows starting from the changed row onwards
3. **Row-Specific Calculation**: `calculateRow(rowNum)` handles the calculation logic for a single row

### Calculation Rules

For each row, the total is calculated based on the following rules:

- If **M = 0 AND L = 0**: Total = Manche Number × 10 (e.g., Row 3 gets 30 points)
- If **M = 0 AND L ≠ 0**: Total = Manche Number × -10 (penalty)
- If **M = L** (and both non-zero): Total = 10 points (fixed)
- If **M ≠ L** (and neither is zero): Total = -10 points (penalty)

The **Cumulative Total** for each row is calculated as:
```
Cumulative Total = Previous Row's Cumulative Total + Current Row Total + Current Row B Value
```

## Usage

Simply open `scoresheet.html` in a web browser. No build process or dependencies required.

### How It Works

1. Enter values in the M, L, and B columns for any row
2. The totals are calculated automatically
3. The cumulative totals cascade down to all subsequent rows
4. You can go back and edit earlier rows - all later rows will update automatically

## Files

- **scoresheet.html**: The main HTML structure with the score table
- **scoresheet.js**: The JavaScript implementing the cascading calculation logic

## Example

1. **Initial State**: All inputs are 0, so each row gets Manche × 10 points
   - Row 1: Total = 10, Cumulative = 10
   - Row 2: Total = 20, Cumulative = 30
   - Row 3: Total = 30, Cumulative = 60
   - etc.

2. **After entering M=3, L=3, B=5 in Row 2**:
   - Row 1: Total = 10, Cumulative = 10 (unchanged)
   - Row 2: Total = 10 (matching values), B = 5, Cumulative = 25 (10 + 10 + 5)
   - Row 3: Total = 30, Cumulative = 55 (25 + 30 + 0)
   - All subsequent rows cascade correctly

3. **After changing Row 1's M from 0 to 5**:
   - Row 1: Total = -10 (M ≠ L penalty), Cumulative = -10
   - Row 2: Total = 10, B = 5, Cumulative = 5 (-10 + 10 + 5)
   - Row 3: Total = 30, Cumulative = 35 (5 + 30 + 0)
   - All subsequent rows update automatically

## Key Benefits

✅ **Automatic Cascading**: Changes to any row automatically update all subsequent rows  
✅ **Clean Code**: Single set of event listeners and calculation logic instead of duplicated code  
✅ **Maintainable**: Easy to modify calculation rules in one place  
✅ **Extensible**: Easy to add more rows or columns if needed
