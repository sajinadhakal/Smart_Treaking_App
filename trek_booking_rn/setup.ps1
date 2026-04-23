# Nepal Trek Explorer - Setup Script
# Run this to install and start the app

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host "  Nepal Trek Explorer - BCA 6th Semester Project" -ForegroundColor Green
Write-Host "  Tribhuvan University" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

Write-Host "`n[1/4] Checking Node.js installation..." -ForegroundColor Cyan

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js installed: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found!" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n[2/4] Installing dependencies..." -ForegroundColor Cyan
Write-Host "This may take 2-3 minutes..." -ForegroundColor Yellow

# Install dependencies
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencies installed successfully!" -ForegroundColor Green
} else {
    Write-Host "✗ Installation failed!" -ForegroundColor Red
    Write-Host "Try running: npm install --legacy-peer-deps" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n[3/4] Project structure:" -ForegroundColor Cyan
Write-Host "  ├── App.js                   (Main app)" -ForegroundColor White
Write-Host "  ├── src/algorithms/          (7 algorithms)" -ForegroundColor White
Write-Host "  ├── src/screens/             (5 screens)" -ForegroundColor White
Write-Host "  ├── src/components/          (UI components)" -ForegroundColor White
Write-Host "  └── src/data/mockData.js     (8 sample treks)" -ForegroundColor White

Write-Host "`n[4/4] Ready to start!" -ForegroundColor Cyan
Write-Host "`nTo start the development server, run:" -ForegroundColor Yellow
Write-Host "  npx expo start" -ForegroundColor Green
Write-Host "`nOr simply:" -ForegroundColor Yellow
Write-Host "  npm start" -ForegroundColor Green

Write-Host "`n📱 How to run:" -ForegroundColor Cyan
Write-Host "  1. Install 'Expo Go' app on your phone" -ForegroundColor White
Write-Host "  2. Run: npm start" -ForegroundColor White
Write-Host "  3. Scan QR code with Expo Go" -ForegroundColor White
Write-Host "  4. App will open!" -ForegroundColor White

Write-Host "`n🎓 Features:" -ForegroundColor Cyan
Write-Host "  ✓ 7 Algorithms implemented with visualization" -ForegroundColor Green
Write-Host "  ✓ AI Trip Planner with recommendation engine" -ForegroundColor Green
Write-Host "  ✓ Educational mode for learning" -ForegroundColor Green
Write-Host "  ✓ Modern UI/UX design" -ForegroundColor Green
Write-Host "  ✓ Search, filter, sort functionality" -ForegroundColor Green

Write-Host "`n📚 Documentation:" -ForegroundColor Cyan
Write-Host "  README.md       - Full project documentation" -ForegroundColor White
Write-Host "  QUICKSTART.md   - Quick start guide" -ForegroundColor White

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host "  Setup Complete! Ready for your TU project 🎉" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

Write-Host "`nStart now? (Y/N): " -ForegroundColor Yellow -NoNewline
$response = Read-Host

if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host "`nStarting Expo development server...`n" -ForegroundColor Cyan
    npx expo start
} else {
    Write-Host "`nRun 'npm start' when you're ready!`n" -ForegroundColor Cyan
}
