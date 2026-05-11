# Logo Assets

Folder ini digunakan untuk menyimpan logo aplikasi asli.

Contoh penggunaan nanti:
- `app_logo.png`
- `app_logo_dark.png`

Setelah file logo ditambahkan, daftarkan path asset di `pubspec.yaml`, ubah constant di `lib/core/constants/app_assets.dart`, lalu sesuaikan widget `AppLogo` agar memakai `Image.asset`.
