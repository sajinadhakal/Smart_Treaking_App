# ========================================
# Nepal Trekking App - One-Click Launcher
# Starts Backend and Frontend Automatically
# BCA 6th Semester Project
# ========================================

param(
    [switch]$setup = $false
)

function Get-PythonExecutable {
    $candidates = @(
        (Join-Path $PWD ".venv\Scripts\python.exe"),
        (Join-Path $PWD "Backend\venv\Scripts\python.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return "python"
}

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

    return '127.0.0.1'
}

Write-Host "=================================" -ForegroundColor Cyan
Write-Host " Nepal Trekking App Launcher" -ForegroundColor Cyan
Write-Host " BCA TU 6th Semester Project" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if running in correct directory
if (-not (Test-Path "Backend") -or -not (Test-Path "front_end")) {
    Write-Host "ERROR: Please run this script from C:\Users\sazna\6th_sem\" -ForegroundColor Red
    exit 1
}

# Function to check if setup was done
function Test-Setup {
    $backendReady = (Test-Path ".venv\Scripts\python.exe") -or (Test-Path "Backend\venv\Scripts\python.exe")
    $dbReady = Test-Path "Backend\db.sqlite3"
    $frontendReady = Test-Path "front_end\.dart_tool"
    
    return ($backendReady -and $dbReady -and $frontendReady)
}

# Run setup if needed or requested
if ($setup -or -not (Test-Setup)) {
    Write-Host "Running initial setup..." -ForegroundColor Yellow
    Write-Host ""
    & .\setup.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "Setup failed! Please fix errors and try again." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
    Write-Host "Setup completed successfully!" -ForegroundColor Green
    Write-Host ""
}

# Get current IP address
Write-Host "Detecting network configuration..." -ForegroundColor Yellow
$currentIP = Get-LanIp
if ($currentIP -eq '127.0.0.1') {
    Write-Host "Could not detect LAN IP, using localhost: $currentIP" -ForegroundColor Yellow
} else {
    Write-Host "Your IP Address: $currentIP" -ForegroundColor Cyan
}
Write-Host ""

$pythonExe = Get-PythonExecutable

Write-Host "=================================" -ForegroundColor Cyan
Write-Host " Starting Application" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Start Backend in new window
Write-Host "1. Starting Backend Server..." -ForegroundColor Green
$backendScript = @"
Set-Location '$PWD\Backend'
`$Host.UI.RawUI.WindowTitle = 'Backend Server - Nepal Trekking App'
Write-Host ''
Write-Host '=================================' -ForegroundColor Cyan
Write-Host ' Backend Server Running' -ForegroundColor Green
Write-Host '=================================' -ForegroundColor Cyan
Write-Host 'Server URL: http://${currentIP}:8000' -ForegroundColor Green
Write-Host 'Admin Panel: http://${currentIP}:8000/admin' -ForegroundColor Green
Write-Host 'API Docs: http://${currentIP}:8000/api/' -ForegroundColor Green
Write-Host ''
Write-Host 'Press Ctrl+C to stop the server' -ForegroundColor Yellow
Write-Host '=================================' -ForegroundColor Cyan
Write-Host ''
& '$pythonExe' manage.py runserver 0.0.0.0:8000
"@

$backendScriptFile = "Backend\run-server.ps1"
$backendScript | Out-File -FilePath $backendScriptFile -Encoding UTF8

Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "$PWD\$backendScriptFile"
Write-Host "   ✓ Backend server starting..." -ForegroundColor Green

# Wait for backend to start
Write-Host "   Waiting for backend to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Test backend connection
$maxRetries = 10
$retryCount = 0
$backendReady = $false

while (-not $backendReady -and $retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://${currentIP}:8000/api/" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
        }
    } catch {
        $retryCount++
        Start-Sleep -Seconds 1
    }
}

if ($backendReady) {
    Write-Host "   ✓ Backend is ready!" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Backend taking longer than expected..." -ForegroundColor Yellow
    Write-Host "   Continuing anyway..." -ForegroundColor Yellow
}

Write-Host ""

# Check for Flutter devices
Write-Host "2. Checking Flutter Devices..." -ForegroundColor Green
Set-Location front_end
$devices = flutter devices --machine 2>&1 | Out-String

if ($devices -match "\[\]" -or $devices -match "No devices") {
    Write-Host ""
    Write-Host "   ⚠ No devices detected!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Please connect a device:" -ForegroundColor White
    Write-Host "   • Connect phone via USB with USB debugging enabled" -ForegroundColor White
    Write-Host "   • Start an Android emulator" -ForegroundColor White
    Write-Host "   • Or use Chrome for web version" -ForegroundColor White
    Write-Host ""
    Write-Host "   Then run this script again" -ForegroundColor White
    Write-Host ""
    Set-Location ..
    exit 1
}

Write-Host "   ✓ Device(s) found!" -ForegroundColor Green

# Start Frontend in new window
Write-Host ""
Write-Host "3. Starting Flutter App..." -ForegroundColor Green

$frontendScriptFile = Join-Path $PWD "front_end\run-app.ps1"
Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $frontendScriptFile
Write-Host "   ✓ Flutter app starting..." -ForegroundColor Green

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host " Application Started!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Access Points:" -ForegroundColor Cyan
Write-Host "  Backend API:  http://${currentIP}:8000/api/" -ForegroundColor White
Write-Host "  Admin Panel:  http://${currentIP}:8000/admin" -ForegroundColor White
Write-Host "  Admin Login:  admin / (your password)" -ForegroundColor White
Write-Host ""

Write-Host "Important Notes:" -ForegroundColor Yellow
Write-Host "  • Two PowerShell windows opened (Backend & Frontend)" -ForegroundColor White
Write-Host "  • Close those windows to stop the application" -ForegroundColor White
Write-Host "  • Keep this window open to see status" -ForegroundColor White
Write-Host ""

Write-Host "Troubleshooting:" -ForegroundColor Cyan
Write-Host "  • Connection issues? Check firewall settings" -ForegroundColor White
Write-Host "  • App not connecting? Verify IP address: $currentIP" -ForegroundColor White
Write-Host "  • See TROUBLESHOOTING.md for more help" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit this launcher (servers keep running)..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
