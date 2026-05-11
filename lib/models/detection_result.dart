class DetectionResult {
  const DetectionResult({
    required this.id,
    required this.coffeeType,
    required this.grade,
    required this.confidence,
    required this.status,
    required this.description,
    required this.date,
    required this.characteristics,
  });

  final String id;
  final String coffeeType;
  final String grade;
  final double confidence;
  final String status;
  final String description;
  final DateTime date;
  final Map<String, String> characteristics;

  String get confidenceText => '${confidence.toStringAsFixed(1)}%';
}
