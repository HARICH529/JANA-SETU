Write-Host "========================================" -ForegroundColor Green
Write-Host "Starting Ngrok and Updating API URLs" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Kill existing ngrok processes
Write-Host "Killing existing ngrok processes..." -ForegroundColor Yellow
Get-Process -Name "ngrok" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start ngrok in background
Write-Host "Starting ngrok tunnel..." -ForegroundColor Yellow
Start-Process -FilePath "ngrok" -ArgumentList "http", "3000" -WindowStyle Hidden

# Wait for ngrok to start
Start-Sleep -Seconds 5

# Get ngrok URL
Write-Host "Fetching ngrok URL..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get
    $ngrokUrl = $response.tunnels | Where-Object { $_.proto -eq "https" } | Select-Object -First 1 -ExpandProperty public_url
    
    if (-not $ngrokUrl) {
        throw "No HTTPS tunnel found"
    }
    
    Write-Host "Ngrok URL: $ngrokUrl" -ForegroundColor Green
    
    # Update Mobile App API Config
    Write-Host "Updating mobile app API configuration..." -ForegroundColor Yellow
    $mobileConfigPath = "civic_reporter\lib\api\api_config.dart"
    if (Test-Path $mobileConfigPath) {
        $content = Get-Content $mobileConfigPath -Raw
        $content = $content -replace "static const String baseUrl = 'https://.*\.ngrok-free\.app/api/v1';", "static const String baseUrl = '$ngrokUrl/api/v1';"
        Set-Content $mobileConfigPath -Value $content
        Write-Host "✓ Mobile config updated" -ForegroundColor Green
    } else {
        Write-Host "✗ Mobile config file not found" -ForegroundColor Red
    }
    
    # Update Admin Dashboard .env file
    Write-Host "Updating admin dashboard configuration..." -ForegroundColor Yellow
    $adminEnvPath = "admin-vite\.env"
    "VITE_API_URL=$ngrokUrl/api/v1" | Set-Content $adminEnvPath
    Write-Host "✓ Admin config updated" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Configuration Updated Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Ngrok URL: $ngrokUrl" -ForegroundColor Cyan
    Write-Host "Mobile API: $ngrokUrl/api/v1" -ForegroundColor Cyan
    Write-Host "Admin API: $ngrokUrl/api/v1" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Make sure your backend server is running on port 3000"
    Write-Host "2. Restart your mobile app to use the new API URL"
    Write-Host "3. Restart your admin dashboard (npm run dev)"
    Write-Host ""
    
    # Open ngrok dashboard
    Start-Process "http://localhost:4040"
    
    Write-Host "Ngrok dashboard opened. Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host "ERROR: Could not get ngrok URL. Make sure ngrok is installed and running." -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}