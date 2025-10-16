const express = require('express');
const multer = require('multer');
const {
  createReport,
  getNearbyReports,
  getReportsInBounds,
  getNearbyReportsByDepartment,
  acknowledgeReport,
  resolveReport,
  deleteReport,
  getUserReports,
  getAllReports,
  upvoteReport,
  getAllReportsForMobile,
  getUserReportsForMobile,
  updateReportStatusResolve,
  mlWebhook
} = require('../controllers/reportController');
const authMiddleware = require('../middlewares/authMiddleware');
const { validateReportSubmission } = require('../middlewares/validation');

// Configure multer for memory storage
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit for audio files
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/') || file.mimetype.startsWith('audio/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image and audio files are allowed'), false);
    }
  }
});

const router = express.Router();

// Public geolocation routes (no auth required for viewing nearby reports)
router.get('/test', (req, res) => res.json({ message: 'Public route working!' }));
router.get('/nearby', getNearbyReports);
router.get('/bounds', getReportsInBounds);
router.get('/nearby/department', getNearbyReportsByDepartment);
router.get('/get-all-reports', getAllReportsForMobile);

// ML Webhook (no auth required)
router.post('/ml-webhook', mlWebhook);

// Protected routes (require authentication)
router.use(authMiddleware);

// Mobile client routes
router.post('/create-report', upload.fields([{ name: 'image', maxCount: 1 }, { name: 'voice', maxCount: 1 }]), validateReportSubmission, createReport);
router.post('/:reportId/upvote-report', upvoteReport);
router.get('/fetch-user-reports', getUserReportsForMobile);
router.patch('/:reportId/update-report-status-resolve', updateReportStatusResolve);

// Legacy routes (keep for backward compatibility)
router.post('/', upload.fields([{ name: 'image', maxCount: 1 }, { name: 'voice', maxCount: 1 }]), validateReportSubmission, createReport);
router.get('/my-reports', getUserReports);
router.patch('/:reportId/resolve', resolveReport);

// Admin routes
router.get('/all', getAllReports);
router.patch('/:reportId/acknowledge', acknowledgeReport);
router.delete('/:reportId', deleteReport);

module.exports = router;