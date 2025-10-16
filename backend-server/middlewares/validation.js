const ApiError = require("../utils/apiError");

const validateRegistration = (req, res, next) => {
  const { name, email, password, mobile } = req.body;
  const errors = [];

  if (!name || name.trim().length < 2) {
    errors.push("Name must be at least 2 characters long");
  }

  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.push("Please provide a valid email address");
  }

  if (!password || password.length < 6) {
    errors.push("Password must be at least 6 characters long");
  }

  if (!mobile || !/^[6-9]\d{9}$/.test(mobile)) {
    errors.push("Please provide a valid 10-digit mobile number");
  }

  // Check for common weak passwords
  const weakPasswords = ['123456', 'password', '123456789', 'qwerty', 'abc123'];
  if (password && weakPasswords.includes(password.toLowerCase())) {
    errors.push("Password is too weak. Please choose a stronger password");
  }

  if (errors.length > 0) {
    throw new ApiError(400, "Validation failed", errors);
  }

  next();
};

const validateLogin = (req, res, next) => {
  const { email, password } = req.body;
  const errors = [];

  if (!email) {
    errors.push("Email or phone number is required");
  } else {
    // Check if it's email or phone
    const isEmail = email.includes('@');
    const isPhone = /^[6-9]\d{9}$/.test(email);
    
    if (!isEmail && !isPhone) {
      errors.push("Please provide a valid email address or 10-digit phone number");
    }
  }

  if (!password) {
    errors.push("Password is required");
  }

  if (errors.length > 0) {
    throw new ApiError(400, "Validation failed", errors);
  }

  next();
};

const validateFirebaseAuth = (req, res, next) => {
  const { idToken, name, mobile } = req.body;
  const errors = [];

  if (!idToken) {
    errors.push("Firebase ID token is required");
  }

  // For new users, name and mobile are required
  if (name !== undefined && (!name || name.trim().length < 2)) {
    errors.push("Name must be at least 2 characters long");
  }

  if (mobile !== undefined && (!mobile || !/^[6-9]\d{9}$/.test(mobile))) {
    errors.push("Please provide a valid 10-digit mobile number");
  }

  if (errors.length > 0) {
    throw new ApiError(400, "Validation failed", errors);
  }

  next();
};

const validateReportSubmission = (req, res, next) => {
  const { description } = req.body;
  const hasImage = req.files && req.files.image && req.files.image[0];
  const hasAudio = req.files && req.files.voice && req.files.voice[0];
  const hasDescription = description && description.trim().length > 0;

  if (!hasDescription && !hasImage && !hasAudio) {
    throw new ApiError(400, "Please provide at least description, image, or audio");
  }

  next();
};

const sanitizeInput = (req, res, next) => {
  // Remove any potential XSS attempts
  const sanitize = (obj) => {
    for (let key in obj) {
      if (typeof obj[key] === 'string') {
        obj[key] = obj[key].replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
        obj[key] = obj[key].replace(/javascript:/gi, '');
        obj[key] = obj[key].replace(/on\w+\s*=/gi, '');
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        sanitize(obj[key]);
      }
    }
  };

  if (req.body) sanitize(req.body);
  if (req.query) sanitize(req.query);
  if (req.params) sanitize(req.params);

  next();
};

module.exports = {
  validateRegistration,
  validateLogin,
  validateFirebaseAuth,
  validateReportSubmission,
  sanitizeInput
};