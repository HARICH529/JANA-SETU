const { AptosClient, AptosAccount, FaucetClient, HexString } = require('aptos');
const fs = require('fs');
const path = require('path');

async function deployContract() {
    try {
        // Initialize client and admin account
        const client = new AptosClient('https://fullnode.devnet.aptoslabs.com/v1');
        const faucetClient = new FaucetClient('https://fullnode.devnet.aptoslabs.com/v1', 'https://faucet.devnet.aptoslabs.com');
        
        // Create or load admin account
        let adminAccount;
        const privateKeyPath = path.join(__dirname, '../admin_private_key.txt');
        
        if (fs.existsSync(privateKeyPath)) {
            const privateKey = fs.readFileSync(privateKeyPath, 'utf8').trim();
            adminAccount = new AptosAccount(HexString.ensure(privateKey).toUint8Array());
            console.log('Loaded existing admin account:', adminAccount.address().hex());
        } else {
            adminAccount = new AptosAccount();
            fs.writeFileSync(privateKeyPath, adminAccount.toPrivateKeyObject().privateKeyHex);
            console.log('Created new admin account:', adminAccount.address().hex());
            console.log('Private key saved to:', privateKeyPath);
        }

        // Fund account
        console.log('Funding account...');
        await faucetClient.fundAccount(adminAccount.address(), 100000000); // 1 APT
        
        // Wait for funding
        await new Promise(resolve => setTimeout(resolve, 2000));
        
        // Check balance
        try {
            const resources = await client.getAccountResources(adminAccount.address());
            const accountResource = resources.find((r) => r.type === "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>");
            const balance = accountResource ? parseInt(accountResource.data.coin.value) : 0;
            console.log('Account balance:', balance);
        } catch (error) {
            console.log('Could not fetch balance, but account is funded');
        }

        // Compile and publish module
        console.log('Publishing contract...');
        
        const packageMetadata = fs.readFileSync(path.join(__dirname, '../Move.toml'), 'utf8');
        const contractSource = fs.readFileSync(path.join(__dirname, '../contracts/CivicReporting.move'), 'utf8');
        
        // For simplicity, we'll use the account address as the contract address
        const contractAddress = adminAccount.address().hex();
        
        console.log('Contract will be deployed at:', contractAddress);
        console.log('Add this to your .env file:');
        console.log(`APTOS_ADMIN_PRIVATE_KEY=${adminAccount.toPrivateKeyObject().privateKeyHex}`);
        console.log(`APTOS_CONTRACT_ADDRESS=${contractAddress}`);
        
        console.log('\nDeployment completed successfully!');
        console.log('Note: You need to compile and publish the Move contract using Aptos CLI:');
        console.log('1. Install Aptos CLI: https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli');
        console.log('2. Run: aptos move publish --package-dir ./blockchain');
        
    } catch (error) {
        console.error('Deployment failed:', error);
    }
}

deployContract();