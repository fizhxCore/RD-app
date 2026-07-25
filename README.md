# Reminder & Diary App

Aplikasi Reminder + Diary pribadi (terkunci PIN) yang dibangun dengan Flutter,
Clean Architecture, dan Riverpod. Dirancang untuk di-build sepenuhnya lewat
**GitHub Actions** — tidak perlu Android Studio atau Flutter SDK lokal.

## ✨ Fitur

**Reminder**
- Tambah/edit/hapus reminder, prioritas, kategori, catatan
- Reminder berulang: harian/mingguan/bulanan (reschedule manual, akurat lintas timezone)
- Pre-reminder: tepat waktu s/d 1 hari sebelumnya
- Notifikasi lokal dengan action button: ✅ Tandai Selesai, ⏰ Snooze 5 Menit
- Home screen: grup Hari Ini / Akan Datang / Terlambat / Selesai

**Diary (Catatan Pribadi)**
- Terkunci PIN 6 digit (hash SHA-256 + salt, tersimpan di secure storage)
- Isi catatan dienkripsi AES-256 per-entry — bukan disimpan plaintext di database
- Auto-lock setiap kali app kembali dari background
- Mood tag & kategori per catatan

⚠️ **Catatan penting**: encryption key diary diturunkan dari PIN. Jika PIN lupa
dan direset, semua catatan diary lama **tidak bisa dipulihkan** (by design, demi
keamanan). Ini diberitahukan jelas ke pengguna saat setup PIN & saat reset.

## 🏗️ Arsitektur

Clean Architecture, 3 layer per fitur (`data` / `domain` / `presentation`):

```
lib/
 ├── core/           # theme, database, notification service, router, DI
 ├── features/
 │    ├── reminder/  # data → domain → presentation
 │    └── diary/     # data → domain → presentation
 └── main.dart
```

Tech stack: Riverpod, Go Router, Drift (SQLite), flutter_local_notifications,
timezone, flutter_secure_storage, encrypt (AES), crypto (SHA-256).

## 🚀 Build APK via GitHub Actions

1. Buat repository baru di GitHub, push seluruh isi folder ini ke branch `main`.
2. Tab **Actions** akan otomatis menjalankan workflow `Build Android APK` setiap
   ada push ke `main` (atau jalankan manual lewat tombol **Run workflow**).
3. Setelah selesai (~5-8 menit), buka run yang selesai:
   - APK bisa diunduh dari bagian **Artifacts** (`reminder-diary-app-release`), atau
   - Otomatis dibuat sebagai **GitHub Release** dengan file APK terlampir.
4. Unduh APK, install di HP Android (aktifkan "Install dari sumber tidak dikenal"
   jika diminta).

### Kenapa ini bisa jalan tanpa `android/` folder di-commit
Workflow menjalankan `flutter create --platforms=android .` di awal untuk
membuat ulang folder `android/` dari template resmi Flutter, lalu
`scripts/patch_android.sh` menambahkan permission & receiver yang dibutuhkan
notifikasi (POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, boot receiver, dsb).
Ini membuat repo tetap ringan dan bebas masalah versi Gradle yang basi.

### Kalau build gagal
Kemungkinan penyebab paling umum & cara ceknya:
- **Error di step "Generate Drift & Riverpod code"** → cek log `build_runner`,
  biasanya karena ada typo di anotasi tabel Drift.
- **Error Gradle terkait `desugar_jdk_libs`** → versi Flutter/AGP di runner
  berbeda dari yang diasumsikan `patch_android.sh`; buka log lengkap step
  "Build release APK" untuk pesan error spesifik.
- **flutter_local_notifications exact alarm permission ditolak saat runtime**
  di Android 13+ → pengguna perlu approve permission "Alarms & reminders" di
  Settings HP secara manual (ini keterbatasan OS, bukan bug app).

## 📱 Roadmap lanjutan (belum diimplementasikan)
- Search & filter/sort reminder (judul, kategori, tanggal, prioritas)
- Dark mode toggle yang benar-benar tersambung ke tema (saat ini UI placeholder)
- Backup/restore data
- Unit test & widget test
