const { exec } = require('child_process');
const { getLocalIP } = require('../utils/networkUtils');

const localIP = getLocalIP();
const port = process.env.PORT || 3000;

console.log('🚀 Starting development server...');
console.log(`📍 Current network IP: ${localIP}`);
console.log(`🔗 API will be available at: http://${localIP}:${port}`);

// Set environment variable for current session
process.env.CURRENT_IP = localIP;

// Start the server
require('../index.js');