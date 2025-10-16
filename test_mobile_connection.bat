@echo off
echo ========================================
echo Testing Mobile App Connection to Backend
echo ========================================
echo.
echo Backend Server: http://192.168.29.244:3000
echo.
echo Test Credentials:
echo Email: mobiletest@example.com
echo Password: mobile123
echo.
echo Testing connection...
curl -X POST http://192.168.29.244:3000/api/v1/auth/login -H "Content-Type: application/json" -d "{\"email\":\"mobiletest@example.com\",\"password\":\"mobile123\"}"
echo.
echo.
echo ========================================
echo If you see success:true above, the backend is working!
echo Use these credentials in your mobile app:
echo Email: mobiletest@example.com
echo Password: mobile123
echo ========================================
pause