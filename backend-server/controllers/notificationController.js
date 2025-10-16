const notificationService = require('../services/notificationService');

const getUserNotifications = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { page = 1, limit = 20 } = req.query;
    
    const result = await notificationService.getUserNotifications(
      userId, 
      parseInt(page), 
      parseInt(limit)
    );
    
    if (!result) {
      return res.status(500).json({
        success: false,
        error: 'Failed to fetch notifications'
      });
    }
    
    res.json({
      success: true,
      message: 'Notifications retrieved successfully',
      data: result
    });
  } catch (error) {
    console.error('Get user notifications error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch notifications'
    });
  }
};

const markNotificationAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;
    
    const success = await notificationService.markNotificationAsRead(notificationId);
    
    if (!success) {
      return res.status(500).json({
        success: false,
        error: 'Failed to mark notification as read'
      });
    }
    
    res.json({
      success: true,
      message: 'Notification marked as read'
    });
  } catch (error) {
    console.error('Mark notification as read error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to mark notification as read'
    });
  }
};

const markAllNotificationsAsRead = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const success = await notificationService.markAllNotificationsAsRead(userId);
    
    if (!success) {
      return res.status(500).json({
        success: false,
        error: 'Failed to mark all notifications as read'
      });
    }
    
    res.json({
      success: true,
      message: 'All notifications marked as read'
    });
  } catch (error) {
    console.error('Mark all notifications as read error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to mark all notifications as read'
    });
  }
};

module.exports = {
  getUserNotifications,
  markNotificationAsRead,
  markAllNotificationsAsRead
};