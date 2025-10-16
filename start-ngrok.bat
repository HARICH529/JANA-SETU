@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "start-ngrok-update.ps1"
pause