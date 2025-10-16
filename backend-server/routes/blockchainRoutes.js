const express = require('express');
const {
  getBlockchainEvents,
  getAccountBalance,
  verifyConnection
} = require('../controllers/blockchainController');
const adminMiddleware = require('../middlewares/adminMiddleware');

const router = express.Router();

// Public routes
router.get('/verify', verifyConnection);

// Admin routes
router.use(adminMiddleware);
router.get('/events/:reportId', getBlockchainEvents);
router.get('/balance', getAccountBalance);

module.exports = router;