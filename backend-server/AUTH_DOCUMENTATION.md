# Authentication System Documentation

## Overview
This backend server implements a secure authentication system supporting both local (email/password) and Firebase authentication for Flutter mobile applications.

## Features

### Security Features
- **Password Hashing**: bcrypt with salt rounds of 12
- **JWT Tokens**: Access tokens (15min) and refresh tokens (7 days)
- **Rate Limiting**: Protection against brute force attacks
- **Input Validation**: Comprehensive validation and sanitization
- **Account Locking**: Automatic account lock after 5 failed attempts
- **CORS Protection**: Configurable cross-origin resource sharing
- **Helmet Security**: HTTP security headers
- **XSS Protection**: Input sanitization against XSS attacks

### Authentication Methods
1. **Local Authentication**: Email/password registration and login
2. **Firebase Authentication**: Integration with Firebase Auth for Flutter apps

## API Endpoints

### Public Endpoints

#### 1. Register (Local Auth)
```
POST /api/v1/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword123",
  "mobile": "9876543210"
}
```

**Response:**
```json
{
  "statusCode": 201,
  "data": {
    "user": {
      "_id": "...",
      "name": "John Doe",
      "email": "john@example.com",
      "mobile": "9876543210",
      "authProvider": "local",
      "isEmailVerified": false
    },
    "accessToken": "...",
    "refreshToken": "..."
  },
  "message": "User registered successfully",
  "success": true
}
```

#### 2. Login (Local Auth)
```
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword123"
}
```

#### 3. Firebase Authentication
```
POST /api/v1/auth/firebase-auth
Content-Type: application/json

{
  "idToken": "firebase_id_token_here",
  "name": "John Doe",
  "mobile": "9876543210"
}
```

#### 4. Refresh Token
```
POST /api/v1/auth/refresh-token
Content-Type: application/json

{
  "refreshToken": "your_refresh_token_here"
}
```

### Protected Endpoints (Require Authorization Header)

#### 5. Get Profile
```
GET /api/v1/auth/profile
Authorization: Bearer <access_token>
```

#### 6. Update Profile
```
PATCH /api/v1/auth/profile
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Updated Name",
  "mobile": "9876543211"
}
```

#### 7. Logout
```
POST /api/v1/auth/logout
Authorization: Bearer <access_token>
```

## User Model Schema

```javascript
{
  uid: String,              // Firebase UID (optional)
  name: String,             // Required, 2-50 characters
  email: String,            // Required, unique, valid email
  password: String,         // Required for local auth, min 6 chars
  mobile: String,           // Required, 10-digit Indian mobile
  isEmailVerified: Boolean, // Default: false
  authProvider: String,     // 'local' or 'firebase'
  reports: [ObjectId],      // References to Report model
  coverImage: String,       // Cloudinary URL
  refreshToken: String,     // JWT refresh token
  points: Number,           // Default: 0
  badge: String,            // Bronze/Silver/Gold/Platinum
  isActive: Boolean,        // Default: true
  lastLogin: Date,          // Last login timestamp
  loginAttempts: Number,    // Failed login attempts
  lockUntil: Date,          // Account lock expiry
  createdAt: Date,          // Auto-generated
  updatedAt: Date           // Auto-generated
}
```

## Security Measures

### Rate Limiting
- **General API**: 100 requests per 15 minutes per IP
- **Auth Endpoints**: 5 requests per 15 minutes per IP
- **Password Reset**: 3 requests per hour per IP

### Account Security
- **Password Requirements**: Minimum 6 characters, no common weak passwords
- **Account Locking**: 5 failed attempts = 2-hour lock
- **Token Expiry**: Access tokens expire in 15 minutes
- **Refresh Tokens**: Valid for 7 days

### Input Validation
- Email format validation
- Mobile number validation (Indian format)
- XSS protection through input sanitization
- SQL injection prevention through Mongoose ODM

## Environment Variables

```env
# Server Configuration
PORT=3000
DB_URI=mongodb://localhost:27017/your_database
CORS_ORIGIN=*

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-in-production

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_SECRET_KEY=your_secret_key
```

## Firebase Setup

1. Create a Firebase project
2. Enable Authentication
3. Download service account key
4. Place it as `firebase-service-account.json` in the root directory
5. Configure Firebase in your Flutter app

## Error Handling

The API returns consistent error responses:

```json
{
  "statusCode": 400,
  "data": null,
  "message": "Validation failed",
  "success": false,
  "errors": ["Email is required", "Password must be at least 6 characters"]
}
```

## Common Error Codes
- **400**: Bad Request (validation errors)
- **401**: Unauthorized (invalid credentials/token)
- **403**: Forbidden (account locked/deactivated)
- **409**: Conflict (user already exists)
- **423**: Locked (account temporarily locked)
- **429**: Too Many Requests (rate limit exceeded)
- **500**: Internal Server Error

## Flutter Integration

For Flutter apps using Firebase Auth:

1. User authenticates with Firebase
2. Get Firebase ID token
3. Send token to `/api/v1/auth/firebase-auth`
4. Receive JWT tokens for API access
5. Use access token for subsequent API calls
6. Refresh token when access token expires

## Security Best Practices

1. **Always use HTTPS in production**
2. **Store JWT tokens securely in Flutter app**
3. **Implement proper token refresh logic**
4. **Validate all inputs on both client and server**
5. **Monitor for suspicious activities**
6. **Regularly rotate JWT secrets**
7. **Use environment variables for sensitive data**
8. **Implement proper logging and monitoring**

## Testing

Use tools like Postman or curl to test the endpoints:

```bash
# Register a new user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123","mobile":"9876543210"}'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## Deployment Considerations

1. **Environment Variables**: Set all required environment variables
2. **Database**: Ensure MongoDB is accessible
3. **Firebase**: Upload service account key securely
4. **HTTPS**: Use SSL certificates in production
5. **Rate Limiting**: Consider using Redis for distributed rate limiting
6. **Monitoring**: Implement logging and error tracking
7. **Backup**: Regular database backups
8. **Updates**: Keep dependencies updated for security patches