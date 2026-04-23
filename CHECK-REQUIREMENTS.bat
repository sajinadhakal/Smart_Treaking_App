@echo off
title Check Prerequisites - Nepal Trekking App
color 0B

echo =========================================
echo  Prerequisites Checker
echo  Nepal Trekking App - BCA Project
echo =========================================
echo.

echo Checking required software...
echo.

REM Check Python
echo [1/3] Checking Python...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    python --version
    echo [OK] Python is installed
) else (
    echo [FAIL] Python is NOT installed
    echo Please install Python 3.8+ from: https://www.python.org/downloads/
)
echo.

REM Check Flutter
echo [2/3] Checking Flutter...
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    flutter --version | findstr /C:"Flutter"
    echo [OK] Flutter is installed
) else (
    echo [FAIL] Flutter is NOT installed
    echo Please install Flutter from: https://docs.flutter.dev/get-started/install
)
echo.

REM Check Git (optional but helpful)
echo [3/3] Checking Git...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    git --version
    echo [OK] Git is installed
) else (
    echo [INFO] Git is not installed (optional)
)
echo.

echo =========================================
echo  Check Complete!
echo =========================================
echo.

REM Check if setup was run
if exist "Backend\venv\" (
    echo [OK] Backend virtual environment exists
) else (
    echo [PENDING] Backend setup not done yet
    echo Run START-APP.bat or setup.ps1 to continue
)
echo.

if exist "Backend\db.sqlite3" (
    echo [OK] Database exists
) else (
    echo [PENDING] Database not created yet
)
echo.

if exist "front_end\.dart_tool\" (
    echo [OK] Flutter dependencies installed
) else (
    echo [PENDING] Flutter setup not done yet
)
echo.

echo Press any key to exit...
pause >nul
