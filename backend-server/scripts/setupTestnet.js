const { AptosClient, AptosAccount, HexString } = require('aptos');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function setupTestnet() {
    try {
        const client = new AptosClient(process.env.APTOS_NODE_URL);
        const adminAccount = new AptosAccount(HexString.ensure(process.env.APTOS_ADMIN_PRIVATE_KEY).toUint8Array());
        
        console.log('🔧 Setting up testnet account...');
        console.log('Address:', adminAccount.address().hex());
        
        // Check account
        try {
            const account = await client.getAccount(adminAccount.address());
            console.log('✅ Account exists, sequence:', account.sequence_number);
        } catch (error) {
            console.log('❌ Account not found. Fund it at:');
            console.log('https://aptoslabs.com/testnet-faucet');
            console.log('Address:', adminAccount.address().hex());
            return;
        }
        
        // For now, use a mock blockchain approach
        console.log('💡 Contract deployment requires Aptos CLI.');
        console.log('For testing, your app will use mock blockchain service.');
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

setupTestnet();