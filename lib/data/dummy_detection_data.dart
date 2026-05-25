import '../models/bounding_box.dart';
import '../models/detection_result.dart';

final List<DetectionResult> dummyDetectionResults = [
  DetectionResult(
    id: 'DET-001',
    coffeeType: 'Arabika',
    grade: 'Grade A',
    confidence: 0.925,
    confidencePercent: 92.5,
    status: 'Kualitas Tinggi',
    description:
        'Biji kopi Arabika terdeteksi memiliki bentuk utuh, ukuran seragam, permukaan halus, dan warna merata.',
    recommendation: 'Layak jual kualitas tinggi.',
    detectedAt: DateTime(2026, 5, 11, 9, 15),
    characteristics: const {
      'Bentuk dan keutuhan biji': 'Utuh dan sangat baik',
      'Ukuran biji': 'Seragam',
      'Permukaan biji': 'Halus',
      'Warna biji': 'Merata',
    },
    boundingBoxes: const [
      BoundingBox(
        x: 0.16,
        y: 0.18,
        width: 0.68,
        height: 0.58,
        confidence: 0.925,
        label: 'Arabika Grade A',
      ),
    ],
  ),
  DetectionResult(
    id: 'DET-002',
    coffeeType: 'Robusta',
    grade: 'Grade B',
    confidence: 0.842,
    confidencePercent: 84.2,
    status: 'Kualitas Sedang',
    description:
        'Biji kopi Robusta cukup baik, namun masih terdapat variasi kecil pada ukuran dan warna biji.',
    recommendation: 'Masih layak, perlu sortasi ringan.',
    detectedAt: DateTime(2026, 5, 10, 14, 40),
    characteristics: const {
      'Bentuk dan keutuhan biji': 'Cukup utuh',
      'Ukuran biji': 'Cukup seragam',
      'Permukaan biji': 'Cukup halus',
      'Warna biji': 'Cukup merata',
    },
    boundingBoxes: const [
      BoundingBox(
        x: 0.18,
        y: 0.22,
        width: 0.64,
        height: 0.54,
        confidence: 0.842,
        label: 'Robusta Grade B',
      ),
    ],
  ),
  DetectionResult(
    id: 'DET-003',
    coffeeType: 'Arabika',
    grade: 'Grade C',
    confidence: 0.789,
    confidencePercent: 78.9,
    status: 'Kualitas Rendah',
    description:
        'Biji kopi Arabika menunjukkan ketidakteraturan bentuk, ukuran tidak merata, dan permukaan kurang mulus.',
    recommendation: 'Perlu sortasi ulang karena kualitas rendah.',
    detectedAt: DateTime(2026, 5, 9, 11, 5),
    characteristics: const {
      'Bentuk dan keutuhan biji': 'Kurang utuh',
      'Ukuran biji': 'Tidak seragam',
      'Permukaan biji': 'Kasar',
      'Warna biji': 'Tidak merata',
    },
    boundingBoxes: const [
      BoundingBox(
        x: 0.20,
        y: 0.24,
        width: 0.58,
        height: 0.50,
        confidence: 0.789,
        label: 'Arabika Grade C',
      ),
    ],
  ),
  DetectionResult(
    id: 'DET-004',
    coffeeType: 'Robusta',
    grade: 'Grade A',
    confidence: 0.901,
    confidencePercent: 90.1,
    status: 'Kualitas Tinggi',
    description:
        'Biji Robusta tampak utuh, padat, dan memiliki warna yang konsisten untuk kualitas tinggi.',
    recommendation: 'Layak jual kualitas tinggi.',
    detectedAt: DateTime(2026, 5, 8, 16, 25),
    characteristics: const {
      'Bentuk dan keutuhan biji': 'Utuh dan baik',
      'Ukuran biji': 'Seragam',
      'Permukaan biji': 'Halus',
      'Warna biji': 'Merata',
    },
    boundingBoxes: const [
      BoundingBox(
        x: 0.15,
        y: 0.19,
        width: 0.70,
        height: 0.56,
        confidence: 0.901,
        label: 'Robusta Grade A',
      ),
    ],
  ),
  DetectionResult(
    id: 'DET-005',
    coffeeType: 'Arabika',
    grade: 'Grade B',
    confidence: 0.814,
    confidencePercent: 81.4,
    status: 'Kualitas Sedang',
    description:
        'Biji Arabika masih layak, dengan sebagian kecil perbedaan bentuk dan tingkat warna.',
    recommendation: 'Masih layak, perlu sortasi ringan.',
    detectedAt: DateTime(2026, 5, 7, 8, 50),
    characteristics: const {
      'Bentuk dan keutuhan biji': 'Cukup utuh',
      'Ukuran biji': 'Cukup seragam',
      'Permukaan biji': 'Cukup halus',
      'Warna biji': 'Cukup merata',
    },
    boundingBoxes: const [
      BoundingBox(
        x: 0.18,
        y: 0.20,
        width: 0.62,
        height: 0.55,
        confidence: 0.814,
        label: 'Arabika Grade B',
      ),
    ],
  ),
];
