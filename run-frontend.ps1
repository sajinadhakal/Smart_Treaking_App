# ========================================
# Run Flutter Frontend
# Nepal Trekking App - BCA Project
# ========================================

Write-Host "Starting Flutter App..." -ForegroundColor Green
Write-Host ""

function Get-LanIp {
    if (Get-Command Get-NetIPAddress -ErrorAction SilentlyContinue) {
        $ip = Get-NetIPAddress -AddressFamily IPv4 |
            Where-Object { $_.IPAddress -notmatch '^(127|169)\.' } |
            Select-Object -First 1 -ExpandProperty IPAddress
        if ($ip) {
            return $ip
        }
    }

    $ip = ipconfig |
        Select-String -Pattern '\d{1,3}(?:\.\d{1,3}){3}' |
        ForEach-Object { $_.Matches } |
        ForEach-Object { $_.Value } |
        Where-Object { $_ -notmatch '^(127|169)\.' } |
        Select-Object -First 1

    if ($ip) {
        return $ip
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

$lanIp = Get-LanIp
$apiBaseUrl = "http://${lanIp}:8000/api"

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host " Flutter App Starting" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Detected devices:" -ForegroundColor Green
Write-Host $devices -ForegroundColor White
Write-Host ""
Write-Host "Using backend API: $apiBaseUrl" -ForegroundColor Green
Write-Host ""

flutter run --dart-define "API_BASE_URL=$apiBaseUrl"
