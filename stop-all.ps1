# ========================================
# Stop All Services
# Nepal Trekking App - BCA Project
# ========================================

Write-Host "=================================" -ForegroundColor Cyan
Write-Host " Stopping Nepal Trekking App" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Find and stop Django/Python processes on port 8000
Write-Host "Stopping Backend Server..." -ForegroundColor Yellow
$djangoProcesses = Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -like "*Backend*" -or
    $_.CommandLine -like "*manage.py*" -or
    $_.CommandLine -like "*runserver*"
}

if ($djangoProcesses) {
    $djangoProcesses | Stop-Process -Force
    Write-Host "  ✓ Backend server stopped" -ForegroundColor Green
} else {
    Write-Host "  No backend processes found" -ForegroundColor Gray
}

# Find and stop Flutter processes
Write-Host "Stopping Flutter App..." -ForegroundColor Yellow
$flutterProcesses = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -like "*flutter*" -or
    $_.MainWindowTitle -like "*Flutter*"
}

if ($flutterProcesses) {
    $flutterProcesses | Stop-Process -Force
    Write-Host "  ✓ Flutter app stopped" -ForegroundColor Green
} else {
    Write-Host "  No Flutter processes found" -ForegroundColor Gray
}

# Kill any remaining PowerShell windows with our scripts
$scriptProcesses = Get-Process powershell -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -like "*Backend Server*" -or
    $_.MainWindowTitle -like "*Flutter App*" -or
    $_.MainWindowTitle -like "*Nepal Trekking*"
}

if ($scriptProcesses) {
    $scriptProcesses | Stop-Process -Force
    Write-Host "  ✓ Script windows closed" -ForegroundColor Green
}

# Try to free up port 8000 if still occupied
Write-Host "Checking port 8000..." -ForegroundColor Yellow
$portProcess = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($portProcess) {
    $process = Get-Process -Id $portProcess.OwningProcess -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Id $process.Id -Force
        Write-Host "  ✓ Port 8000 freed" -ForegroundColor Green
    }
} else {
    Write-Host "  Port 8000 is free" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host " All Services Stopped" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now safely close this window or run the app again." -ForegroundColor White
Write-Host ""
