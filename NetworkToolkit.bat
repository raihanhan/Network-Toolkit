@echo off
title Network Toolkit
color 0A
:menu
cls
echo.
echo =========================================================================
echo                            Network Toolkit
echo =========================================================================
echo.
echo 1. Show Full IP Configuration
echo 2. Ping Google
echo 3. Flush DNS Cache
echo 4. Release IP Address
echo 5. Renew IP Address
echo 6. Reset Winsock
echo 7. Reset TCP/IP Stack
echo 8. Open Network Connections
echo 9. Open WiFi Settings
echo 10. Open Device Manager
echo 11. Open Network Troubleshooter
echo 12. Speed Test Ping
echo 13. Restart Explorer
echo 14. Exit
echo.
set /p choice=Enter Option: 
if "%choice%"=="1" ipconfig /all
if "%choice%"=="2" ping google.com
if "%choice%"=="3" ipconfig /flushdns
if "%choice%"=="4" ipconfig /release
if "%choice%"=="5" ipconfig /renew
if "%choice%"=="6" netsh winsock reset
if "%choice%"=="7" netsh int ip reset
if "%choice%"=="8" start ncpa.cpl
if "%choice%"=="9" start ms-settings:network-wifi
if "%choice%"=="10" start devmgmt.msc
if "%choice%"=="11" start ms-settings:troubleshoot
if "%choice%"=="12" ping 8.8.8.8 -t
if "%choice%"=="13" (
    taskkill /f /im explorer.exe
    start explorer.exe
)
if "%choice%"=="14" exit
pause
goto menu
 