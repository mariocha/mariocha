# Score Sheet Usage Guide

## Overview
This repository contains an interactive HTML score sheet with automatic total calculation functionality.

## Features
- **4 columns by 10 rows** grid for data entry
- **Automatic total calculation** - totals update instantly as you enter values
- **Clean, professional design** with a green color scheme
- **Number input fields** with built-in validation
- **Responsive layout** that works on different screen sizes

## How to Use

### Opening the Score Sheet
1. Download or clone this repository
2. Open `score-sheet.html` in any modern web browser (Chrome, Firefox, Safari, Edge)
3. No server or installation required - it works directly in your browser

### Entering Scores
1. Click on any input field in the table
2. Type a number (decimals are supported)
3. The total for that column will automatically update as you type
4. Press Tab or click another field to continue entering data

### Features
- **Live Updates**: Totals update automatically upon input without needing to click a button
- **Decimal Support**: You can enter decimal values (e.g., 10.5, 25.75)
- **Visual Feedback**: Input fields highlight when selected for better usability
- **Total Row**: The bottom row displays the sum of all values in each column

## Technical Details
- Pure HTML, CSS, and JavaScript - no external dependencies
- Uses event listeners on input fields to trigger automatic calculations
- Data attributes (`data-col`, `data-row`) help track which column each input belongs to
- Totals are formatted to 2 decimal places for consistency

## Screenshot

### Initial State
![Score Sheet Initial](https://github.com/user-attachments/assets/a0db914f-034b-454c-98f1-379ddddecc50)

### With Data Entered
![Score Sheet with Totals](https://github.com/user-attachments/assets/e739c2a3-7358-4005-a293-c598b9db8c53)

The score sheet automatically calculates:
- Column 1: 35.00 (10 + 25)
- Column 2: 15.00
- Column 3: 30.00  
- Column 4: 20.00

## Browser Compatibility
Works with all modern browsers including:
- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Opera (latest)
