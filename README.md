# Coffee Quality Detection - Frontend

Coffee Quality Detection adalah aplikasi berbasis Android yang digunakan untuk mendeteksi dan mengklasifikasikan kualitas biji kopi berdasarkan citra digital menggunakan metode YOLOv11. Aplikasi ini dikembangkan menggunakan Flutter sebagai frontend dan terhubung dengan backend FastAPI untuk melakukan proses deteksi kualitas biji kopi.

Aplikasi ini dapat digunakan oleh petani, pembeli, pelaku usaha kopi, maupun pengguna umum untuk membantu proses penilaian kualitas biji kopi secara lebih cepat, objektif, dan konsisten.

## Fitur Utama

Aplikasi frontend ini menyediakan beberapa fitur utama, yaitu:

- Login pengguna menggunakan email, Google, atau nomor telepon.
- Halaman beranda yang menampilkan statistik hasil deteksi.
- Fitur scan kamera untuk mengambil citra biji kopi secara langsung.
- Fitur upload gambar untuk memilih citra biji kopi dari galeri.
- Halaman hasil klasifikasi yang menampilkan jenis kopi, grade kualitas, confidence score, jumlah objek terdeteksi, status kualitas, bounding box, karakteristik fisik, dan rekomendasi.
- Riwayat deteksi untuk menyimpan dan melihat kembali hasil klasifikasi sebelumnya.
- Halaman profil pengguna yang menampilkan data akun, lokasi, bahasa, statistik penggunaan, dan informasi model YOLO aktif.
- Fitur upload model `.pt` untuk memperbarui model YOLO yang digunakan oleh sistem.

## Teknologi yang Digunakan

Frontend aplikasi ini dikembangkan menggunakan beberapa teknologi berikut:

- Flutter
- Dart
- HTTP Client
- Image Picker
- File Picker
- Shared Preferences
- Google Sign In
- URL Launcher

## Struktur Folder

Struktur utama folder frontend adalah sebagai berikut:

```text
lib/
├── core/              # Konfigurasi utama aplikasi
├── data/              # Data lokal atau dummy pendukung aplikasi
├── models/            # Model data aplikasi
├── screens/           # Halaman antarmuka pengguna
├── services/          # Service untuk API, autentikasi, riwayat, dan model
├── app.dart           # Konfigurasi aplikasi
└── main.dart          # Entry point aplikasi
```

# Production dan iOS

API aplikasi adalah `http://203.145.35.191`. Nilai ini menjadi default tunggal di
`ApiConfig`, tetapi tetap dapat diganti saat build dengan `--dart-define`.

Jalankan development dengan konfigurasi environment:

```sh
flutter run \
  --dart-define=API_BASE_URL=http://203.145.35.191 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=ISI_SERVER_CLIENT_ID \
  --dart-define=GOOGLE_IOS_CLIENT_ID=ISI_IOS_CLIENT_ID
```

Flutter Web Chrome:

```sh
flutter run -d chrome --web-port=51039 \
  --dart-define=API_BASE_URL=http://203.145.35.191
```

Flutter Web melalui web-server (buka URL-nya secara manual di Safari):

```sh
flutter run -d web-server --web-hostname=localhost --web-port=51039 \
  --dart-define=API_BASE_URL=http://203.145.35.191
```

Foto dari kamera atau galeri dikirim sebagai `XFile` asli. Frontend tidak
meminta kompresi, resize, crop, atau encode ulang dari `image_picker`; file JPG,
JPEG, atau PNG divalidasi dengan batas maksimum 20 MB lalu dikirim langsung
sebagai multipart field `file`.

Android release:

```sh
flutter build apk --release \
  --dart-define=API_BASE_URL=http://203.145.35.191
```

Untuk iOS, buat OAuth Client bertipe iOS di Google Cloud dengan Bundle ID
`com.akmalhidayah.beansdetection`. Isi iOS Client ID dan reversed client ID pada
konfigurasi lokal berdasarkan `ios/Flutter/GoogleSignIn.xcconfig.example`. Server
client ID harus sama dengan `GOOGLE_CLIENT_ID` backend. Jangan memasukkan client
secret ke aplikasi.

```sh
flutter pub get
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
```

Di Xcode pilih Runner, buka Signing & Capabilities, aktifkan Automatically manage
signing, pilih Team, pastikan Bundle ID benar, aktifkan Developer Mode pada iPhone,
lalu pilih iPhone sebagai target. Build tanpa signing dapat dijalankan dengan
`flutter build ios --no-codesign`.

Login nomor telepon belum aktif sampai backend menyediakan OTP. Google Sign-In iOS
memerlukan OAuth Client tipe iOS dan URL scheme reversed client ID.
