const { AptosClient, AptosAccount, HexString } = require('aptos');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function deployContract() {
    try {
        const client = new AptosClient(process.env.APTOS_NODE_URL);
        const adminAccount = new AptosAccount(HexString.ensure(process.env.APTOS_ADMIN_PRIVATE_KEY).toUint8Array());
        
        console.log('🚀 Deploying contract...');
        console.log('Admin address:', adminAccount.address().hex());
        
        // Initialize the contract
        const payload = {
            type: "entry_function_payload",
            function: `${process.env.APTOS_CONTRACT_ADDRESS}::CivicReporting::initialize`,
            type_arguments: [],
            arguments: []
        };

        const txnRequest = await client.generateTransaction(adminAccount.address(), payload);
        const signedTxn = await client.signTransaction(adminAccount, txnRequest);
        const transactionRes = await client.submitTransaction(signedTxn);
        
        console.log('📝 Transaction submitted:', transactionRes.hash);
        
        await client.waitForTransaction(transactionRes.hash);
        console.log('✅ Contract initialized successfully!');
        
        // Verify deployment
        const resources = await client.getAccountResources(adminAccount.address());
        const contractResource = resources.find(r => r.type.includes('CivicReportingEvents'));
        
        if (contractResource) {
            console.log('✅ Contract verified on blockchain');
        } else {
            console.log('❌ Contract verification failed');
        }
        
    } catch (error) {
        console.error('❌ Deployment failed:', error.message);
    }
}

deployContract();