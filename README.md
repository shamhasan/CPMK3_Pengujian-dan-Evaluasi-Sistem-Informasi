# Integration Test Snippet - Stori Studio (Photo Session Module)

**PENTING: Repositori ini hanya berisi potongan skrip pengujian (Test Snippet) dan bukan merupakan source code aplikasi secara utuh.**

## Konteks Repositori
Repositori ini dibuat khusus untuk memenuhi luaran Evaluasi Akhir Semester (EAS) Magang Berdampak 2026. Skrip `app_test.dart` di dalam repositori ini adalah murni hasil rancangan penulis (Developer Testing) untuk menyimulasikan alur pengguna secara *end-to-end* pada modul Sesi Foto.

## Kepatuhan Non-Disclosure Agreement (NDA)
Sesuai dengan perjanjian kerahasiaan data (NDA) dengan instansi tempat magang, *source code* utama aplikasi (meliputi arsitektur GetX, logika bisnis, layanan unggah internal, dan antarmuka *proprietary*) **tidak diikutsertakan** dalam repositori publik ini. 

Skrip pengujian ini sengaja diekstraksi secara terisolasi (sebagai *snippet*) semata-mata untuk mendemonstrasikan kepada dosen penguji mengenai implementasi:
1. Skenario otomatisasi *Black-box testing* (simulasi interaksi `tester.tap`).
2. Validasi antarmuka dan *State Management* (pengecekan transisi UI dan perubahan data galeri).
3. Evaluasi stabilitas memori saat *hardware* kamera diakses secara berurutan.

Hasil nyata dari eksekusi skrip ini (yang dijalankan di lingkungan lokal internal perusahaan) telah dilampirkan berupa tangkapan layar terminal (*log*) pada dokumen Laporan Magang Bab III.
