#!/usr/bin/env pwsh
# Quick start script for Flutter frontend in MOCK MODE
# No backend needed!

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Flutter Frontend - Mock Mode Launcher" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to frontend directory
Set-Location -Path "$PSScriptRoot\front_end"

Write-Host "✓ Working directory: front_end" -ForegroundColor Green
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✓ Flutter found: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter not found! Please install Flutter first." -ForegroundColor Red
    Write-Host "  Download from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MOCK MODE IS ACTIVE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  • Backend NOT required ✓" -ForegroundColor Green
Write-Host "  • Any login credentials work ✓" -ForegroundColor Green
Write-Host "  • Sample data preloaded ✓" -ForegroundColor Green
Write-Host ""
Write-Host "Login with any username/password, e.g.:" -ForegroundColor Yellow
Write-Host "  Username: demo" -ForegroundColor White
Write-Host "  Password: test" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# List available devices
Write-Host "Available devices:" -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "Starting Flutter app..." -ForegroundColor Yellow
Write-Host ""

# Run the app
flutter run
