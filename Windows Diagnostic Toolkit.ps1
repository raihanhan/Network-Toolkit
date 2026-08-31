if (-not (Test-Path ".\logs")) { New-Item -ItemType Directory -Path ".\logs" | Out-Null }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function New-LogPath($prefix) {
    $stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    return ".\logs\$($prefix)_$stamp.txt"
}

function Pause-Return {
    Write-Host "`nPress Enter to return to the menu..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}

function Require-Admin($featureName) {
    if (-not $isAdmin) {
        Write-Host "`n[!] '$featureName' requires Administrator privileges." -ForegroundColor Yellow
        Write-Host "    Close this window, then right-click the file -> Run with PowerShell as Administrator." -ForegroundColor Yellow
        return $false
    }
    return $true
}

# =====================================================================
#  1. NETWORK TOOLKIT
# =====================================================================
function Show-NetworkMenu {
    Clear-Host
    Write-Host "=========================================================="
    Write-Host "                    NETWORK TOOLKIT"
    Write-Host "=========================================================="
    if (-not $isAdmin) { Write-Host "[!] Not running as Administrator - some options may fail`n" -ForegroundColor Yellow }
    Write-Host " 1. Show Full IP Configuration"
    Write-Host " 2. Ping Google"
    Write-Host " 3. Flush DNS Cache"
    Write-Host " 4. Release IP Address        [Admin]"
    Write-Host " 5. Renew IP Address          [Admin]"
    Write-Host " 6. Reset Winsock             [Admin, confirmation required]"
    Write-Host " 7. Reset TCP/IP Stack        [Admin, confirmation required]"
    Write-Host " 8. Open Network Connections"
    Write-Host " 9. Open WiFi Settings"
    Write-Host "10. Open Device Manager"
    Write-Host "11. Open Network Troubleshooter"
    Write-Host "12. Speed Test Ping (Ctrl+C to stop)"
    Write-Host "13. Restart Explorer"
    Write-Host "14. Auto-Diagnostic Mode"
    Write-Host " 0. Back to Main Menu"
    Write-Host "=========================================================="
}

function Invoke-AutoDiagnostic {
    Clear-Host
    Write-Host "=========================================================="
    Write-Host "                  Auto-Diagnostic Mode"
    Write-Host "=========================================================="
    $log = New-LogPath "diagnostic"
    "Network Toolkit - Auto Diagnostic Report" | Out-File $log
    "Date/Time: $(Get-Date)" | Out-File $log -Append
    "" | Out-File $log -Append

    Write-Host "`n[1/3] Checking internet connectivity (IP-level, to 8.8.8.8)..."
    $ipOk = Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet
    if ($ipOk) {
        Write-Host "  Result: OK - IP-level internet connectivity is working" -ForegroundColor Green
        "[1/3] Internet (IP-level): OK" | Out-File $log -Append
    } else {
        Write-Host "  Result: FAILED - no internet connectivity" -ForegroundColor Red
        "[1/3] Internet (IP-level): FAILED" | Out-File $log -Append
    }

    Write-Host "`n[2/3] Checking DNS resolution (ping google.com)..."
    $dnsOk = $false
    if ($ipOk) {
        $dnsOk = Test-Connection -ComputerName google.com -Count 2 -Quiet -ErrorAction SilentlyContinue
        if ($dnsOk) {
            Write-Host "  Result: OK - DNS resolution is working normally" -ForegroundColor Green
            "[2/3] DNS Resolution: OK" | Out-File $log -Append
        } else {
            Write-Host "  Result: FAILED - trying DNS flush and re-checking..." -ForegroundColor Yellow
            ipconfig /flushdns | Out-Null
            $dnsOk = Test-Connection -ComputerName google.com -Count 2 -Quiet -ErrorAction SilentlyContinue
            if ($dnsOk) {
                Write-Host "  Result after DNS flush: OK - issue resolved" -ForegroundColor Green
                "[2/3] DNS Resolution: FAILED initially, OK after DNS flush" | Out-File $log -Append
            } else {
                Write-Host "  Result after DNS flush: still FAILED" -ForegroundColor Red
                "[2/3] DNS Resolution: FAILED" | Out-File $log -Append
            }
        }
    } else {
        Write-Host "  Skipped - no IP-level connectivity" -ForegroundColor DarkGray
        "[2/3] DNS Resolution: Skipped (no IP-level connectivity)" | Out-File $log -Append
    }

    Write-Host "`n[3/3] Checking connectivity to Default Gateway..."
    $gwOk = $false
    $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty NextHop)
    if ($gateway) {
        $gwOk = Test-Connection -ComputerName $gateway -Count 2 -Quiet -ErrorAction SilentlyContinue
        if ($gwOk) {
            Write-Host "  Result: OK - Gateway $gateway is reachable" -ForegroundColor Green
            "[3/3] Gateway ($gateway): OK" | Out-File $log -Append
        } else {
            Write-Host "  Result: FAILED - Gateway $gateway is not responding" -ForegroundColor Red
            "[3/3] Gateway ($gateway): FAILED" | Out-File $log -Append
        }
    } else {
        Write-Host "  Could not detect Default Gateway" -ForegroundColor DarkGray
        "[3/3] Gateway: Not detected" | Out-File $log -Append
    }

    Write-Host "`n=========================================================="
    Write-Host "                        Summary"
    Write-Host "=========================================================="
    if (-not $ipOk) {
        Write-Host "Likely cause: Network adapter down / cable-WiFi disconnected / ISP issue" -ForegroundColor Yellow
        Write-Host "Suggestion: Check physical/WiFi connection, or open Network Connections (option 8)"
        "Likely cause: Adapter/physical connection/ISP issue" | Out-File $log -Append
    } elseif (-not $dnsOk) {
        Write-Host "Likely cause: DNS server issue" -ForegroundColor Yellow
        Write-Host "Suggestion: Change DNS server (e.g. to 8.8.8.8 / 1.1.1.1) via option 8"
        "Likely cause: DNS server issue" | Out-File $log -Append
    } elseif (-not $gwOk) {
        Write-Host "Likely cause: Router/gateway issue" -ForegroundColor Yellow
        Write-Host "Suggestion: Restart the router, check the cable to the router"
        "Likely cause: Router/gateway issue" | Out-File $log -Append
    } else {
        Write-Host "All checks OK - network connection is in good condition" -ForegroundColor Green
        "Conclusion: All checks OK" | Out-File $log -Append
    }
    Write-Host "`nFull report saved to: $log"
}

