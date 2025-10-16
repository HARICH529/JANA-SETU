Write-Host "Killing existing ngrok processes..." -ForegroundColor Yellow
Get-Process -Name "ngrok" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "Starting ngrok tunnel..." -ForegroundColor Yellow
Start-Process -FilePath "ngrok" -ArgumentList "http", "3000" -WindowStyle Hidden

Write-Host "Waiting for ngrok to start..." -ForegroundColor Yellow
for ($i = 1; $i -le 10; $i++) {
    Start-Sleep -Seconds 2
    try {
        $test = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get -TimeoutSec 3
        Write-Host "Ngrok is ready!" -ForegroundColor Green
        break
    } catch {
        Write-Host "Waiting... ($i/10)" -ForegroundColor Yellow
        if ($i -eq 10) {
            throw "Ngrok failed to start after 20 seconds"
        }
    }
}

Write-Host "Fetching ngrok URL..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -Method Get
    $ngrokUrl = $response.tunnels | Where-Object { $_.proto -eq "https" } | Select-Object -First 1 -ExpandProperty public_url
    
    if (-not $ngrokUrl) {
        throw "No HTTPS tunnel found"
    }
    
    Write-Host "Ngrok URL: $ngrokUrl" -ForegroundColor Green
    
    # Update Mobile App
    $mobileConfigPath = "civic_reporter\lib\api\api_config.dart"
    if (Test-Path $mobileConfigPath) {
        $content = Get-Content $mobileConfigPath -Raw
        $content = $content -replace "static const String baseUrl = 'https://.*\.ngrok-free\.app/api/v1';", "static const String baseUrl = '$ngrokUrl/api/v1';"
        Set-Content $mobileConfigPath -Value $content
        Write-Host "Mobile config updated" -ForegroundColor Green
    }
    
    # Update Admin Dashboard
    "VITE_API_URL=$ngrokUrl/api/v1" | Set-Content "admin-vite\.env"
    Write-Host "Admin config updated" -ForegroundColor Green
    
    Write-Host "Configuration Updated Successfully!" -ForegroundColor Green
    Write-Host "Ngrok URL: $ngrokUrl" -ForegroundColor Cyan
    
    Start-Process "http://localhost:4040"
    Read-Host "Press Enter to exit"
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}