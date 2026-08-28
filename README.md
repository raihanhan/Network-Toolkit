# 🛠️ Network Toolkit — Windows Network Troubleshooting Automation

Sebuah CLI berbasis Batch Script yang mengotomatisasi 13+ perintah troubleshooting jaringan Windows yang paling sering digunakan oleh IT Support, sehingga proses diagnosa dan perbaikan koneksi jaringan pengguna menjadi lebih cepat, konsisten, dan tidak perlu mengetik ulang perintah CMD satu per satu.

![Platform](https://img.shields.io/badge/platform-Windows-blue)
![Language](https://img.shields.io/badge/language-Batch%20Script-lightgrey)
![Status](https://img.shields.io/badge/status-active-brightgreen)

---

## 📌 Latar Belakang

Sebagai bagian dari persiapan karier di bidang **IT Support**, saya sering menjumpai skenario di mana user melaporkan masalah koneksi internet/jaringan yang solusinya berulang: cek IP, flush DNS, release/renew IP, reset TCP/IP stack, dan sebagainya.

Alih-alih mengetik perintah CMD satu per satu setiap kali menangani tiket, saya membangun **Network Toolkit**: sebuah menu interaktif yang menjalankan perintah-perintah tersebut hanya dengan menekan satu tombol. Tujuannya adalah mempercepat *first-level troubleshooting* dan mengurangi human error saat mengetik perintah di bawah tekanan (misalnya saat remote-assist user yang panik).

## ✨ Fitur

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

## 🧰 Tech Stack

- **Windows Batch Scripting (.bat)** — dipilih karena native berjalan di semua PC Windows tanpa instalasi dependency tambahan, cocok untuk lingkungan enterprise/klien yang sering membatasi instalasi software pihak ketiga.
- **Windows CLI Utilities** — `ipconfig`, `netsh`, `ping`, `taskkill`

## 🎯 Skill yang Didemonstrasikan

- Pemahaman **dasar jaringan komputer**: IP addressing, DNS, DHCP, TCP/IP stack, Winsock
- Kemampuan **troubleshooting sistematis** (urutan menu dari diagnosa → tindakan perbaikan → verifikasi)
- **Automation & scripting** untuk efisiensi kerja IT Support (mengubah SOP manual menjadi tool siap pakai)
- Pemahaman terhadap **kebutuhan end-user/helpdesk**: tool dirancang agar bisa dipakai teknisi junior tanpa harus hafal syntax CMD

## 🚀 Cara Menjalankan

1. Download atau clone repository ini
2. Jalankan `network-toolkit.bat` dengan cara double click (disarankan **Run as Administrator** agar perintah seperti `netsh winsock reset` dan `netsh int ip reset` berjalan sempurna)
3. Pilih nomor menu sesuai kebutuhan, lalu tekan Enter
4. Tool akan kembali ke menu utama setelah setiap perintah selesai dijalankan

> ⚠️ **Catatan:** Beberapa perintah (reset Winsock, reset TCP/IP stack, release/renew IP) memerlukan hak akses Administrator dan disarankan **restart PC** setelah dijalankan agar perubahan diterapkan penuh.

## 🖼️ Demo

*(Tempelkan screenshot tampilan menu di sini, atau GIF singkat saat memilih salah satu opsi. Lihat bagian "Cara Membuat Screenshot/Demo" di panduan portofolio.)*

```
=========================================================================
                           Network Toolkit
=========================================================================

1. Show Full IP Configuration
2. Ping Google
3. Flush DNS Cache
...
```

## 🔭 Rencana Pengembangan Selanjutnya

- [ ] Menambahkan logging otomatis (menyimpan hasil setiap perintah ke file `.txt` bertanggal, untuk dokumentasi tiket)
- [ ] Menambahkan validasi input (mencegah error jika user memasukkan huruf/angka di luar menu)
- [ ] Menambahkan opsi export hasil `ipconfig /all` ke file untuk dilampirkan ke laporan
- [ ] Port ke PowerShell untuk fitur yang lebih advanced (misalnya cek status adapter otomatis)

## 👤 Tentang Proyek Ini

Dibuat sebagai bagian dari portofolio dalam persiapan memulai karier di bidang **IT Support**, untuk mendemonstrasikan pemahaman troubleshooting jaringan dasar sekaligus kemampuan membangun tool otomatisasi yang benar-benar bisa dipakai di pekerjaan sehari-hari.

---
