const admin = require("../config/firebase");
const User = require("../models/User");
const generateTokens = require("../utils/jwt");
const jwt = require("jsonwebtoken");

// Register with email/password
const register = async (req, res) => {
  try {
    const { name, email, password, mobile } = req.body;

    if (!name || !email || !password || !mobile) {
      return res.status(400).json({ error: "All fields are required" });
    }

    // Check for existing user
    let user = await User.findOne({ email });
    if (user) {
      // User already exists, generate tokens and return success
      const { accessToken, refreshToken } = generateTokens(user);
      await User.findByIdAndUpdate(user._id, { refreshToken });
      
      return res.status(200).json({
        success: true,
        message: "User already registered, logged in successfully",
        data: {
          user: {
            _id: user._id,
            name: user.name,
            email: user.email,
            mobile: user.mobile
          },
          accessToken,
          refreshToken
        }
      });
    }

    // Check for existing mobile
    const existingMobile = await User.findOne({ mobile });
    if (existingMobile) {
      return res.status(409).json({ error: "Mobile number already exists" });
    }

    user = await User.create({
      name: name.trim(),
      email: email.toLowerCase(),
      password,
      mobile,
      authProvider: 'local'
    });

    const { accessToken, refreshToken } = generateTokens(user);
    
    await User.findByIdAndUpdate(user._id, { refreshToken });

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: {
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
          mobile: user.mobile
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ error: "Registration failed" });
  }
};

// Login with email/phone and password
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const existingRefreshToken = req.headers['x-refresh-token'];

    if (!email || !password) {
      return res.status(400).json({ error: "Email/Phone and password are required" });
    }

    // Check if input is email or phone number
    const isEmail = email.includes('@');
    const query = isEmail 
      ? { email: email.toLowerCase() }
      : { mobile: email }; // Using 'email' field for both email and phone input
    
    const user = await User.findOne(query).select('+password +refreshToken');

    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const isPasswordValid = await user.comparePassword(password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // Verify existing refresh token if provided
    if (existingRefreshToken && user.refreshToken) {
      try {
        const decoded = jwt.verify(existingRefreshToken, process.env.JWT_REFRESH_SECRET);
        if (user.refreshToken !== existingRefreshToken || decoded.userId !== user._id.toString()) {
          return res.status(403).json({ error: "Invalid session. Please login again." });
        }
      } catch (error) {
        return res.status(403).json({ error: "Invalid or expired session. Please login again." });
      }
    }

    // Generate new tokens
    const { accessToken, refreshToken } = generateTokens(user);
    
    await User.findByIdAndUpdate(user._id, { 
      refreshToken,
      lastLogin: new Date()
    });

    res.status(200).json({
      success: true,
      message: "Login successful",
      data: {
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
          mobile: user.mobile,
          points: user.points,
          badge: user.badge
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
};

// Firebase authentication
const firebaseAuth = async (req, res) => {
  try {
    const { idToken, name, mobile } = req.body;

    if (!idToken) {
      return res.status(400).json({ error: "Firebase ID token is required" });
    }

    const decoded = await admin.auth().verifyIdToken(idToken);
    const { uid, email, email_verified } = decoded;

    let user = await User.findOne({ 
      email: email.toLowerCase() 
    });

    if (!user) {
      if (!name || !mobile) {
        return res.status(400).json({ error: "Name and mobile are required for new users" });
      }

      user = await User.create({
        name: name.trim(),
        email: email.toLowerCase(),
        mobile,
        authProvider: 'firebase',
        isEmailVerified: email_verified || false
      });
    } else {
      user.authProvider = 'firebase';
      await user.save();
    }

    const { accessToken, refreshToken } = generateTokens(user);
    
    await User.findByIdAndUpdate(user._id, { refreshToken });

    res.status(200).json({
      success: true,
      message: "Authentication successful",
      data: {
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
          mobile: user.mobile,
          points: user.points,
          badge: user.badge
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error("Firebase auth error:", error);
    res.status(401).json({ error: "Invalid Firebase token" });
  }
};

// Refresh token
const refresh = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(400).json({ error: "Refresh token required" });

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    const user = await User.findById(decoded.userId).select('+refreshToken');
    
    if (!user || user.refreshToken !== refreshToken) {
      return res.status(403).json({ error: "Invalid refresh token" });
    }

    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);
    await User.findByIdAndUpdate(user._id, { refreshToken: newRefreshToken });

    res.json({ 
      success: true,
      data: {
        accessToken, 
        refreshToken: newRefreshToken 
      }
    });
  } catch (error) {
    res.status(403).json({ error: "Refresh failed" });
  }
};

// Logout - invalidate refresh token
const logout = async (req, res) => {
  try {
    const userId = req.user.userId;
    await User.findByIdAndUpdate(userId, { $unset: { refreshToken: 1 } });
    
    res.status(200).json({ 
      success: true,
      message: "Logout successful" 
    });
  } catch (error) {
    res.status(500).json({ error: "Logout failed" });
  }
};

// Save FCM token for push notifications
const saveFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    const userId = req.user.userId;

    if (!fcmToken) {
      return res.status(400).json({ error: "FCM token is required" });
    }

    await User.findByIdAndUpdate(userId, { fcmToken });
    
    res.status(200).json({ 
      success: true,
      message: "FCM token saved successfully" 
    });
  } catch (error) {
    console.error("Save FCM token error:", error);
    res.status(500).json({ error: "Failed to save FCM token" });
  }
};

// Get user profile with resolved reports count
const getProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const Report = require('../models/Report');
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Count resolved reports submitted by user
    const resolvedReportsCount = await Report.countDocuments({
      userId: userId,
      reportStatus: 'RESOLVED'
    });

    res.json({
      success: true,
      message: "Profile retrieved successfully",
      data: {
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
          mobile: user.mobile,
          points: user.points,
          monthlyPoints: user.monthlyPoints,
          badge: user.badge,
          resolvedReportsCount
        }
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Failed to get profile' });
  }
};

module.exports = { register, login, firebaseAuth, refresh, logout, saveFcmToken, getProfile };