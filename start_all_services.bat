@echo off
echo ========================================
echo Starting All SIH Project Services
echo ========================================

echo 1. Starting Backend Server...
cd /d "c:\Users\harik\OneDrive\Desktop\SIH\backend-server"
start "Backend Server" cmd /k "npm run dev"

timeout /t 3

echo 2. Starting Admin Panel...
cd /d "c:\Users\harik\OneDrive\Desktop\SIH\admin-vite"
start "Admin Panel" cmd /k "npm run dev"

echo ========================================
echo Services Started!
echo ========================================
echo Backend API: http://localhost:3000
echo Admin Panel: http://localhost:5173
echo ML Service: http://localhost:8000 (if running)
echo ========================================
echo Check individual windows for service status
pause