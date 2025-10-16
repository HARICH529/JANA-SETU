const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const aptosService = require('../services/aptosService');

async function testReportBlockchain() {
    try {
        console.log('🧪 Testing blockchain with actual report data...');
        
        await aptosService.initialize();
        console.log('✅ Service initialized:', aptosService.initialized);
        
        // Use the actual report ID from your API response
        const reportId = '68c69be4f6d6e58e96b0b48b';
        const userId = '68c574a6a7194b9d16e8213c';
        
        console.log('📝 Submitting report:', reportId, 'for user:', userId);
        
        const txHash = await aptosService.submitReport(reportId, userId);
        console.log('✅ Transaction hash:', txHash);
        
        console.log('🔗 Check transaction at:');
        console.log(`https://explorer.aptoslabs.com/txn/${txHash}?network=testnet`);
        
    } catch (error) {
        console.error('❌ Test failed:', error);
    }
}

testReportBlockchain();