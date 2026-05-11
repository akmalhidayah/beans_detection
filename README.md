# Deteksi Kualitas Biji Kopi

Aplikasi Flutter UI awal untuk deteksi kualitas biji kopi Arabika dan Robusta berbasis AI/YOLOv11. Versi ini menggunakan dummy data lokal dan belum terhubung ke backend, kamera, atau galeri asli.

## Struktur Folder

- `lib/core/`: theme, warna, constants, utility, dan widget reusable.
- `lib/models/`: struktur data aplikasi.
- `lib/data/`: dummy data lokal sebelum backend/API disambungkan.
- `lib/screens/`: semua halaman aplikasi dan widget khusus setiap halaman.
- `assets/images/logo/`: tempat logo aplikasi asli.
- `assets/images/splash/`: tempat gambar splash screen.
- `assets/images/placeholders/`: tempat gambar dummy/contoh biji kopi.
- `assets/icons/`: tempat icon tambahan aplikasi.

## Cara Menjalankan

Jika project belum memiliki folder Android hasil scaffold Flutter, jalankan:

```bash
flutter create --platforms=android .
```

Lalu jalankan:

```bash
flutter pub get
flutter run
```

## Cara Mengganti Logo

1. Masukkan file logo ke `assets/images/logo/`.
2. Pastikan folder asset sudah terdaftar di `pubspec.yaml`.
3. Ubah path di `lib/core/constants/app_assets.dart`.
4. Ganti isi widget `AppLogo` agar memakai `Image.asset(AppAssets.logoPath)`.
