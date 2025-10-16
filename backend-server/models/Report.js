const mongoose = require('mongoose');
const { Schema } = mongoose;

const reportSchema = new Schema(
  {
    title: {
      type: String,
      default: 'Processing...'
    },
    description: {
      type: String,
      default: ''
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        required: true
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        required: true
      }
    },
    address: {
      type: String // Human readable address
    },
    image_url: {
      type: String  // Cloudinary URL
    },
    voice_url: {
      type: String  // Cloudinary URL for audio
    },
    department: {
      type: String,
      enum: ['Roads', 'Water', 'Electricity', 'Sanitation', 'Health', 'Environment', 'Safety', 'Processing', 'Other'],
      default: 'Processing'
    },
    reportStatus: {
      type: String,
      enum: ['SUBMITTED', 'ACKNOWLEDGED', 'RESOLVED', 'DELETED'],
      default: 'SUBMITTED'
    },
    severity: {
      type: String,
      enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
      default: 'MEDIUM'
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    upvotes: {
      type: Number,
      default: 0
    },
    upvotedBy: [{
      type: Schema.Types.ObjectId,
      ref: "User"
    }],
    mlClassified: {
      type: Boolean,
      default: false
    },
    mlSeverity: {
      type: String,
      enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
    },
    mlDepartment: {
      type: String,
      enum: ['Roads', 'Water', 'Electricity', 'Sanitation', 'Health', 'Environment', 'Safety', 'Other']
    },
    mlTitle: {
      type: String
    },
    mlConflicts: {
      type: String
    },
    mlConfidence: {
      severity: { type: Number },
      department: { type: Number }
    },
    isAcknowledged: {
      type: Boolean,
      default: false
    },
    acknowledgedAt: {
      type: Date
    },
    acknowledgedBy: {
      type: Schema.Types.ObjectId,
      ref: "Admin"
    }
  },
  { timestamps: true }
);

// Create 2dsphere index for geospatial queries
reportSchema.index({ location: "2dsphere" });

module.exports = mongoose.model("Report", reportSchema);