// Global state to manage all rows
const TOTAL_ROWS = 10;

// Helper function to get the element ID suffix for a given row number
// Row 1 → 11, Row 2 → 21, Row 3 → 31, etc.
function getElementIdSuffix(rowNum) {
    return rowNum * 10 + 1;
}

// Initialize the score sheet
function initScoreSheet() {
    // Add event listeners to all input fields with a single global handler
    for (let row = 1; row <= TOTAL_ROWS; row++) {
        const mancheNum = getElementIdSuffix(row);
        
        // Get input elements for this row
        const M = document.querySelector(`#M${mancheNum} input`);
        const L = document.querySelector(`#L${mancheNum} input`);
        const B = document.querySelector(`#B${mancheNum} input`);
        
        if (M && L && B) {
            // Add listeners that trigger recalculation from the current row onwards
            M.addEventListener('input', () => recalculateFromRow(row));
            L.addEventListener('input', () => recalculateFromRow(row));
            B.addEventListener('input', () => recalculateFromRow(row));
        }
    }
    
    // Initial calculation for all rows
    recalculateFromRow(1);
}

// Recalculate all rows starting from the given row number
function recalculateFromRow(startRow) {
    for (let row = startRow; row <= TOTAL_ROWS; row++) {
        calculateRow(row);
    }
}

// Calculate totals for a specific row
function calculateRow(rowNum) {
    const mancheNum = getElementIdSuffix(rowNum);
    
    // Get elements for this row
    const mancheSpan = document.getElementById(`mancheNum${rowNum}`);
    const M = document.querySelector(`#M${mancheNum} input`);
    const L = document.querySelector(`#L${mancheNum} input`);
    const B = document.querySelector(`#B${mancheNum} input`);
    const tot = document.getElementById(`tot${mancheNum}`);
    const totB = document.getElementById(`totB${mancheNum}`);
    const totaL = document.getElementById(`totaL${mancheNum}`);
    
    // Check if all elements exist
    if (!mancheSpan || !M || !L || !B || !tot || !totB || !totaL) {
        console.error(`Missing elements for row ${rowNum}`);
        return;
    }
    
    // Get the manche number (row number)
    const manche = parseInt(mancheSpan.textContent);
    
    // Get input values
    const mValue = parseInt(M.value) || 0;
    const lValue = parseInt(L.value) || 0;
    const bValue = parseInt(B.value) || 0;
    
    // Calculate the main total based on the rules
    let totalValue = 0;
    
    if (mValue === 0 && lValue === 0) {
        // Both are 0: give points based on manche number
        totalValue = manche * 10;
    } else if (mValue === 0 && lValue !== 0) {
        // M is 0 but L is not: negative points
        totalValue = manche * -10;
    } else if (mValue === lValue) {
        // Values match: fixed 10 points
        totalValue = 10;
    } else {
        // Values don't match: -10 points
        totalValue = -10;
    }
    
    // Update the total for this row
    tot.textContent = totalValue;
    
    // Update the B total (just copy the B value)
    totB.textContent = bValue;
    
    // Calculate cumulative total
    // Get the previous row's cumulative total
    let previousCumulativeTotal = 0;
    if (rowNum > 1) {
        const prevRowNum = rowNum - 1;
        const prevMancheNum = getElementIdSuffix(prevRowNum);
        const prevTotaL = document.getElementById(`totaL${prevMancheNum}`);
        if (prevTotaL) {
            previousCumulativeTotal = parseInt(prevTotaL.textContent) || 0;
        }
    }
    
    // Cumulative total = previous cumulative + current total + current B value
    const cumulativeTotal = previousCumulativeTotal + totalValue + bValue;
    totaL.textContent = cumulativeTotal;
}

// Initialize when the DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initScoreSheet);
} else {
    initScoreSheet();
}
