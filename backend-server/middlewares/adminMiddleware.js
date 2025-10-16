const jwt = require('jsonwebtoken');
const Admin = require('../models/Admin');

const adminMiddleware = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const admin = await Admin.findById(decoded.adminId);
    
    if (!admin) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    req.admin = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

module.exports = adminMiddleware;