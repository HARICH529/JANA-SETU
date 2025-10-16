const { AptosClient, AptosAccount, HexString } = require('aptos');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function publishContract() {
    try {
        const client = new AptosClient(process.env.APTOS_NODE_URL);
        const adminAccount = new AptosAccount(HexString.ensure(process.env.APTOS_ADMIN_PRIVATE_KEY).toUint8Array());
        
        console.log('🚀 Publishing contract to testnet...');
        console.log('Admin address:', adminAccount.address().hex());
        
        // Check if account has funds
        const balance = await client.getAccountBalance(adminAccount.address());
        console.log('Account balance:', balance / 100000000, 'APT');
        
        if (balance === 0) {
            console.log('❌ Account has no funds. Please fund it from testnet faucet:');
            console.log('https://aptoslabs.com/testnet-faucet');
            console.log('Address:', adminAccount.address().hex());
            return;
        }
        
        // Read the compiled Move bytecode (you need to compile first)
        const contractPath = path.join(__dirname, '../blockchain/contracts/CivicReporting.move');
        
        if (!fs.existsSync(contractPath)) {
            console.log('❌ Contract file not found:', contractPath);
            return;
        }
        
        console.log('📝 Contract found, but needs to be compiled with Aptos CLI');
        console.log('Run these commands:');
        console.log('1. cd blockchain');
        console.log('2. aptos move compile');
        console.log('3. aptos move publish --profile default');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

publishContract();