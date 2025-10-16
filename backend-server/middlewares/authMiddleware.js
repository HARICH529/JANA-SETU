const jwt = require("jsonwebtoken");
const User = require("../models/User");

const authMiddleware = async (req, res, next) => {
  try {
    console.log('🔐 Auth middleware hit for:', req.path);
    const authHeader = req.headers.authorization;
    console.log('🔑 Auth header:', authHeader ? 'Present' : 'Missing');
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      console.log('❌ No token provided');
      return res.status(401).json({ error: "No token provided" });
    }

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const user = await User.findById(decoded.userId);
    if (!user) {
      return res.status(401).json({ error: "User not found" });
    }

    req.user = {
      userId: user._id,
      email: user.email,
      name: user.name,
      mobile: user.mobile,
      points: user.points || 0,
      badge: user.badge || 'Bronze',
      uid: user.uid
    };
    
    console.log('✅ Auth successful for user:', user.email);
    next();
  } catch (err) {
    return res.status(403).json({ error: "Invalid or expired token" });
  }
};

module.exports = authMiddleware;