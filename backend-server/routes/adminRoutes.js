const express = require('express');
const {
  login,
  getAllReports,
  updateReportAcknowledge,
  getReportLocations
} = require('../controllers/adminController');
const adminMiddleware = require('../middlewares/adminMiddleware');

const router = express.Router();

// Public admin routes
router.post('/login', login);

// Protected admin routes
router.use(adminMiddleware);
router.get('/get-all-reports', getAllReports);
router.get('/get-report-locations', getReportLocations);
router.patch('/update-report-acknowledge/:reportId', updateReportAcknowledge);

module.exports = router;