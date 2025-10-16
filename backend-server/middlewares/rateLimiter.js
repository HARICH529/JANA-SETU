const ApiError = require('../utils/apiError');

// Simple in-memory rate limiter (for production, use Redis)
const requestCounts = new Map();

const createRateLimiter = (windowMs, maxRequests, message) => {
  return (req, res, next) => {
    const key = req.ip;
    const now = Date.now();
    
    if (!requestCounts.has(key)) {
      requestCounts.set(key, { count: 1, resetTime: now + windowMs });
      return next();
    }
    
    const record = requestCounts.get(key);
    
    if (now > record.resetTime) {
      record.count = 1;
      record.resetTime = now + windowMs;
      return next();
    }
    
    if (record.count >= maxRequests) {
      throw new ApiError(429, message || 'Too many requests, please try again later');
    }
    
    record.count++;
    next();
  };
};

// Clean up old entries periodically
setInterval(() => {
  const now = Date.now();
  for (const [key, record] of requestCounts.entries()) {
    if (now > record.resetTime) {
      requestCounts.delete(key);
    }
  }
}, 60000); // Clean up every minute

// General rate limiter
const generalLimiter = createRateLimiter(
  15 * 60 * 1000, // 15 minutes
  100, // 100 requests
  'Too many requests from this IP, please try again later.'
);

// Strict rate limiter for auth endpoints
const authLimiter = createRateLimiter(
  15 * 60 * 1000, // 15 minutes
  5, // 5 requests
  'Too many authentication attempts, please try again later.'
);

// Very strict limiter for password reset
const passwordResetLimiter = createRateLimiter(
  60 * 60 * 1000, // 1 hour
  3, // 3 requests
  'Too many password reset attempts, please try again later.'
);

module.exports = {
  generalLimiter,
  authLimiter,
  passwordResetLimiter
};