# ========================================
# Run Backend Server
# Nepal Trekking App - BCA Project
# ========================================

Write-Host "Starting Backend Server..." -ForegroundColor Green
Write-Host ""

# Resolve workspace root and Python executable
$workspaceRoot = (Get-Location).Path

function Get-PythonExecutable {
    $candidates = @(
        (Join-Path $workspaceRoot ".venv\Scripts\python.exe"),
        (Join-Path $workspaceRoot "Backend\venv\Scripts\python.exe")
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

    return "127.0.0.1"
}

$pythonExe = Get-PythonExecutable
$currentIP = Get-LanIp

# Navigate to backend
Set-Location Backend

Write-Host "Using Python: $pythonExe" -ForegroundColor Yellow

# Check database
if (-not (Test-Path "db.sqlite3")) {
    Write-Host "Database not found! Running migrations..." -ForegroundColor Yellow
    & $pythonExe manage.py migrate
}

# Start server
Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host " Backend Server Starting" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Server URL: http://${currentIP}:8000" -ForegroundColor Green
Write-Host "Admin Panel: http://${currentIP}:8000/admin" -ForegroundColor Green
Write-Host "API Docs: http://${currentIP}:8000/api/" -ForegroundColor Green
Write-Host "Bind Address: 0.0.0.0:8000 (accessible from phone on same WiFi)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Run Django server
& $pythonExe manage.py runserver "0.0.0.0:8000"
