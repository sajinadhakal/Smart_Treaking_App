@echo off
title Nepal Trekking App Launcher
color 0A

echo =========================================
echo  Nepal Trekking App - One-Click Launcher
echo  BCA 6th Semester Project
echo =========================================
echo.

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0run-all.ps1"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to start the application
    echo Check the messages above for details
    pause
)
