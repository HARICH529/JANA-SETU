const ApiError = require("../utils/apiError");
const ApiResponse = require("../utils/apiResponse");

const errorHandler = (err, req, res, next) => {
  console.error("Error caught by global handler:", {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    url: req.url,
    method: req.method,
    ip: req.ip
  });

  // If it's a custom ApiError
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json(
      new ApiResponse(err.statusCode, null, err.message, err.errors)
    );
  }

  // MongoDB validation errors
  if (err.name === 'ValidationError') {
    const errors = Object.values(err.errors).map(e => e.message);
    return res.status(400).json(
      new ApiResponse(400, null, "Validation failed", errors)
    );
  }

  // MongoDB duplicate key error
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    const message = `${field} already exists`;
    return res.status(409).json(
      new ApiResponse(409, null, message)
    );
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json(
      new ApiResponse(401, null, "Invalid token")
    );
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json(
      new ApiResponse(401, null, "Token expired")
    );
  }

  // Multer file upload errors
  if (err.code === "LIMIT_FILE_SIZE") {
    return res.status(400).json(
      new ApiResponse(400, null, "File too large")
    );
  }

  if (err.code === "LIMIT_UNEXPECTED_FILE") {
    return res.status(400).json(
      new ApiResponse(400, null, "Unexpected file field")
    );
  }

  // Rate limiting errors
  if (err.status === 429) {
    return res.status(429).json(
      new ApiResponse(429, null, "Too many requests, please try again later")
    );
  }

  // Mongoose CastError
  if (err.name === 'CastError') {
    return res.status(400).json(
      new ApiResponse(400, null, "Invalid ID format")
    );
  }

  // Fallback for unhandled errors
  const statusCode = err.statusCode || err.status || 500;
  const message = process.env.NODE_ENV === 'production' 
    ? 'Internal Server Error' 
    : err.message || 'Internal Server Error';

  return res.status(statusCode).json(
    new ApiResponse(statusCode, null, message)
  );
};

module.exports = errorHandler;