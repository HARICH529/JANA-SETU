const aptosService = require('../services/aptosService');

// Get blockchain events for a report
const getBlockchainEvents = async (req, res) => {
  try {
    const { reportId } = req.params;
    
    // Query blockchain events
    const events = await aptosService.client.getEventsByEventHandle(
      aptosService.adminAccount.address(),
      `${aptosService.contractAddress}::CivicReporting::CivicReportingEvents`,
      'report_submitted_events'
    );
    
    const reportEvents = events.filter(event => 
      event.data.report_id === reportId
    );
    
    res.json({
      success: true,
      reportId,
      events: reportEvents
    });
  } catch (error) {
    console.error('Get blockchain events error:', error);
    res.status(500).json({ error: 'Failed to get blockchain events' });
  }
};

// Get account balance
const getAccountBalance = async (req, res) => {
  try {
    const balance = await aptosService.getAccountBalance();
    res.json({
      success: true,
      balance: balance / 100000000, // Convert from octas to APT
      address: aptosService.adminAccount.address().hex()
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get balance' });
  }
};

// Verify blockchain connection
const verifyConnection = async (req, res) => {
  try {
    const ledgerInfo = await aptosService.client.getLedgerInfo();
    res.json({
      success: true,
      connected: true,
      chainId: ledgerInfo.chain_id,
      ledgerVersion: ledgerInfo.ledger_version
    });
  } catch (error) {
    res.status(500).json({ 
      success: false,
      connected: false,
      error: error.message 
    });
  }
};

module.exports = {
  getBlockchainEvents,
  getAccountBalance,
  verifyConnection
};