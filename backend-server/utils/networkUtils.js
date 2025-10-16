const os = require('os');

function getLocalIP() {
    const interfaces = os.networkInterfaces();
    
    for (const name of Object.keys(interfaces)) {
        for (const interface of interfaces[name]) {
            // Skip internal and non-IPv4 addresses
            if (interface.family === 'IPv4' && !interface.internal) {
                return interface.address;
            }
        }
    }
    
    return 'localhost'; // Fallback
}

module.exports = { getLocalIP };