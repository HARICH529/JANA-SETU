const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reportId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Report',
    required: true
  },
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['status_update', 'upvote', 'acknowledgment'],
    default: 'status_update'
  },
  isRead: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true // This automatically adds createdAt and updatedAt
});

// Index for efficient queries
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ reportId: 1 });

module.exports = mongoose.model('Notification', notificationSchema);