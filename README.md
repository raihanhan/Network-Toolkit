# 🛠️ Network Toolkit — Windows Network Troubleshooting Automation

Sebuah CLI berbasis Batch Script yang mengotomatisasi 13+ perintah troubleshooting jaringan Windows yang paling sering digunakan oleh IT Support, sehingga proses diagnosa dan perbaikan koneksi jaringan pengguna menjadi lebih cepat, konsisten, dan tidak perlu mengetik ulang perintah CMD satu per satu.

![Platform](https://img.shields.io/badge/platform-Windows-blue)
![Language](https://img.shields.io/badge/language-Batch%20Script-lightgrey)
![Status](https://img.shields.io/badge/status-active-brightgreen)

---

## Latar Belakang

Sebagai bagian dari persiapan karier di bidang **IT Support**, saya sering menjumpai skenario di mana user melaporkan masalah koneksi internet/jaringan yang solusinya berulang: cek IP, flush DNS, release/renew IP, reset TCP/IP stack, dan sebagainya.

Alih-alih mengetik perintah CMD satu per satu setiap kali menangani tiket, saya membangun **Network Toolkit**: sebuah menu interaktif yang menjalankan perintah-perintah tersebut hanya dengan menekan satu tombol. Tujuannya adalah mempercepat *first-level troubleshooting* dan mengurangi human error saat mengetik perintah di bawah tekanan (misalnya saat remote-assist user yang panik).

## Fitur

| No | Fitur | Perintah Windows yang Dijalankan | Kegunaan di Dunia Nyata |
|----|-------|-----------------------------------|--------------------------|
| 1 | Show Full IP Configuration | `ipconfig /all` | Melihat IP, subnet, gateway, DNS, MAC address untuk diagnosa awal |
| 2 | Ping Google | `ping google.com` | Uji cepat konektivitas internet & DNS resolution |
| 3 | Flush DNS Cache | `ipconfig /flushdns` | Mengatasi masalah "website tidak bisa diakses" akibat cache DNS lama |
| 4 | Release IP Address | `ipconfig /release` | Melepas IP address yang bermasalah (biasanya sebelum renew) |
| 5 | Renew IP Address | `ipconfig /renew` | Meminta IP baru dari DHCP server |
| 6 | Reset Winsock | `netsh winsock reset` | Memperbaiki koneksi internet yang rusak akibat corrupt Winsock catalog |
| 7 | Reset TCP/IP Stack | `netsh int ip reset` | Mengembalikan konfigurasi TCP/IP ke default saat terjadi error jaringan kompleks |
| 8 | Open Network Connections | `ncpa.cpl` | Akses cepat ke adapter jaringan untuk cek status/enable-disable |
| 9 | Open WiFi Settings | `ms-settings:network-wifi` | Akses cepat pengaturan WiFi tanpa navigasi manual |
| 10 | Open Device Manager | `devmgmt.msc` | Cek driver adapter jaringan yang bermasalah |
| 11 | Open Network Troubleshooter | `ms-settings:troubleshoot` | Menjalankan built-in troubleshooter Windows |
| 12 | Speed Test Ping | `ping 8.8.8.8 -t` | Memantau latency & packet loss secara real-time |
| 13 | Restart Explorer | `taskkill /f /im explorer.exe` + `start explorer.exe` | Memperbaiki taskbar/File Explorer yang freeze tanpa perlu restart PC |

## Tech Stack

- **Windows Batch Scripting (.bat)** — dipilih karena native berjalan di semua PC Windows tanpa instalasi dependency tambahan, cocok untuk lingkungan enterprise/klien yang sering membatasi instalasi software pihak ketiga.
- **Windows CLI Utilities** — `ipconfig`, `netsh`, `ping`, `taskkill`

## Skill yang Didemonstrasikan

- Pemahaman **dasar jaringan komputer**: IP addressing, DNS, DHCP, TCP/IP stack, Winsock
- Kemampuan **troubleshooting sistematis** (urutan menu dari diagnosa → tindakan perbaikan → verifikasi)
- **Automation & scripting** untuk efisiensi kerja IT Support (mengubah SOP manual menjadi tool siap pakai)
- Pemahaman terhadap **kebutuhan end-user/helpdesk**: tool dirancang agar bisa dipakai teknisi junior tanpa harus hafal syntax CMD

## Cara Menjalankan

1. Download atau clone repository ini
2. Jalankan `network-toolkit.bat` dengan cara double click (disarankan **Run as Administrator** agar perintah seperti `netsh winsock reset` dan `netsh int ip reset` berjalan sempurna)
3. Pilih nomor menu sesuai kebutuhan, lalu tekan Enter
4. Tool akan kembali ke menu utama setelah setiap perintah selesai dijalankan

> ⚠️ **Catatan:** Beberapa perintah (reset Winsock, reset TCP/IP stack, release/renew IP) memerlukan hak akses Administrator dan disarankan **restart PC** setelah dijalankan agar perubahan diterapkan penuh.

## Demo

<img width="1102" height="585" alt="image" src="https://github.com/user-attachments/assets/b7e48c7e-8664-4c56-9b6c-aa481437f9e1" />

## Changelog — v2.0

Versi kedua menambahkan tiga peningkatan utama di atas versi awal:

- **Logging otomatis** — setiap perintah (opsi 1–7) kini menyimpan outputnya ke `logs/log_<timestamp>.txt`, memudahkan dokumentasi saat menangani tiket helpdesk.
- **Validasi input & error handling** — input di luar 1–15 akan menampilkan pesan error, bukan diabaikan begitu saja; perintah yang butuh hak akses Administrator (opsi 4–7) dicek dulu sebelum dijalankan; perintah berisiko (reset Winsock/TCP-IP, opsi 6–7) meminta konfirmasi eksplisit sebelum dieksekusi.
- **Auto-Diagnostic Mode (opsi 14, BARU)** — menjalankan 3 pengecekan berurutan (konektivitas internet IP-level → resolusi DNS, dengan flush DNS otomatis jika gagal → konektivitas ke default gateway), lalu memberi kesimpulan kemungkinan penyebab masalah dan menyimpan laporan lengkap ke `logs/diagnostic_<timestamp>.txt`.

> File script v2.0 ada di `network-toolkit-v2.bat`. Script asli (v1.0) tetap disertakan di `network-toolkit.bat` sebagai referensi/riwayat perkembangan proyek — bagus untuk ditunjukkan di case study sebagai bukti progres.

> ⚠️ **Catatan pengujian:** Script v2.0 memakai `wmic` untuk timestamp log (locale-independent) — `wmic` sudah deprecated di Windows 11 versi terbaru meski umumnya masih terpasang. Sebelum dipakai di mesin produksi/dilampirkan ke portofolio, jalankan dan uji tiap opsi menu (terutama opsi 14) di lingkungan Windows nyata, dan sesuaikan bila ada perbedaan hasil.

## Rencana Pengembangan Selanjutnya

- [ ] Menambahkan opsi export hasil `ipconfig /all` ke format laporan HTML yang lebih rapi
- [ ] Port ke PowerShell untuk fitur yang lebih advanced (misalnya cek status adapter otomatis via `Get-NetAdapter`)
- [ ] Ganti `wmic` dengan `powershell Get-Date` sebagai fallback timestamp bila `wmic` tidak tersedia
- [ ] Versi GUI sederhana (Python/Tkinter)

## Tentang Proyek Ini

Dibuat sebagai bagian dari portofolio dalam persiapan memulai karier di bidang **IT Support**, untuk mendemonstrasikan pemahaman troubleshooting jaringan dasar sekaligus kemampuan membangun tool otomatisasi yang benar-benar bisa dipakai di pekerjaan sehari-hari.

---