function Invoke-NetworkMenu {
    do {
        Show-NetworkMenu
        $choice = Read-Host "`nSelect an option"
        switch ($choice) {
            '1' { ipconfig /all | Tee-Object -FilePath (New-LogPath "ipconfig") }
            '2' { ping google.com | Tee-Object -FilePath (New-LogPath "ping") }
            '3' { ipconfig /flushdns | Tee-Object -FilePath (New-LogPath "flushdns") }
            '4' { if (Require-Admin "Release IP") { ipconfig /release | Tee-Object -FilePath (New-LogPath "release") } }
            '5' { if (Require-Admin "Renew IP") { ipconfig /renew | Tee-Object -FilePath (New-LogPath "renew") } }
            '6' {
                Write-Host "`n[!] Resetting Winsock will reset all network provider configuration on this system." -ForegroundColor Yellow
                $sure = Read-Host "Are you sure you want to continue? (y/n)"
                if ($sure -eq 'y' -and (Require-Admin "Reset Winsock")) {
                    netsh winsock reset | Tee-Object -FilePath (New-LogPath "winsock")
                    Write-Host "`n[!] A restart is required for the changes to fully take effect." -ForegroundColor Yellow
                }
            }
            '7' {
                Write-Host "`n[!] Resetting the TCP/IP stack will restore network configuration to default." -ForegroundColor Yellow
                $sure = Read-Host "Are you sure you want to continue? (y/n)"
                if ($sure -eq 'y' -and (Require-Admin "Reset TCP/IP Stack")) {
                    netsh int ip reset | Tee-Object -FilePath (New-LogPath "tcpreset")
                    Write-Host "`n[!] A restart is required for the changes to fully take effect." -ForegroundColor Yellow
                }
            }
            '8' { Start-Process ncpa.cpl }
            '9' { Start-Process "ms-settings:network-wifi" }
            '10' { Start-Process devmgmt.msc }
            '11' { Start-Process "ms-settings:troubleshoot" }
            '12' { ping 8.8.8.8 -t }
            '13' { Stop-Process -Name explorer -Force; Start-Process explorer }
            '14' { Invoke-AutoDiagnostic }
            '0' { return }
            default { Write-Host "Invalid option." -ForegroundColor Red }
        }
        if ($choice -ne '0') { Pause-Return }
    } while ($choice -ne '0')
}

# =====================================================================
#  2. SYSTEM INTEGRITY TOOLKIT
# =====================================================================
function Show-IntegrityMenu {
    Clear-Host
    Write-Host "=========================================================="
    Write-Host "               SYSTEM INTEGRITY TOOLKIT"
    Write-Host "=========================================================="
    if (-not $isAdmin) { Write-Host "[!] Not running as Administrator - options 1-7 will fail`n" -ForegroundColor Yellow }
    Write-Host "1. SFC - Scan Now (check + repair system files)"
    Write-Host "2. SFC - Verify Only (no repair)"
    Write-Host "3. DISM - Check Health (quick check)"
    Write-Host "4. DISM - Scan Health (deep check)"
    Write-Host "5. DISM - Restore Health (repair component store)"
    Write-Host "6. Full Repair Sequence (DISM RestoreHealth then SFC Scannow)"
    Write-Host "7. CHKDSK - Schedule Check on Next Restart (C:)"
    Write-Host "8. View Last CBS Log (last 50 lines)"
    Write-Host "9. Open Reliability History (GUI)"
    Write-Host "0. Back to Main Menu"
    Write-Host "=========================================================="
}

