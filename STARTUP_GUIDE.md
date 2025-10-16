# Quick Startup Guide

## Step 1: Start Backend Server

Open a new terminal/command prompt and run:

```bash
cd backend-server
npm install
node scripts/createAdmin.js
npm start
```

Or use the batch file:
```bash
start-backend.bat
```

**Admin Credentials:**
- Email: `hari@gmail.com`
- Password: `hari1234`

## Step 2: Start Frontend (Admin Dashboard)

In another terminal:

```bash
cd Admin
npm start
```

## Step 3: Access Dashboard

1. Open browser: `http://localhost:3000` (React App)
2. Login with admin credentials above
3. Backend API runs on: `http://localhost:3000/api/v1`

## Troubleshooting

### Backend Issues:
- Ensure MongoDB connection is working
- Check if port 3000 is available
- Verify .env file has correct DB_URI

### Frontend Issues:
- Restart React app after backend is running
- Clear browser cache if needed
- Check console for specific errors

## API Endpoints Available:
- `POST /api/v1/admin/login` - Admin login
- `GET /api/v1/admin/get-all-reports` - Get all reports
- `PATCH /api/v1/admin/update-report-acknowledge/:id` - Acknowledge report