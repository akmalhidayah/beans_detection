import '../models/detection_result.dart';

final List<DetectionResult> dummyDetectionResults = [
  DetectionResult(
    id: 'DET-001',
    coffeeType: 'Arabika',
    grade: 'Grade A',
    confidence: 94.7,
    status: 'Berkualitas Tinggi',
    description:
        'Biji kopi memiliki bentuk utuh, ukuran relatif seragam, permukaan halus, dan warna merata.',
    date: DateTime(2026, 5, 11, 9, 15),
    characteristics: const {
      'Bentuk & Keutuhan': 'Baik',
      'Ukuran': 'Seragam',
      'Permukaan': 'Halus',
      'Warna': 'Merata',
    },
  ),
  DetectionResult(
    id: 'DET-002',
    coffeeType: 'Robusta',
    grade: 'Grade B',
    confidence: 87.5,
    status: 'Kualitas Sedang',
    description:
        'Biji kopi cukup baik, namun terdapat sedikit variasi ukuran dan warna pada beberapa biji.',
    date: DateTime(2026, 5, 10, 14, 40),
    characteristics: const {
      'Bentuk & Keutuhan': 'Cukup',
      'Ukuran': 'Cukup Seragam',
      'Permukaan': 'Cukup Halus',
      'Warna': 'Cukup Merata',
    },
  ),
  DetectionResult(
    id: 'DET-003',
    coffeeType: 'Arabika',
    grade: 'Grade C',
    confidence: 76.2,
    status: 'Kualitas Rendah',
    description:
        'Biji kopi menunjukkan ketidakteraturan bentuk, ukuran tidak merata, dan permukaan kurang mulus.',
    date: DateTime(2026, 5, 9, 11, 5),
    characteristics: const {
      'Bentuk & Keutuhan': 'Kurang',
      'Ukuran': 'Tidak Seragam',
      'Permukaan': 'Kasar',
      'Warna': 'Tidak Merata',
    },
  ),
  DetectionResult(
    id: 'DET-004',
    coffeeType: 'Robusta',
    grade: 'Grade A',
    confidence: 92.1,
    status: 'Berkualitas Tinggi',
    description:
        'Biji robusta tampak utuh, padat, dan memiliki warna yang konsisten untuk kualitas tinggi.',
    date: DateTime(2026, 5, 8, 16, 25),
    characteristics: const {
      'Bentuk & Keutuhan': 'Baik',
      'Ukuran': 'Seragam',
      'Permukaan': 'Halus',
      'Warna': 'Merata',
    },
  ),
  DetectionResult(
    id: 'DET-005',
    coffeeType: 'Arabika',
    grade: 'Grade B',
    confidence: 84.8,
    status: 'Kualitas Sedang',
    description:
        'Biji arabika masih layak, dengan sebagian kecil perbedaan bentuk dan tingkat warna.',
    date: DateTime(2026, 5, 7, 8, 50),
    characteristics: const {
      'Bentuk & Keutuhan': 'Cukup',
      'Ukuran': 'Cukup Seragam',
      'Permukaan': 'Cukup Halus',
      'Warna': 'Cukup Merata',
    },
  ),
];
