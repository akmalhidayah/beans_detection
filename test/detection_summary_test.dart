import 'package:beans_detection/models/detection_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses aggregate summary and keeps zero defaults', () {
    final summary = DetectionSummary.fromJson({
      'total': 4,
      'class_counts': {'Arabica Grade A': 3, 'Robusta Grade C': 1},
      'dominant_class': 'Arabica Grade A',
      'dominant_coffee_type': 'Arabica',
      'dominant_grade': 'Grade A',
      'dominant_count': 3,
      'dominant_percentage': 75,
      'dominant_average_confidence': 0.8,
      'low_quality_percentage': 25,
      'sorting_required_percentage': 25,
    });
    expect(summary.total, 4);
    expect(summary.classCounts['Arabica Grade B'], 0);
    expect(summary.dominantClass, 'Arabica Grade A');
    final restored = DetectionSummary.fromJson(summary.toJson());
    expect(restored.classCounts, summary.classCounts);
    expect(restored.dominantPercentage, 75);
  });

  test('builds fallback composition from legacy detections', () {
    final summary = DetectionSummary.fromLegacy(
      detections: [
        {
          'class_name': 'Robusta Grade C',
          'coffee_type': 'Robusta',
          'grade': 'Grade C'
        },
        {
          'class_name': 'Robusta Grade C',
          'coffee_type': 'Robusta',
          'grade': 'Grade C'
        },
      ],
      className: 'Robusta Grade C',
      coffeeType: 'Robusta',
      grade: 'Grade C',
      totalDetected: 2,
      confidence: .7,
    );
    expect(summary.dominantCount, 2);
    expect(summary.lowQualityPercentage, 100);
  });
}
