// src/game.js

// Enhance UI clarity
function enhanceUI() {
    const matchDisplay = document.querySelector('.match-display');
    const economySection = document.querySelector('.economy-section');
    const scoutingWatchlist = document.querySelector('.scouting-watchlist');

    // Apply better visual hierarchy
    matchDisplay.style.fontSize = '18px';
    economySection.style.fontSize = '18px';
    scoutingWatchlist.style.fontSize = '18px';

    // Improve labels
    const labels = document.querySelectorAll('.label');
    labels.forEach(label => {
        label.style.fontSize = '16px';
        label.style.color = '#333'; // Darker color for better contrast
    });

    // Add padding for clarity
    matchDisplay.style.padding = '15px';
    economySection.style.padding = '15px';
    scoutingWatchlist.style.padding = '15px';

    // Enhance contrast
    document.body.style.backgroundColor = '#fff'; // White background
    matchDisplay.style.backgroundColor = '#f9f9f9'; // Light grey for separation
    economySection.style.backgroundColor = '#f9f9f9';
    scoutingWatchlist.style.backgroundColor = '#f9f9f9';

    // Improve spacing
    matchDisplay.style.marginBottom = '10px';
    economySection.style.marginBottom = '10px';
    scoutingWatchlist.style.marginBottom = '10px';

    // Final touch
    matchDisplay.style.border = '1px solid #ddd';
    economySection.style.border = '1px solid #ddd';
    scoutingWatchlist.style.border = '1px solid #ddd';
}

// Call enhanceUI on page load
window.onload = enhanceUI;