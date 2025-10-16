const { ethers } = require("ethers");

class BlockchainService {
  constructor() {
    this.provider = new ethers.providers.JsonRpcProvider(process.env.POLYGON_RPC_URL);
    this.adminWallet = new ethers.Wallet(process.env.ADMIN_PRIVATE_KEY, this.provider);
    
    // SimpleReportContract ABI
    this.contractABI = [
      "function submitReport(uint256 _reportId, string memory _description, address _userId) external",
      "function updateStatus(uint256 _reportId, uint8 _status) external",
      "function getReport(uint256 _reportId) external view returns (tuple(uint256 id, string description, uint8 status, address userId, uint256 timestamp))"
    ];
    
    this.contract = new ethers.Contract(
      process.env.CONTRACT_ADDRESS,
      this.contractABI,
      this.adminWallet
    );
  }

  async submitReport(reportData) {
    try {
      // For SimpleReportContract (3 parameters)
      const tx = await this.contract.submitReport(
        reportData._id.toString(),
        reportData.description,
        reportData.userId.toString()
      );
      
      const receipt = await tx.wait();
      console.log("Report submitted to blockchain:", receipt.hash);
      return { success: true, txHash: receipt.hash };
    } catch (error) {
      console.error("Blockchain submit error:", error);
      return { success: false, error: error.message };
    }
  }

  async acknowledgeReport(reportId) {
    try {
      const tx = await this.contract.updateStatus(reportId.toString(), 1); // 1 = ACKNOWLEDGED
      const receipt = await tx.wait();
      console.log("Report acknowledged on blockchain:", receipt.hash);
      return { success: true, txHash: receipt.hash };
    } catch (error) {
      console.error("Blockchain acknowledge error:", error);
      return { success: false, error: error.message };
    }
  }

  async resolveReport(reportId) {
    try {
      const tx = await this.contract.updateStatus(reportId.toString(), 2); // 2 = RESOLVED
      const receipt = await tx.wait();
      console.log("Report resolved on blockchain:", receipt.hash);
      return { success: true, txHash: receipt.hash };
    } catch (error) {
      console.error("Blockchain resolve error:", error);
      return { success: false, error: error.message };
    }
  }

  async deleteReport(reportId) {
    try {
      const tx = await this.contract.updateStatus(reportId.toString(), 3); // 3 = DELETED
      const receipt = await tx.wait();
      console.log("Report deleted on blockchain:", receipt.hash);
      return { success: true, txHash: receipt.hash };
    } catch (error) {
      console.error("Blockchain delete error:", error);
      return { success: false, error: error.message };
    }
  }

  async getReport(reportId) {
    try {
      const report = await this.contract.getReport(reportId.toString());
      return { success: true, data: report };
    } catch (error) {
      console.error("Blockchain get report error:", error);
      return { success: false, error: error.message };
    }
  }
}

module.exports = new BlockchainService();