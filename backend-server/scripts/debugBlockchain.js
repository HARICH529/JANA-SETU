const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const aptosService = require('../services/aptosService');

async function debugBlockchain() {
    console.log('🔍 Debugging blockchain service...');
    
    try {
        // Initialize service
        await aptosService.initialize();
        console.log('✅ Service initialized:', aptosService.initialized);
        console.log('📍 Admin address:', aptosService.adminAccount?.address().hex());
        console.log('📄 Contract address:', aptosService.contractAddress);
        
        // Test submit report
        console.log('\n🧪 Testing submitReport...');
        const result = await aptosService.submitReport('debug_test_456', '0x123');
        console.log('📝 Result:', result);
        
    } catch (error) {
        console.error('❌ Debug failed:', error);
    }
}

debugBlockchain();