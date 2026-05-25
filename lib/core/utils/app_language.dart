class AppLanguage {
  const AppLanguage._();

  static const String indonesia = 'Indonesia';
  static const String english = 'English';

  static String text(String key, String language) {
    final isEnglish = language == english;
    final dictionary = isEnglish ? _english : _indonesia;
    return dictionary[key] ?? _indonesia[key] ?? key;
  }

  static const Map<String, String> _indonesia = {
    'home': 'Beranda',
    'scan': 'Scan',
    'upload': 'Upload',
    'history': 'Riwayat',
    'profile': 'Profil',
    'edit_profile': 'Edit Profil',
    'logout': 'Keluar',
    'backend_status': 'Status Backend',
    'online': 'Online',
    'offline': 'Offline',
    'analyze_now': 'Analisis Sekarang',
    'choose_image': 'Pilih Gambar',
    'open_camera': 'Buka Kamera',
    'classification_result': 'Hasil Klasifikasi',
    'save_history': 'Simpan Riwayat',
    'detect_again': 'Deteksi Lagi',
    'language': 'Bahasa',
    'hello': 'Halo',
  };

  static const Map<String, String> _english = {
    'home': 'Home',
    'scan': 'Scan',
    'upload': 'Upload',
    'history': 'History',
    'profile': 'Profile',
    'edit_profile': 'Edit Profile',
    'logout': 'Logout',
    'backend_status': 'Backend Status',
    'online': 'Online',
    'offline': 'Offline',
    'analyze_now': 'Analyze Now',
    'choose_image': 'Choose Image',
    'open_camera': 'Open Camera',
    'classification_result': 'Classification Result',
    'save_history': 'Save History',
    'detect_again': 'Detect Again',
    'language': 'Language',
    'hello': 'Hello',
  };
}
