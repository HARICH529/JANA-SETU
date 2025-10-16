// Mock blockchain service for testing without actual deployment
class MockBlockchainService {
  constructor() {
    this.mockTxCounter = 1;
  }

  generateMockTxHash() {
    return `0x${Math.random().toString(16).substr(2, 64)}`;
  }

  async submitReport(reportData) {
    console.log("Mock: Submitting report to blockchain", reportData._id);
    await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate network delay
    
    return { 
      success: true, 
      txHash: this.generateMockTxHash()
    };
  }

  async acknowledgeReport(reportId) {
    console.log("Mock: Acknowledging report", reportId);
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return { 
      success: true, 
      txHash: this.generateMockTxHash()
    };
  }

  async resolveReport(reportId) {
    console.log("Mock: Resolving report", reportId);
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return { 
      success: true, 
      txHash: this.generateMockTxHash()
    };
  }

  async deleteReport(reportId) {
    console.log("Mock: Deleting report", reportId);
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return { 
      success: true, 
      txHash: this.generateMockTxHash()
    };
  }

  async getReport(reportId) {
    console.log("Mock: Getting report", reportId);
    return { 
      success: true, 
      data: {
        id: reportId,
        description: "Mock report",
        status: 0
      }
    };
  }
}

module.exports = new MockBlockchainService();