function Invoke-IntegrityMenu {
    do {
        Show-IntegrityMenu
        $choice = Read-Host "`nSelect an option"
        switch ($choice) {
            '1' { if (Require-Admin "SFC Scannow") { Write-Host "`n(This process can take 10-20 minutes)`n"; sfc /scannow } }
            '2' { if (Require-Admin "SFC Verify") { sfc /verifyonly } }
            '3' { if (Require-Admin "DISM CheckHealth") { DISM /Online /Cleanup-Image /CheckHealth } }
            '4' { if (Require-Admin "DISM ScanHealth") { DISM /Online /Cleanup-Image /ScanHealth } }
            '5' { if (Require-Admin "DISM RestoreHealth") { DISM /Online /Cleanup-Image /RestoreHealth } }
            '6' {
                if (Require-Admin "Full Repair Sequence") {
                    Write-Host "`n=== STEP 1/2: DISM RestoreHealth ===" -ForegroundColor Cyan
                    DISM /Online /Cleanup-Image /RestoreHealth
                    Write-Host "`n=== STEP 2/2: SFC Scannow ===" -ForegroundColor Cyan
                    sfc /scannow
                    Write-Host "`nSequence complete." -ForegroundColor Green
                }
            }
            '7' {
                if (Require-Admin "CHKDSK") {
                    Write-Host "`nScheduling CHKDSK on drive C: for the next restart."
                    chkdsk C: /f /r
                }
            }
            '8' {
                Write-Host "`n--- Last 50 lines of CBS.log ---" -ForegroundColor Cyan
                Get-Content -Tail 50 "$env:windir\Logs\CBS\CBS.log" -ErrorAction SilentlyContinue
            }
            '9' {
                Write-Host "`nOpening Reliability History (Reliability Monitor)..."
                Start-Process perfmon /rel
            }
            '0' { return }
            default { Write-Host "Invalid option." -ForegroundColor Red }
        }
        if ($choice -ne '0') { Pause-Return }
    } while ($choice -ne '0')
}

# =====================================================================
#  3. HARDWARE TOOLKIT
# =====================================================================
function Show-HardwareMenu {
    Clear-Host
    Write-Host "=========================================================="
    Write-Host "                  HARDWARE DIAGNOSTIC TOOLKIT"
    Write-Host "=========================================================="
    Write-Host "1. CPU Info & Live Usage"
    Write-Host "2. RAM Info & Usage"
    Write-Host "3. Storage - Disk Health (S.M.A.R.T. status)"
    Write-Host "4. Storage - Disk Space Summary"
    Write-Host "5. Recent Hardware-Related Event Log Errors"
    Write-Host "6. Run Full System Report"
    Write-Host "7. Export Full Report to File"
    Write-Host "0. Back to Main Menu"
    Write-Host "=========================================================="
}

function Get-CpuInfo {
    Write-Host "`n--- CPU INFO ---" -ForegroundColor Cyan
    Get-CimInstance Win32_Processor |
        Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, LoadPercentage, Status |
        Format-List

    Write-Host "--- LIVE CPU USAGE (5 sec sample) ---" -ForegroundColor Cyan
    Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 5 |
        Select-Object -ExpandProperty CounterSamples |
        Select-Object Timestamp, CookedValue |
        Format-Table -AutoSize
}

function Get-RamInfo {
    Write-Host "`n--- RAM INFO ---" -ForegroundColor Cyan
    $os = Get-CimInstance Win32_OperatingSystem
    $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeGB  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedGB  = [math]::Round($totalGB - $freeGB, 2)
    $pctUsed = [math]::Round(($usedGB / $totalGB) * 100, 1)

    Write-Host ("Total RAM : {0} GB" -f $totalGB)
    Write-Host ("Used RAM  : {0} GB ({1}%)" -f $usedGB, $pctUsed)
    Write-Host ("Free RAM  : {0} GB" -f $freeGB)

    Write-Host "`n--- INSTALLED MEMORY MODULES ---" -ForegroundColor Cyan
    Get-CimInstance Win32_PhysicalMemory |
        Select-Object BankLabel, DeviceLocator, @{N='CapacityGB';E={[math]::Round($_.Capacity/1GB,2)}}, Speed, Manufacturer |
        Format-Table -AutoSize

    Write-Host "--- TOP MEMORY-CONSUMING PROCESSES ---" -ForegroundColor Cyan
    Get-Process | Sort-Object WS -Descending | Select-Object -First 5 |
        Select-Object Name, Id, @{N='MemoryMB';E={[math]::Round($_.WS/1MB,1)}} |
        Format-Table -AutoSize
}

