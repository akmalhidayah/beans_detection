import 'package:beans_detection/models/detection_result.dart';
import 'package:beans_detection/models/detection_summary.dart';
import 'package:beans_detection/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(
      () => SharedPreferences.setMockInitialValues({'language': 'Indonesia'}));

  DetectionResult detectedResult() => DetectionResult(
        id: 'result-1',
        className: 'Robusta Grade B',
        coffeeType: 'Robusta',
        grade: 'Grade B',
        confidence: .786,
        status: 'Kualitas Sedang',
        description:
            'Hasil ditentukan dari kelas dengan jumlah objek paling banyak.',
        recommendation: 'Masih layak, perlu sortasi ringan.',
        detectedAt: DateTime(2026, 8, 4, 12),
        characteristics: const {
          'bentuk_keutuhan': 'Sebagian besar biji utuh.',
          'ukuran': 'Ukuran biji cukup seragam.',
          'permukaan': 'Permukaan biji cukup baik.',
          'warna': 'Warna biji cukup merata.',
        },
        totalDetected: 1,
        summary: const DetectionSummary(
          total: 1,
          classCounts: {
            'Arabica Grade A': 0,
            'Arabica Grade B': 0,
            'Arabica Grade C': 0,
            'Robusta Grade A': 0,
            'Robusta Grade B': 1,
            'Robusta Grade C': 0,
          },
          gradeCounts: {'Grade A': 0, 'Grade B': 1, 'Grade C': 0},
          coffeeTypeCounts: {'Arabica': 0, 'Robusta': 1},
          dominantClass: 'Robusta Grade B',
          dominantCoffeeType: 'Robusta',
          dominantGrade: 'Grade B',
          dominantCount: 1,
          dominantPercentage: 100,
          dominantAverageConfidence: .786,
          averageConfidence: .786,
          lowQualityPercentage: 0,
          sortingRequiredPercentage: 100,
        ),
      );

  Future<void> pumpResult(
    WidgetTester tester, {
    required DetectionResult result,
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: ResultScreen(result: result)));
    await tester.pumpAndSettle();
  }

  testWidgets('detected result shows simplified summary and actions',
      (tester) async {
    await pumpResult(
      tester,
      result: detectedResult(),
      size: const Size(430, 900),
    );

    expect(find.text('Robusta Grade B'), findsWidgets);
    expect(find.text('Grade B'), findsOneWidget);
    for (final label in [
      'Confidence',
      'Objek terdeteksi',
      'Perlu disortasi',
      'Status kualitas',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    for (final removed in [
      'Kelas dominan:',
      'Jenis kopi dominan',
      'Grade dominan',
      'Persentase kelas dominan',
      'Deskripsi Hasil',
    ]) {
      expect(find.textContaining(removed), findsNothing);
    }

    expect(find.text('Informasi hasil'), findsOneWidget);
    expect(find.text('Masih layak, perlu sortasi ringan.'), findsOneWidget);
    expect(find.text('Simpan Riwayat'), findsOneWidget);
    expect(find.text('Deteksi Lagi'), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('information row opens result explanation', (tester) async {
    await pumpResult(
      tester,
      result: detectedResult(),
      size: const Size(430, 900),
    );
    await tester.ensureVisible(find.text('Informasi hasil'));
    await tester.tap(find.text('Informasi hasil'));
    await tester.pumpAndSettle();
    expect(find.text('Cara Hasil Ditentukan'), findsOneWidget);
    expect(find.textContaining('batas minimum'), findsOneWidget);
  });

  testWidgets('tablet layout does not overflow', (tester) async {
    await pumpResult(
      tester,
      result: detectedResult(),
      size: const Size(1000, 900),
    );
    await tester.scrollUntilVisible(
      find.text('Kembali ke Beranda'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('not detected state remains usable', (tester) async {
    final result = DetectionResult(
      id: 'none',
      coffeeType: '-',
      grade: '-',
      confidence: 0,
      status: 'Tidak Terdeteksi',
      description: '-',
      recommendation: '-',
      detectedAt: DateTime(2026),
      characteristics: const {},
      responseStatus: 'not_detected',
      message: 'Tidak ada objek terdeteksi.',
    );
    await pumpResult(tester, result: result, size: const Size(430, 800));
    expect(find.text('Tidak ada biji kopi terdeteksi.'), findsOneWidget);
    expect(find.text('Tidak ada objek terdeteksi.'), findsOneWidget);
    expect(find.text('Deteksi Lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
