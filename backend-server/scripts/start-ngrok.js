const ngrok = require('ngrok');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;

async function startWithNgrok() {
    try {
        // Start the server first
        require('../index.js');
        
        // Wait a bit for server to start
        await new Promise(resolve => setTimeout(resolve, 2000));
        
        // Start ngrok tunnel
        console.log('🚀 Starting ngrok tunnel...');
        const url = await ngrok.connect({
            port: PORT,
            authtoken: process.env.NGROK_AUTH_TOKEN // Optional: add your ngrok auth token
        });
        
        console.log('✅ Ngrok tunnel established!');
        console.log(`🌐 Public URL: ${url}`);
        console.log(`📱 Use this URL in your mobile app and web dashboard`);
        
        // Save URL to config file for clients
        const config = {
            publicURL: url,
            apiURL: `${url}/api/v1`,
            socketURL: url,
            lastUpdated: new Date().toISOString()
        };
        
        fs.writeFileSync(
            path.join(__dirname, '../public/config.json'), 
            JSON.stringify(config, null, 2)
        );
        
        console.log('📄 Config saved to public/config.json');
        
    } catch (error) {
        console.error('❌ Ngrok setup failed:', error);
        process.exit(1);
    }
}

startWithNgrok();