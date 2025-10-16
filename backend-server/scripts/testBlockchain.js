const { AptosClient, AptosAccount, HexString } = require('aptos');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function testBlockchain() {
    try {
        const client = new AptosClient(process.env.APTOS_NODE_URL);
        const adminAccount = new AptosAccount(HexString.ensure(process.env.APTOS_ADMIN_PRIVATE_KEY).toUint8Array());
        
        console.log('🧪 Testing blockchain connection...');
        console.log('Admin address:', adminAccount.address().hex());
        console.log('Contract address:', process.env.APTOS_CONTRACT_ADDRESS);
        
        // Test transaction
        const payload = {
            type: "entry_function_payload",
            function: `${process.env.APTOS_CONTRACT_ADDRESS}::CivicReporting::submit_report`,
            type_arguments: [],
            arguments: ["test_report_123", adminAccount.address().hex()]
        };

        console.log('📝 Submitting test transaction...');
        
        const txnRequest = await client.generateTransaction(adminAccount.address(), payload);
        const signedTxn = await client.signTransaction(adminAccount, txnRequest);
        const transactionRes = await client.submitTransaction(signedTxn);
        
        console.log('✅ Transaction submitted:', transactionRes.hash);
        
        await client.waitForTransaction(transactionRes.hash);
        console.log('✅ Transaction confirmed!');
        
        // Get transaction details
        const txnDetails = await client.getTransactionByHash(transactionRes.hash);
        console.log('📊 Transaction details:', JSON.stringify(txnDetails, null, 2));
        
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        console.error('Full error:', error);
    }
}

testBlockchain();