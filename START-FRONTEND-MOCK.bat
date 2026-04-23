@echo off
REM Quick start batch file for Flutter frontend in MOCK MODE
REM No backend needed!

echo ============================================
echo   Flutter Frontend - Mock Mode Launcher
echo ============================================
echo.

cd front_end

echo Checking Flutter installation...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter not found!
    echo Please install Flutter first: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo.
echo Getting Flutter dependencies...
call flutter pub get

echo.
echo ============================================
echo   MOCK MODE IS ACTIVE
echo ============================================
echo.
echo   * Backend NOT required
echo   * Any login credentials work
echo   * Sample data preloaded
echo.
echo Login with any username/password, e.g.:
echo   Username: demo
echo   Password: test
echo.
echo ============================================
echo.

echo Available devices:
call flutter devices

echo.
echo Starting Flutter app...
echo.

call flutter run

pause
