const express = require('express');
const {
  getUserNotifications,
  markNotificationAsRead,
  markAllNotificationsAsRead
} = require('../controllers/notificationController');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// All notification routes require authentication
router.use(authMiddleware);

// Get user notifications
router.get('/', getUserNotifications);

// Mark specific notification as read
router.patch('/:notificationId/read', markNotificationAsRead);

// Mark all notifications as read
router.patch('/mark-all-read', markAllNotificationsAsRead);

module.exports = router;