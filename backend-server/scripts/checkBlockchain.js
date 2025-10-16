const { AptosClient, AptosAccount, HexString } = require('aptos');

async function checkBlockchain() {
    try {
        const client = new AptosClient('https://fullnode.testnet.aptoslabs.com/v1');
        const contractAddress = '0xbb18f7b6e2a27904b788ba22985430e83fa3f374183e1c3278dc2d796630b33a';
        
        console.log('🔍 Checking Aptos Testnet...');
        
        // Check account exists
        try {
            const account = await client.getAccount(contractAddress);
            console.log('✅ Account exists:', account.sequence_number);
        } catch (error) {
            console.log('❌ Account not found or not funded');
            return;
        }
        
        // Check resources
        const resources = await client.getAccountResources(contractAddress);
        console.log('📦 Resources found:', resources.length);
        
        // Check for contract
        const contractResource = resources.find(r => 
            r.type.includes('CivicReportingEvents')
        );
        
        if (contractResource) {
            console.log('✅ Smart contract deployed');
        } else {
            console.log('❌ Smart contract not found');
        }
        
        // Check transactions
        const transactions = await client.getAccountTransactions(contractAddress, { limit: 10 });
        console.log('📝 Recent transactions:', transactions.length);
        
        transactions.forEach((tx, i) => {
            console.log(`${i + 1}. ${tx.type} - ${tx.hash}`);
        });
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

checkBlockchain();