const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const { AptosClient, AptosAccount, HexString } = require('aptos');

const forceBlockchainSubmit = async (req, res) => {
    try {
        const { reportId, userId } = req.body;
        
        console.log('🚀 Force blockchain submit:', reportId, userId);
        
        const client = new AptosClient(process.env.APTOS_NODE_URL);
        const adminAccount = new AptosAccount(HexString.ensure(process.env.APTOS_ADMIN_PRIVATE_KEY).toUint8Array());
        
        const payload = {
            type: "entry_function_payload",
            function: `${process.env.APTOS_CONTRACT_ADDRESS}::CivicReporting::submit_report`,
            type_arguments: [],
            arguments: [reportId, userId]
        };

        const txnRequest = await client.generateTransaction(adminAccount.address(), payload);
        const signedTxn = await client.signTransaction(adminAccount, txnRequest);
        const transactionRes = await client.submitTransaction(signedTxn);
        await client.waitForTransaction(transactionRes.hash);

        console.log('✅ Transaction:', transactionRes.hash);
        
        res.json({
            success: true,
            txHash: transactionRes.hash,
            explorerUrl: `https://explorer.aptoslabs.com/txn/${transactionRes.hash}?network=testnet`
        });
        
    } catch (error) {
        console.error('❌ Error:', error);
        res.status(500).json({ error: error.message });
    }
};

module.exports = { forceBlockchainSubmit };