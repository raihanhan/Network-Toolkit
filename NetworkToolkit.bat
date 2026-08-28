@echo off
setlocal enabledelayedexpansion
title Network Toolkit v2.0
color 0A

:: === Setup awal ===
if not exist logs mkdir logs

:: Cek apakah dijalankan sebagai Administrator
net session >nul 2>&1
if %errorlevel%==0 (
    set isAdmin=1
) else (
    set isAdmin=0
)

:menu
cls
echo.
echo =========================================================================
echo                            Network Toolkit v2.0
echo =========================================================================
if %isAdmin%==0 (
    echo  [!] Tidak berjalan sebagai Administrator - opsi 4-7 mungkin gagal
    echo.
)
echo 1.  Show Full IP Configuration
echo 2.  Ping Google
echo 3.  Flush DNS Cache
echo 4.  Release IP Address        [Admin]
echo 5.  Renew IP Address          [Admin]
echo 6.  Reset Winsock             [Admin, butuh konfirmasi]
echo 7.  Reset TCP/IP Stack        [Admin, butuh konfirmasi]
echo 8.  Open Network Connections
echo 9.  Open WiFi Settings
echo 10. Open Device Manager
echo 11. Open Network Troubleshooter
echo 12. Speed Test Ping
echo 13. Restart Explorer
echo 14. Auto-Diagnostic Mode      
echo 15. Exit
echo.
set "choice="
set /p choice=Enter Option (1-15): 

:: === Buat nama file log yang locale-independent (pakai wmic) ===
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| findstr "="') do set dt=%%I
set "logstamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%-%dt:~10,2%-%dt:~12,2%"
set "logfile=logs\log_%logstamp%.txt"

if "%choice%"=="1" (
    ipconfig /all > "%logfile%" 2>&1
    type "%logfile%"
) else if "%choice%"=="2" (
    ping google.com > "%logfile%" 2>&1
    type "%logfile%"
) else if "%choice%"=="3" (
    ipconfig /flushdns > "%logfile%" 2>&1
    type "%logfile%"
) else if "%choice%"=="4" (
    call :confirmAdmin
    if !proceed!==1 (
        ipconfig /release > "%logfile%" 2>&1
        type "%logfile%"
    )
) else if "%choice%"=="5" (
    call :confirmAdmin
    if !proceed!==1 (
        ipconfig /renew > "%logfile%" 2>&1
        type "%logfile%"
    )
) else if "%choice%"=="6" (
    call :confirmRisky "Reset Winsock akan mereset semua konfigurasi network provider di sistem ini."
    if !proceed!==1 (
        netsh winsock reset > "%logfile%" 2>&1
        type "%logfile%"
        echo.
        echo [!] Restart komputer diperlukan agar perubahan diterapkan penuh.
    )
) else if "%choice%"=="7" (
    call :confirmRisky "Reset TCP/IP Stack akan mengembalikan konfigurasi jaringan ke default."
    if !proceed!==1 (
        netsh int ip reset > "%logfile%" 2>&1
        type "%logfile%"
        echo.
        echo [!] Restart komputer diperlukan agar perubahan diterapkan penuh.
    )
) else if "%choice%"=="8" (
    start ncpa.cpl
) else if "%choice%"=="9" (
    start ms-settings:network-wifi
) else if "%choice%"=="10" (
    start devmgmt.msc
) else if "%choice%"=="11" (
    start ms-settings:troubleshoot
) else if "%choice%"=="12" (
    ping 8.8.8.8 -t
) else if "%choice%"=="13" (
    taskkill /f /im explorer.exe
    start explorer.exe
) else if "%choice%"=="14" (
    call :autoDiagnostic
) else if "%choice%"=="15" (
    echo.
    echo Terima kasih telah menggunakan Network Toolkit.
    exit /b
) else (
    echo.
    echo [!] Pilihan tidak valid. Masukkan angka 1-15.
)

echo.
pause
goto menu

:: =========================================================================
:: Fungsi: konfirmasi hak akses Administrator
:: =========================================================================
:confirmAdmin
if %isAdmin%==0 (
    echo.
    echo [!] Perintah ini membutuhkan hak akses Administrator.
    echo     Jalankan ulang network-toolkit.bat dengan klik kanan -^> Run as Administrator.
    set proceed=0
    goto :eof
)
set proceed=1
goto :eof

:: =========================================================================
:: Fungsi: konfirmasi y/n untuk perintah berisiko + cek admin
:: =========================================================================
:confirmRisky
echo.
echo [!] %~1
set /p sure=Yakin ingin lanjut? (y/n): 
if /i "%sure%"=="y" (
    call :confirmAdmin
) else (
    echo Dibatalkan oleh pengguna.
    set proceed=0
)
goto :eof

