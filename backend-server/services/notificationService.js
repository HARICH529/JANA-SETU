const admin = require('firebase-admin');
const Notification = require('../models/Notification');

class NotificationService {
  constructor() {
    this.initialized = false;
  }

  initialize() {
    try {
      if (!this.initialized) {
        // Firebase Admin SDK should already be initialized in firebase.js
        this.initialized = true;
        console.log('✅ Notification Service initialized');
      }
    } catch (error) {
      console.error('❌ Notification Service initialization failed:', error);
    }
  }

  async createNotification(userId, reportId, title, message, type = 'status_update') {
    try {
      const notification = new Notification({
        userId,
        reportId,
        title,
        message,
        type,
        isRead: false
      });
      
      await notification.save();
      console.log('✅ Notification saved to database');
      return notification;
    } catch (error) {
      console.error('❌ Failed to save notification to database:', error);
      return null;
    }
  }

  async sendReportAcknowledgedNotification(userFcmToken, reportTitle, reportId, userId) {
    try {
      if (!this.initialized) {
        this.initialize();
      }

      const title = 'Report Acknowledged! 🎉';
      const body = `Your report "${reportTitle}" has been acknowledged by authorities and is now being processed.`;
      
      // Store notification in database with current timestamp
      await this.createNotification(userId, reportId, title, body, 'acknowledgment');

      if (!userFcmToken) {
        console.log('No FCM token available for user');
        return null;
      }

      const message = {
        token: userFcmToken,
        notification: {
          title,
          body
        },
        data: {
          type: 'report_acknowledged',
          reportId: reportId,
          title: reportTitle
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#2196F3',
            sound: 'default'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      };

      const response = await admin.messaging().send(message);
      console.log('✅ Notification sent successfully:', response);
      return response;
    } catch (error) {
      console.error('❌ Failed to send notification:', error);
      return null;
    }
  }

  async sendReportStatusUpdateNotification(userFcmToken, reportTitle, newStatus, reportId, userId) {
    try {
      if (!this.initialized) {
        this.initialize();
      }

      const statusMessages = {
        'acknowledged': 'Your report has been acknowledged and is being reviewed.',
        'in_progress': 'Work has started on your report!',
        'resolved': 'Great news! Your report has been resolved.'
      };

      const title = 'Report Status Update';
      const body = statusMessages[newStatus.toLowerCase()] || `Your report status has been updated to ${newStatus}.`;
      
      // Store notification in database with current timestamp
      await this.createNotification(userId, reportId, title, body, 'status_update');

      if (!userFcmToken) {
        console.log('No FCM token available for user');
        return null;
      }

      const message = {
        token: userFcmToken,
        notification: {
          title,
          body
        },
        data: {
          type: 'status_update',
          reportId: reportId,
          status: newStatus,
          title: reportTitle
        },
        android: {
          notification: {
            icon: 'ic_notification',
            color: '#2196F3',
            sound: 'default'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      };

      const response = await admin.messaging().send(message);
      console.log('✅ Status update notification sent successfully:', response);
      return response;
    } catch (error) {
      console.error('❌ Failed to send status update notification:', error);
      return null;
    }
  }

  async getUserNotifications(userId, page = 1, limit = 20) {
    try {
      const skip = (page - 1) * limit;
      
      const notifications = await Notification.find({ userId })
        .populate('reportId', 'title')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit);
      
      const total = await Notification.countDocuments({ userId });
      const unreadCount = await Notification.countDocuments({ userId, isRead: false });
      
      return {
        notifications,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        },
        unreadCount
      };
    } catch (error) {
      console.error('❌ Failed to get user notifications:', error);
      return null;
    }
  }

  async markNotificationAsRead(notificationId) {
    try {
      await Notification.findByIdAndUpdate(notificationId, { isRead: true });
      console.log('✅ Notification marked as read');
      return true;
    } catch (error) {
      console.error('❌ Failed to mark notification as read:', error);
      return false;
    }
  }

  async markAllNotificationsAsRead(userId) {
    try {
      await Notification.updateMany({ userId, isRead: false }, { isRead: true });
      console.log('✅ All notifications marked as read');
      return true;
    } catch (error) {
      console.error('❌ Failed to mark all notifications as read:', error);
      return false;
    }
  }
}

module.exports = new NotificationService();