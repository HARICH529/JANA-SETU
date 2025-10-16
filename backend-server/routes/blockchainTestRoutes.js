const express = require('express');
const { forceBlockchainSubmit } = require('../controllers/blockchainTestController');

const router = express.Router();

router.post('/force-submit', forceBlockchainSubmit);

module.exports = router;