:: =========================================================================
:: Fungsi: Auto-Diagnostic Mode
:: Menjalankan 3 pengecekan berurutan: konektivitas internet (IP-level),
:: resolusi DNS, dan konektivitas ke default gateway. Hasilnya dicatat
:: ke file laporan dan diberi kesimpulan penyebab yang paling mungkin.
:: =========================================================================
:autoDiagnostic
cls
echo.
echo =========================================================================
echo                       Auto-Diagnostic Mode
echo =========================================================================
echo.
set "diagfile=logs\diagnostic_%logstamp%.txt"
echo Network Toolkit - Auto Diagnostic Report> "%diagfile%"
echo Tanggal/Waktu: %date% %time%>> "%diagfile%"
echo.>> "%diagfile%"

echo [1/3] Mengecek konektivitas internet (IP-level, ke 8.8.8.8)...
ping -n 2 8.8.8.8 >nul 2>&1
if !errorlevel!==0 (
    echo   Hasil: OK - koneksi internet IP-level berjalan
    echo [1/3] Internet ^(IP-level^): OK>> "%diagfile%"
    set ipOk=1
) else (
    echo   Hasil: GAGAL - tidak ada koneksi ke internet
    echo [1/3] Internet ^(IP-level^): GAGAL>> "%diagfile%"
    set ipOk=0
)

echo.
echo [2/3] Mengecek resolusi DNS (ping ke google.com)...
set dnsOk=0
if !ipOk!==1 (
    ping -n 2 google.com >nul 2>&1
    if !errorlevel!==0 (
        echo   Hasil: OK - DNS resolusi berjalan normal
        echo [2/3] DNS Resolution: OK>> "%diagfile%"
        set dnsOk=1
    ) else (
        echo   Hasil: GAGAL - mencoba flush DNS dan cek ulang...
        ipconfig /flushdns >nul 2>&1
        ping -n 2 google.com >nul 2>&1
        if !errorlevel!==0 (
            echo   Hasil setelah flush DNS: OK - masalah teratasi
            echo [2/3] DNS Resolution: GAGAL awalnya, OK setelah flush DNS>> "%diagfile%"
            set dnsOk=1
        ) else (
            echo   Hasil setelah flush DNS: masih GAGAL
            echo [2/3] DNS Resolution: GAGAL>> "%diagfile%"
        )
    )
) else (
    echo   Dilewati - tidak ada koneksi IP-level
    echo [2/3] DNS Resolution: Dilewati ^(tidak ada koneksi IP-level^)>> "%diagfile%"
)

echo.
echo [3/3] Mengecek konektivitas ke Default Gateway...
set "gateway="
for /f "tokens=2 delims=:" %%g in ('ipconfig ^| findstr /i "Default Gateway"') do (
    if not defined gateway (
        set "gw=%%g"
        set "gw=!gw: =!"
        if not "!gw!"=="" set "gateway=!gw!"
    )
)
set gwOk=0
if defined gateway (
    ping -n 2 !gateway! >nul 2>&1
    if !errorlevel!==0 (
        echo   Hasil: OK - Gateway !gateway! dapat dijangkau
        echo [3/3] Gateway ^(!gateway!^): OK>> "%diagfile%"
        set gwOk=1
    ) else (
        echo   Hasil: GAGAL - Gateway !gateway! tidak merespon
        echo [3/3] Gateway ^(!gateway!^): GAGAL>> "%diagfile%"
    )
) else (
    echo   Tidak dapat mendeteksi Default Gateway
    echo [3/3] Gateway: Tidak terdeteksi>> "%diagfile%"
)

echo.
echo =========================================================================
echo                              Ringkasan
echo =========================================================================
if !ipOk!==0 (
    echo Kemungkinan penyebab: Adapter jaringan mati / kabel-WiFi terputus / masalah ISP
    echo Saran: Cek koneksi fisik/WiFi, atau coba opsi 8 ^(Network Connections^)
    echo Kemungkinan penyebab: Adapter/koneksi fisik/ISP bermasalah>> "%diagfile%"
) else if !dnsOk!==0 (
    echo Kemungkinan penyebab: Masalah DNS server
    echo Saran: Ganti DNS server ^(misal ke 8.8.8.8 / 1.1.1.1^) via opsi 8
    echo Kemungkinan penyebab: DNS server bermasalah>> "%diagfile%"
) else if !gwOk!==0 (
    echo Kemungkinan penyebab: Router/gateway bermasalah
    echo Saran: Restart router, cek kabel ke router
    echo Kemungkinan penyebab: Router/gateway bermasalah>> "%diagfile%"
) else (
    echo Semua pengecekan OK - koneksi jaringan dalam kondisi baik
    echo Kesimpulan: Semua pengecekan OK>> "%diagfile%"
)
echo.
echo Laporan lengkap disimpan di: %diagfile%
goto :eof