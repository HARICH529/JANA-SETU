@echo off
echo ========================================
echo Starting Complete SIH Project (Fresh ML Models)
echo ========================================

echo Setting environment variables to force fresh ML model downloads...
set HF_HUB_DISABLE_SYMLINKS_WARNING=1
set TRANSFORMERS_OFFLINE=0
set HF_HUB_CACHE=%TEMP%\hf_cache_fresh_%RANDOM%
set TORCH_HOME=%TEMP%\torch_cache_fresh_%RANDOM%
set TRANSFORMERS_CACHE=%TEMP%\transformers_cache_fresh_%RANDOM%

echo Starting Redis Server (if available)...
start "Redis Server" redis-server 2>nul

echo Starting MongoDB (if available)...
start "MongoDB" mongod 2>nul

timeout /t 3

echo ========================================
echo 1. Starting ML Service (Fresh Models)
echo ========================================
cd /d "c:\Users\harik\OneDrive\Desktop\SIH\backend-server\ml-service"
start "ML Service" python app.py
start "ML Worker" python worker.py

timeout /t 5

echo ========================================
echo 2. Starting Backend Server
echo ========================================
cd /d "c:\Users\harik\OneDrive\Desktop\SIH\backend-server"
start "Backend Server" npm run dev

timeout /t 5

echo ========================================
echo 3. Starting Admin Panel
echo ========================================
cd /d "c:\Users\harik\OneDrive\Desktop\SIH\admin-vite"
start "Admin Panel" npm run dev

echo ========================================
echo All services started!
echo ========================================
echo ML Service: http://localhost:8000
echo Backend API: http://localhost:3000
echo Admin Panel: http://localhost:5173
echo ========================================
echo ML models will be downloaded fresh on first use
echo Check individual windows for service status
echo ========================================
pause