# ========================================
# Run Flutter Frontend
# Nepal Trekking App - BCA Project
# ========================================

Write-Host "Starting Flutter App..." -ForegroundColor Green
Write-Host ""

function Get-LanIp {
    $ipLine = ipconfig |
        Select-String -Pattern 'IPv4[^:]*:\s*(\d+\.\d+\.\d+\.\d+)' |
        Select-Object -First 1

    if ($ipLine -and $ipLine.Matches.Count -gt 0) {
        return $ipLine.Matches[0].Groups[1].Value
    }

    return "127.0.0.1"
}

# Navigate to frontend
Set-Location front_end

# Check for connected devices
Write-Host "Checking for connected devices..." -ForegroundColor Yellow
$devices = flutter devices 2>&1

if ($devices -match "No devices detected") {
    Write-Host ""
    Write-Host "⚠ No devices detected!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Connect your phone via USB" -ForegroundColor White
    Write-Host "2. Enable USB Debugging on phone" -ForegroundColor White
    Write-Host "3. Accept debugging prompt on phone" -ForegroundColor White
    Write-Host "4. Run this script again" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host " Flutter App Starting" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Detected devices:" -ForegroundColor Green
Write-Host $devices -ForegroundColor White
Write-Host ""
Write-Host "Hot reload: Press 'r'" -ForegroundColor Yellow
Write-Host "Hot restart: Press 'R'" -ForegroundColor Yellow
Write-Host "Quit: Press 'q'" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Run Flutter
$lanIp = Get-LanIp
$apiBaseUrl = "http://${lanIp}:8000/api"

Write-Host "Using backend API: $apiBaseUrl" -ForegroundColor Green
Write-Host ""

flutter run --dart-define "API_BASE_URL=$apiBaseUrl"
