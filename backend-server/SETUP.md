# Setup Instructions

## Prerequisites
- Node.js (v16 or higher)
- MongoDB (local or cloud)
- Firebase project with Authentication enabled

## Installation Steps

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Environment Configuration**
   - Copy `.env.example` to `.env`
   - Update the following variables:
     ```env
     PORT=3000
     DB_URI=your_mongodb_connection_string
     JWT_SECRET=your_jwt_secret_key
     JWT_REFRESH_SECRET=your_refresh_secret_key
     CORS_ORIGIN=*
     ```

3. **Firebase Setup**
   - Download Firebase service account key from Firebase Console
   - Save it as `firebase-service-account.json` in the root directory
   - **Important**: Add this file to `.gitignore` for security

4. **Start the Server**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

5. **Verify Installation**
   - Visit `http://localhost:3000/health`
   - Should return server status

## Quick Test

Test the authentication endpoints:

```bash
# Register a user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com", 
    "password": "password123",
    "mobile": "9876543210"
  }'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## Security Checklist

- [ ] JWT secrets are strong and unique
- [ ] Firebase service account key is secure
- [ ] Database connection is encrypted
- [ ] CORS is properly configured
- [ ] Rate limiting is enabled
- [ ] Input validation is working
- [ ] Error handling is comprehensive

## Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Check DB_URI in .env file
   - Ensure MongoDB is running
   - Verify network connectivity

2. **Firebase Authentication Error**
   - Verify firebase-service-account.json exists
   - Check Firebase project configuration
   - Ensure Firebase Auth is enabled

3. **JWT Token Error**
   - Verify JWT_SECRET and JWT_REFRESH_SECRET are set
   - Check token format in Authorization header

4. **Rate Limiting Issues**
   - Clear browser cache
   - Wait for rate limit window to reset
   - Check IP address restrictions

### Logs
Check console output for detailed error messages and debugging information.