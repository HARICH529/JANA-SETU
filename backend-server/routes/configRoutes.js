const express = require('express');
const { getLocalIP } = require('../utils/networkUtils');
const router = express.Router();

// Get current server configuration
router.get('/current', (req, res) => {
    const localIP = getLocalIP();
    const port = process.env.PORT || 3000;
    const host = req.get('host');
    const protocol = req.protocol;
    
    // Check if request is coming through ngrok
    const isNgrok = host && host.includes('ngrok');
    const currentURL = `${protocol}://${host}`;
    
    res.json({
        success: true,
        data: {
            baseURL: isNgrok ? currentURL : `http://${localIP}:${port}`,
            apiURL: isNgrok ? `${currentURL}/api/v1` : `http://${localIP}:${port}/api/v1`,
            socketURL: isNgrok ? currentURL : `http://${localIP}:${port}`,
            serverIP: localIP,
            port: port,
            isPublic: isNgrok,
            publicURL: isNgrok ? currentURL : null
        }
    });
});

module.exports = router;