function Get-StorageHealth {
    Write-Host "`n--- DISK HEALTH (S.M.A.R.T. STATUS) ---" -ForegroundColor Cyan
    try {
        Get-PhysicalDisk | Select-Object DeviceId, FriendlyName, MediaType, HealthStatus, OperationalStatus, Size |
            Format-Table -AutoSize

        Write-Host "--- RELIABILITY COUNTERS ---" -ForegroundColor Cyan
        Get-PhysicalDisk | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue |
            Select-Object DeviceId, Wear, Temperature, ReadErrorsTotal, WriteErrorsTotal |
            Format-Table -AutoSize
    } catch {
        Write-Host "Get-PhysicalDisk / Storage cmdlets unavailable. Falling back to basic status." -ForegroundColor Yellow
        Get-CimInstance Win32_DiskDrive | Select-Object DeviceID, Model, Status, Size | Format-Table -AutoSize
    }
}

function Get-DiskSpace {
    Write-Host "`n--- DISK SPACE SUMMARY ---" -ForegroundColor Cyan
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID, @{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}}, @{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,2)}}, @{N='PctFree';E={[math]::Round(($_.FreeSpace/$_.Size)*100,1)}} |
        Format-Table -AutoSize
}

function Get-HardwareEventErrors {
    Write-Host "`n--- RECENT HARDWARE-RELATED EVENT LOG ERRORS (last 7 days) ---" -ForegroundColor Cyan
    $since = (Get-Date).AddDays(-7)
    try {
        Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 1,2,3; StartTime = $since } -ErrorAction Stop |
        Where-Object { $_.ProviderName -match 'disk|storahci|Storage|Processor|Memory|WHEA|volmgr' } |
        Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message |
        Select-Object -First 20 |
        Format-Table -Wrap -AutoSize
    } catch {
        Write-Host "No matching events found or access denied (try running as Administrator)." -ForegroundColor Yellow
    }
}

function Get-FullHardwareReport {
    Get-CpuInfo; Get-RamInfo; Get-StorageHealth; Get-DiskSpace; Get-HardwareEventErrors
}

function Export-FullHardwareReport {
    $path = New-LogPath "HardwareReport"
    Get-FullHardwareReport 6>&1 | Out-File -FilePath $path -Encoding UTF8
    Write-Host "`nReport exported to: $path" -ForegroundColor Green
}

function Invoke-HardwareMenu {
    do {
        Show-HardwareMenu
        $choice = Read-Host "`nSelect an option"
        switch ($choice) {
            '1' { Get-CpuInfo }
            '2' { Get-RamInfo }
            '3' { Get-StorageHealth }
            '4' { Get-DiskSpace }
            '5' { Get-HardwareEventErrors }
            '6' { Get-FullHardwareReport }
            '7' { Export-FullHardwareReport }
            '0' { return }
            default { Write-Host "Invalid option." -ForegroundColor Red }
        }
        if ($choice -ne '0') { Pause-Return }
    } while ($choice -ne '0')
}

# =====================================================================
#  MAIN MENU
# =====================================================================
function Show-MainMenu {
    Clear-Host
    Write-Host "=========================================================="
    Write-Host "        WINDOWS TROUBLESHOOTING TOOLKIT"
    Write-Host "=========================================================="
    if (-not $isAdmin) {
        Write-Host "[!] Running WITHOUT Administrator privileges." -ForegroundColor Yellow
        Write-Host "    Some features (SFC/DISM/CHKDSK, adapter resets) require Admin.`n" -ForegroundColor Yellow
    } else {
        Write-Host "[OK] Running as Administrator.`n" -ForegroundColor Green
    }
    Write-Host "1. Network Toolkit"
    Write-Host "2. System Integrity Toolkit  (SFC / DISM / CHKDSK)"
    Write-Host "3. Hardware Toolkit          (CPU / RAM / Storage)"
    Write-Host "0. Exit"
    Write-Host "=========================================================="
}

do {
    Show-MainMenu
    $mainChoice = Read-Host "`nSelect a category"
    switch ($mainChoice) {
        '1' { Invoke-NetworkMenu }
        '2' { Invoke-IntegrityMenu }
        '3' { Invoke-HardwareMenu }
        '0' { Write-Host "`nThank you for using the All-in-One Toolkit." }
        default { Write-Host "Invalid option." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($mainChoice -ne '0')
