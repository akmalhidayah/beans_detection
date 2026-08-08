class DetectionSummary {
  const DetectionSummary({
    required this.total,
    required this.classCounts,
    required this.gradeCounts,
    required this.coffeeTypeCounts,
    required this.dominantClass,
    required this.dominantCoffeeType,
    required this.dominantGrade,
    required this.dominantCount,
    required this.dominantPercentage,
    required this.dominantAverageConfidence,
    required this.averageConfidence,
    required this.lowQualityPercentage,
    required this.sortingRequiredPercentage,
  });

  static const classNames = <String>[
    'Arabica Grade A',
    'Arabica Grade B',
    'Arabica Grade C',
    'Robusta Grade A',
    'Robusta Grade B',
    'Robusta Grade C',
  ];
  static const gradeNames = <String>['Grade A', 'Grade B', 'Grade C'];
  static const coffeeTypes = <String>['Arabica', 'Robusta'];

  final int total;
  final Map<String, int> classCounts;
  final Map<String, int> gradeCounts;
  final Map<String, int> coffeeTypeCounts;
  final String dominantClass;
  final String dominantCoffeeType;
  final String dominantGrade;
  final int dominantCount;
  final double dominantPercentage;
  final double dominantAverageConfidence;
  final double averageConfidence;
  final double lowQualityPercentage;
  final double sortingRequiredPercentage;

  factory DetectionSummary.empty() => DetectionSummary(
        total: 0,
        classCounts: {for (final name in classNames) name: 0},
        gradeCounts: {for (final name in gradeNames) name: 0},
        coffeeTypeCounts: {for (final name in coffeeTypes) name: 0},
        dominantClass: '-',
        dominantCoffeeType: '-',
        dominantGrade: '-',
        dominantCount: 0,
        dominantPercentage: 0,
        dominantAverageConfidence: 0,
        averageConfidence: 0,
        lowQualityPercentage: 0,
        sortingRequiredPercentage: 0,
      );

  factory DetectionSummary.fromJson(Map<String, dynamic> json) {
    final empty = DetectionSummary.empty();
    return DetectionSummary(
      total: _int(json['total']),
      classCounts: _countMap(
          json['class_counts'] ?? json['classCounts'], empty.classCounts),
      gradeCounts: _countMap(
          json['grade_counts'] ?? json['gradeCounts'], empty.gradeCounts),
      coffeeTypeCounts: _countMap(
        json['coffee_type_counts'] ?? json['coffeeTypeCounts'],
        empty.coffeeTypeCounts,
      ),
      dominantClass:
          _text(json['dominant_class'] ?? json['dominantClass'], '-'),
      dominantCoffeeType: _text(
        json['dominant_coffee_type'] ?? json['dominantCoffeeType'],
        '-',
      ),
      dominantGrade:
          _text(json['dominant_grade'] ?? json['dominantGrade'], '-'),
      dominantCount: _int(json['dominant_count'] ?? json['dominantCount']),
      dominantPercentage: _double(
        json['dominant_percentage'] ?? json['dominantPercentage'],
      ),
      dominantAverageConfidence: _double(
        json['dominant_average_confidence'] ??
            json['dominantAverageConfidence'],
      ),
      averageConfidence: _double(
        json['average_confidence'] ?? json['averageConfidence'],
      ),
      lowQualityPercentage: _double(
        json['low_quality_percentage'] ?? json['lowQualityPercentage'],
      ),
      sortingRequiredPercentage: _double(
        json['sorting_required_percentage'] ??
            json['sortingRequiredPercentage'],
      ),
    );
  }

  factory DetectionSummary.fromLegacy({
    required List<Map<String, dynamic>> detections,
    required String className,
    required String coffeeType,
    required String grade,
    required int totalDetected,
    required double confidence,
  }) {
    final classCounts = {for (final name in classNames) name: 0};
    final gradeCounts = {for (final name in gradeNames) name: 0};
    final typeCounts = {for (final name in coffeeTypes) name: 0};
    final confidences = {for (final name in classNames) name: <double>[]};
    for (final detection in detections) {
      final detectedClass = detection['class_name']?.toString() ?? '';
      final detectedGrade = detection['grade']?.toString() ?? '';
      final detectedType = detection['coffee_type']?.toString() ?? '';
      if (classCounts.containsKey(detectedClass)) {
        classCounts[detectedClass] = classCounts[detectedClass]! + 1;
      }
      if (confidences.containsKey(detectedClass)) {
        confidences[detectedClass]!.add(_double(detection['confidence']));
      }
      if (gradeCounts.containsKey(detectedGrade)) {
        gradeCounts[detectedGrade] = gradeCounts[detectedGrade]! + 1;
      }
      if (typeCounts.containsKey(detectedType)) {
        typeCounts[detectedType] = typeCounts[detectedType]! + 1;
      }
    }
    final total = detections.isNotEmpty ? detections.length : totalDetected;
    if (detections.isEmpty && total > 0) {
      if (classCounts.containsKey(className)) classCounts[className] = total;
      if (gradeCounts.containsKey(grade)) gradeCounts[grade] = total;
      if (typeCounts.containsKey(coffeeType)) typeCounts[coffeeType] = total;
    }
    final rankedClasses = classNames.toList()
      ..sort((left, right) {
        final countCompare = classCounts[right]!.compareTo(classCounts[left]!);
        if (countCompare != 0) return countCompare;
        final leftTotal = confidences[left]!.fold<double>(0, (a, b) => a + b);
        final rightTotal = confidences[right]!.fold<double>(0, (a, b) => a + b);
        final confidenceCompare = rightTotal.compareTo(leftTotal);
        if (confidenceCompare != 0) return confidenceCompare;
        return classNames.indexOf(left).compareTo(classNames.indexOf(right));
      });
    final fallbackClass = classCounts.containsKey(className) ? className : '-';
    final selectedClass = total > 0 && classCounts[rankedClasses.first]! > 0
        ? rankedClasses.first
        : fallbackClass;
    final dominantCount = classCounts[selectedClass] ?? 0;
    final selectedDetections = detections.where(
      (item) => item['class_name']?.toString() == selectedClass,
    );
    final selectedSample =
        selectedDetections.isEmpty ? null : selectedDetections.first;
    final selectedType = selectedSample?['coffee_type']?.toString() ??
        (selectedClass.startsWith('Arabica')
            ? 'Arabica'
            : selectedClass.startsWith('Robusta')
                ? 'Robusta'
                : coffeeType);
    final selectedGrade = selectedSample?['grade']?.toString() ??
        (selectedClass.endsWith('Grade A')
            ? 'Grade A'
            : selectedClass.endsWith('Grade B')
                ? 'Grade B'
                : selectedClass.endsWith('Grade C')
                    ? 'Grade C'
                    : grade);
    final selectedConfidenceTotal = confidences[selectedClass]
            ?.fold<double>(0, (sum, value) => sum + value) ??
        0;
    final allConfidence = confidences.values
        .expand((values) => values)
        .fold<double>(0, (sum, value) => sum + value);
    final dominantConfidence = dominantCount == 0
        ? (confidence > 1 ? confidence / 100 : confidence)
        : selectedConfidenceTotal / dominantCount;
    return DetectionSummary(
      total: total,
      classCounts: classCounts,
      gradeCounts: gradeCounts,
      coffeeTypeCounts: typeCounts,
      dominantClass: total > 0 ? selectedClass : '-',
      dominantCoffeeType: total > 0 ? selectedType : '-',
      dominantGrade: total > 0 ? selectedGrade : '-',
      dominantCount: dominantCount,
      dominantPercentage: total == 0 ? 0 : dominantCount / total * 100,
      dominantAverageConfidence: dominantConfidence,
      averageConfidence: detections.isEmpty
          ? (confidence > 1 ? confidence / 100 : confidence)
          : allConfidence / detections.length,
      lowQualityPercentage:
          total == 0 ? 0 : (gradeCounts['Grade C'] ?? 0) / total * 100,
      sortingRequiredPercentage: total == 0
          ? 0
          : ((gradeCounts['Grade B'] ?? 0) + (gradeCounts['Grade C'] ?? 0)) /
              total *
              100,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'class_counts': classCounts,
        'grade_counts': gradeCounts,
        'coffee_type_counts': coffeeTypeCounts,
        'dominant_class': dominantClass,
        'dominant_coffee_type': dominantCoffeeType,
        'dominant_grade': dominantGrade,
        'dominant_count': dominantCount,
        'dominant_percentage': dominantPercentage,
        'dominant_average_confidence': dominantAverageConfidence,
        'average_confidence': averageConfidence,
        'low_quality_percentage': lowQualityPercentage,
        'sorting_required_percentage': sortingRequiredPercentage,
      };

  static Map<String, int> _countMap(dynamic value, Map<String, int> defaults) {
    final result = Map<String, int>.from(defaults);
    if (value is Map) {
      for (final entry in value.entries) {
        if (result.containsKey(entry.key.toString())) {
          result[entry.key.toString()] = _int(entry.value);
        }
      }
    }
    return result;
  }

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
  static double _double(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
  static String _text(dynamic value, String fallback) {
    final text = value?.toString() ?? '';
    return text.isEmpty ? fallback : text;
  }
}
