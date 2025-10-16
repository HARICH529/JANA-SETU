const mongoose = require('mongoose');
const { Schema } = mongoose;
const bcrypt = require("bcrypt");

const userSchema = new Schema(
  {

    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      minlength: [2, 'Name must be at least 2 characters'],
      maxlength: [50, 'Name cannot exceed 50 characters']
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, 'Please provide a valid email']
    },
    password: {
      type: String,
      required: function() {
        return this.authProvider === 'local';
      },
      minlength: [6, 'Password must be at least 6 characters'],
      select: false
    },
    mobile: {
      type: String,
      required: [true, 'Mobile number is required'],
      match: [/^\d{10}$/, 'Please provide a valid 10-digit mobile number']
    },
    isEmailVerified: {
      type: Boolean,
      default: false
    },
    authProvider: {
      type: String,
      enum: ['local', 'firebase'],
      default: 'local'
    },
    reports: [
      {
        type: Schema.Types.ObjectId,
        ref: "Report"
      }
    ],
    coverImage: {
      type: String
    },
    refreshToken: {
      type: String,
      select: false
    },
    points: {
      type: Number,
      default: 0,
      min: 0
    },
    monthlyPoints: {
      type: Number,
      default: 0,
      min: 0
    },
    lastMonthlyReset: {
      type: Date,
      default: Date.now
    },
    badge: {
      type: String,
      enum: ['Bronze', 'Silver', 'Gold', 'Platinum'],
      default: "Bronze"
    },
    isActive: {
      type: Boolean,
      default: true
    },
    lastLogin: {
      type: Date
    },
    loginAttempts: {
      type: Number,
      default: 0
    },
    lockUntil: {
      type: Date
    },
    fcmToken: {
      type: String
    }
  },
  { 
    timestamps: true,
    toJSON: {
      transform: function(doc, ret) {
        delete ret.password;
        delete ret.refreshToken;
        delete ret.__v;
        return ret;
      }
    }
  }
);

userSchema.virtual('isLocked').get(function() {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

userSchema.pre("save", async function (next) {
  try {
    if (!this.isModified("password") || !this.password) return next();
    this.password = await bcrypt.hash(this.password, 12);
    next();
  } catch (error) {
    next(error);
  }
});

userSchema.methods.comparePassword = async function (password) {
  if (!this.password) return false;
  return await bcrypt.compare(password, this.password);
};

userSchema.methods.incLoginAttempts = function() {
  if (this.lockUntil && this.lockUntil < Date.now()) {
    return this.updateOne({
      $unset: { lockUntil: 1 },
      $set: { loginAttempts: 1 }
    });
  }
  
  const updates = { $inc: { loginAttempts: 1 } };
  
  if (this.loginAttempts + 1 >= 5 && !this.isLocked) {
    updates.$set = { lockUntil: Date.now() + 2 * 60 * 60 * 1000 };
  }
  
  return this.updateOne(updates);
};

userSchema.methods.resetLoginAttempts = function() {
  return this.updateOne({
    $unset: { loginAttempts: 1, lockUntil: 1 },
    $set: { lastLogin: new Date() }
  });
};

userSchema.methods.updateBadge = function() {
  let newBadge = 'Bronze';
  if (this.points >= 1000) newBadge = 'Platinum';
  else if (this.points >= 500) newBadge = 'Gold';
  else if (this.points >= 200) newBadge = 'Silver';
  
  if (this.badge !== newBadge) {
    this.badge = newBadge;
    return true;
  }
  return false;
};

userSchema.methods.addPoints = function(points) {
  this.points += points;
  this.monthlyPoints += points;
  this.updateBadge();
};

userSchema.methods.resetMonthlyPoints = function() {
  this.monthlyPoints = 0;
  this.lastMonthlyReset = new Date();
};


module.exports = mongoose.model("User", userSchema);