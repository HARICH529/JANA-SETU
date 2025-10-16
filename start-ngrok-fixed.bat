@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "start-ngrok-fixed.ps1"
pause