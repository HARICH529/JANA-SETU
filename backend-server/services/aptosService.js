const { AptosClient, AptosAccount, FaucetClient, HexString } = require('aptos');

class AptosService {
    constructor() {
        this.client = new AptosClient(process.env.APTOS_NODE_URL || 'https://fullnode.devnet.aptoslabs.com/v1');
        this.adminAccount = null;
        this.contractAddress = process.env.APTOS_CONTRACT_ADDRESS;
        this.initialized = false;
    }

    async initialize() {
        try {
            const adminPrivateKey = process.env.APTOS_ADMIN_PRIVATE_KEY;
            if (!adminPrivateKey) {
                throw new Error('APTOS_ADMIN_PRIVATE_KEY not found in environment variables');
            }

            this.adminAccount = new AptosAccount(HexString.ensure(adminPrivateKey).toUint8Array());
            console.log('Admin account address:', this.adminAccount.address().hex());

            // Contract is now deployed, enable real blockchain
            this.initialized = true;
            console.log('Aptos service initialized successfully');
        } catch (error) {
            console.error('Failed to initialize Aptos service:', error);
            this.initialized = false;
        }
    }

    async initializeContract() {
        try {
            const payload = {
                type: "entry_function_payload",
                function: `${this.contractAddress}::CivicReporting::initialize`,
                type_arguments: [],
                arguments: []
            };

            const txnRequest = await this.client.generateTransaction(this.adminAccount.address(), payload);
            const signedTxn = await this.client.signTransaction(this.adminAccount, txnRequest);
            const transactionRes = await this.client.submitTransaction(signedTxn);
            await this.client.waitForTransaction(transactionRes.hash);
            
            console.log('Contract initialized successfully');
        } catch (error) {
            // Contract might already be initialized
            console.log('Contract initialization skipped (might already be initialized)');
        }
    }

    async submitReport(reportId, userAddress) {
        if (!this.initialized) {
            console.log('Mock: Report submitted to blockchain:', reportId);
            return `mock_tx_${Date.now()}`;
        }
        console.log('Submitting report to blockchain:', reportId);
        const cleanReportId = reportId.toString();
        const cleanUserAddr = HexString.ensure(userAddress).toString();
        try {
            const payload = {
                type: "entry_function_payload",
                function: `${this.contractAddress}::CivicReporting::submit_report`,
                type_arguments: [],
                arguments: [cleanReportId, cleanUserAddr]
            };

            const txnRequest = await this.client.generateTransaction(this.adminAccount.address(), payload);
            const signedTxn = await this.client.signTransaction(this.adminAccount, txnRequest);
            const transactionRes = await this.client.submitTransaction(signedTxn);
            await this.client.waitForTransaction(transactionRes.hash);

            console.log(`✅ Report submitted to blockchain: ${reportId} - TX: ${transactionRes.hash}`);
            return transactionRes.hash;
        } catch (error) {
            console.error('Failed to submit report to blockchain:', error);
            console.log('Mock: Report submitted to blockchain:', reportId);
            return `mock_tx_${Date.now()}`;
        }
    }

    async acknowledgeReport(reportId, userAddress) {
        if (!this.initialized) {
            console.log('Mock: Report acknowledged on blockchain:', reportId);
            return `mock_tx_${Date.now()}`;
        }

        const cleanReportId = reportId.toString();
        const cleanUserAddr = HexString.ensure(userAddress).toString();

        try {
            const payload = {
                type: "entry_function_payload",
                function: `${this.contractAddress}::CivicReporting::acknowledge_report`,
                type_arguments: [],
                arguments: [cleanReportId, cleanUserAddr]
            };

            const txnRequest = await this.client.generateTransaction(this.adminAccount.address(), payload);
            const signedTxn = await this.client.signTransaction(this.adminAccount, txnRequest);
            const transactionRes = await this.client.submitTransaction(signedTxn);
            await this.client.waitForTransaction(transactionRes.hash);

            console.log(`Report acknowledged on blockchain: ${reportId}`);
            return transactionRes.hash;
        } catch (error) {
            console.error('Failed to acknowledge report on blockchain:', error);
            console.log('Mock: Report acknowledged on blockchain:', reportId);
            return `mock_tx_${Date.now()}`;
        }
    }

    async resolveReport(reportId, userAddress) {
        if (!this.initialized) {
            console.log('Mock: Report resolved on blockchain:', reportId);
            return `mock_tx_${Date.now()}`;
        }

        const cleanReportId = reportId.toString();
        const cleanUserAddr = HexString.ensure(userAddress).toString();

        try {
            const payload = {
                type: "entry_function_payload",
                function: `${this.contractAddress}::CivicReporting::resolve_report`,
                type_arguments: [],
                arguments: [cleanReportId, cleanUserAddr]
            };

            const txnRequest = await this.client.generateTransaction(this.adminAccount.address(), payload);
            const signedTxn = await this.client.signTransaction(this.adminAccount, txnRequest);
            const transactionRes = await this.client.submitTransaction(signedTxn);
            await this.client.waitForTransaction(transactionRes.hash);

            console.log(`Report resolved on blockchain: ${reportId}`);
            return transactionRes.hash;
        } catch (error) {
            console.error('Failed to resolve report on blockchain:', error);
            console.log('Mock: Report resolved on blockchain:', reportId);
            return `mock_tx_${Date.now()}`;
        }
    }

    async getAccountBalance() {
        if (!this.adminAccount) {
            throw new Error('Admin account not initialized');
        }

        try {
            const resources = await this.client.getAccountResources(this.adminAccount.address());
            const accountResource = resources.find((r) => r.type === "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>");
            return accountResource ? parseInt(accountResource.data.coin.value) : 0;
        } catch (error) {
            console.error('Failed to get account balance:', error);
            return 0;
        }
    }

    async getTransactionHistory() {
        try {
            const transactions = await this.client.getAccountTransactions(
                this.adminAccount.address(),
                { limit: 25 }
            );
            return transactions;
        } catch (error) {
            console.error('Failed to get transaction history:', error);
            return [];
        }
    }
}

module.exports = new AptosService();