@echo off
echo ========================================
echo Starting Ngrok and Updating API URLs
echo ========================================

:: Kill any existing ngrok processes
echo Killing existing ngrok processes...
taskkill /f /im ngrok.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: Start ngrok in background and capture URL
echo Starting ngrok tunnel...
start /b ngrok http 3000 --log=stdout > ngrok_output.txt

:: Wait for ngrok to start
timeout /t 5 /nobreak >nul

:: Get the ngrok URL using curl
echo Fetching ngrok URL...
for /f "tokens=*" %%i in ('curl -s http://localhost:4040/api/tunnels ^| findstr "https://.*\.ngrok-free\.app"') do (
    set "ngrok_line=%%i"
)

:: Extract the URL from the JSON response
for /f "tokens=2 delims=:" %%a in ('echo %ngrok_line% ^| findstr "public_url"') do (
    set "ngrok_url=%%a"
)

:: Clean up the URL (remove quotes and comma)
set "ngrok_url=%ngrok_url:"=%"
set "ngrok_url=%ngrok_url:,=%"
set "ngrok_url=%ngrok_url: =%"

if "%ngrok_url%"=="" (
    echo ERROR: Could not get ngrok URL. Make sure ngrok is installed and running.
    pause
    exit /b 1
)

echo Ngrok URL: %ngrok_url%

:: Update Mobile App API Config
echo Updating mobile app API configuration...
powershell -Command "(Get-Content 'civic_reporter\lib\api\api_config.dart') -replace 'static const String baseUrl = ''https://.*\.ngrok-free\.app/api/v1'';', 'static const String baseUrl = ''%ngrok_url%/api/v1'';' | Set-Content 'civic_reporter\lib\api\api_config.dart'"

:: Update Admin Dashboard .env file
echo Updating admin dashboard configuration...
echo VITE_API_URL=%ngrok_url%/api/v1 > admin-vite\.env

:: Display updated configurations
echo.
echo ========================================
echo Configuration Updated Successfully!
echo ========================================
echo Ngrok URL: %ngrok_url%
echo Mobile API: %ngrok_url%/api/v1
echo Admin API: %ngrok_url%/api/v1
echo ========================================
echo.
echo Next steps:
echo 1. Make sure your backend server is running on port 3000
echo 2. Restart your mobile app to use the new API URL
echo 3. Restart your admin dashboard (npm run dev)
echo.
echo Press any key to open ngrok dashboard...
pause >nul
start http://localhost:4040

:: Keep the window open
echo.
echo Ngrok is running. Press Ctrl+C to stop.
pause >nul