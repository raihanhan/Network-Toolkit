## Windows Diagnostics Toolkit

A single menu-driven PowerShell script for diagnosing and fixing common Windows issues. Instead of separate scripts per problem domain, everything lives in one file with a category-based menu — pick a category, then pick an action.

![Platform](https://img.shields.io/badge/platform-Windows-blue)
![Language](https://img.shields.io/badge/language-PowerShell-blue)
![Status](https://img.shields.io/badge/status-active-brightgreen)

---

## Background

As part of my career preparation in the field of **IT Support**, I often encounter situations where users report issues such as network, hardware, and system operation problems on their Windows devices.

Instead of typing CMD commands one by one every time I handle a ticket, I built the **Windows Diagnostic Toolkit**: an interactive menu that runs those commands with the press of a single button. The goal is to speed up *first-level troubleshooting* and reduce human error when typing commands under pressure (for example, while remotely assisting a panicked user).

## Features

| Category| Covers | 
|----|-------|
| Network Toolkit | 	IP config, DNS, adapter resets, connectivity auto-diagnosis |
| System Integrity Toolkit | 	SFC, DISM, CHKDSK, reliability history |
| Hardware Toolkit | 	CPU, RAM, storage health, hardware-related event errors |

## 📡 Network Toolkit

- Show full IP configuration (ipconfig /all)
  Ping test, DNS flush
- Release / renew IP address
- Reset Winsock / TCP-IP stack (with a y/n confirmation before either)
- Quick shortcuts to Network Connections, Wi-Fi settings, Device Manager, and the built-in Network Troubleshooter
- Continuous ping speed test
- Restart Windows Explorer
- Auto-Diagnostic Mode — runs a 3-step check (internet reachability → DNS resolution → default gateway) and prints a likely root cause with a suggested next step
- Every run is logged to a timestamped file under logs/

## 🛠️ System Integrity Toolkit

- SFC — Scan Now (check + repair) or Verify Only
- DISM — Check Health (quick), Scan Health (deep), Restore Health (repairs the component store SFC relies on)
- Full Repair Sequence — runs DISM RestoreHealth then SFC Scannow back-to-back, the standard fix order when SFC alone can't repair something
- CHKDSK — schedules a disk check on the next restart
- View the last 50 lines of CBS.log (the detailed log SFC writes its results to)
- Open Reliability History (perfmon /rel) — a timeline of crashes, errors, and system changes, useful for spotting patterns over time

## 💻 Hardware Toolkit

- CPU — core count, clock speed, status, and a 5-second live usage sample
- RAM — total/used/free memory, per-module details (slot, capacity, speed, manufacturer), and top 5 memory-consuming processes
- Storage — S.M.A.R.T. health status via Get-PhysicalDisk, reliability counters (wear, temperature, read/write errors), with a fallback to basic WMI disk status where those cmdlets aren't available
- Disk space summary per drive
- Hardware-related Event Log errors from the last 7 days (filtered to disk/storage/CPU/memory/WHEA providers)
- Full System Report — runs all of the above in sequence
- Export report to file — saves a full report as a timestamped .txt

## Requirements

- Windows 10/11
- PowerShell 5.1+ 
- Administrator privileges for most System Integrity options and some Network options (adapter resets, release/renew). The script checks elevation on launch and warns per-feature instead of blocking the whole menu.

## Usage

1. Right-click Windows Diagnostic Toolkit.ps1 → Run with PowerShell
Note: PowerShell scripts don't execute on double-click by design (a Windows security measure) — they'll open in a text editor instead unless launched this way.
2. For full functionality, run it from an elevated session: open PowerShell as Administrator first, then run .\Windows Diagnostic Toolkit.ps1
3. If blocked by execution policy, run once in an elevated PowerShell:

```shell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

4. Pick a category (1–3) from the main menu, then an action from that category's submenu. 0 steps back up a level.
5. Logs and exported reports are saved automatically to the logs/ folder next to the script.

## Demo

<img width="1092" height="282" alt="image" src="https://github.com/user-attachments/assets/42c3019a-663d-4170-a91a-387d34b6a261" />

---

<img width="1097" height="458" alt="image" src="https://github.com/user-attachments/assets/dfc0c05c-b492-4bcb-b596-1ba0c2df99a5" />

---

<img width="1107" height="565" alt="image" src="https://github.com/user-attachments/assets/fac66296-0f5a-4675-a6ac-95bd5573e34d" />

---

<img width="1097" height="404" alt="image" src="https://github.com/user-attachments/assets/0a7be65f-0ee9-4314-a9c2-8c3268c1439a" />

---

## About This Project

Created as part of a portfolio to prepare for a career in **IT Support**, this project demonstrates an understanding of basic network troubleshooting as well as the ability to build automation tools that are truly usable in day-to-day work.

---
