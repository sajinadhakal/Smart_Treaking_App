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
    $ipLine = ipconfig |
        Select-String -Pattern 'IPv4[^:]*:\s*(\d+\.\d+\.\d+\.\d+)' |
        Select-Object -First 1

    if ($ipLine -and $ipLine.Matches.Count -gt 0) {
        return $ipLine.Matches[0].Groups[1].Value
    }

    return "127.0.0.1"
}

function Sync-FrontendApiIp {
    param(
        [string]$ipAddress
    )

    $apiConfigPath = Join-Path $workspaceRoot "front_end\lib\config\api_config.dart"
    if (-not (Test-Path $apiConfigPath)) {
        return
    }

    $content = Get-Content $apiConfigPath -Raw
    $updated = [regex]::Replace(
        $content,
        "static const String _deviceLocalIp = '[^']+';",
        "static const String _deviceLocalIp = '$ipAddress';"
    )

    if ($updated -ne $content) {
        Set-Content -Path $apiConfigPath -Value $updated -NoNewline
        Write-Host "Synced Flutter API IP to $ipAddress in front_end/lib/config/api_config.dart" -ForegroundColor DarkGray
    }
}

$pythonExe = Get-PythonExecutable
$currentIP = Get-LanIp
Sync-FrontendApiIp -ipAddress $currentIP

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
