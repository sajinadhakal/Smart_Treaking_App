@echo off
title Stop Nepal Trekking App
color 0C

echo =========================================
echo  Stopping Nepal Trekking App
echo =========================================
echo.

echo Closing all app processes...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0stop-all.ps1"

echo.
echo All services stopped!
echo.
pause
