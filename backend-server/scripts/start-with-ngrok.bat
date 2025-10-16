@echo off
echo Starting server with ngrok tunnel...

REM Start the server in background
start /B npm run dev

REM Wait for server to start
timeout /t 3 /nobreak > nul

REM Start ngrok tunnel
echo Creating ngrok tunnel...
ngrok http 3000

pause