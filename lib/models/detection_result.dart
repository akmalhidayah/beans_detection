import 'bounding_box.dart';

class DetectionResult {
  DetectionResult({
    required this.id,
    this.imagePath,
    this.imageName = '',
    String? className,
    required this.coffeeType,
    required this.grade,
    required this.confidence,
    double? confidencePercent,
    required this.status,
    required this.description,
    required this.recommendation,
    required this.detectedAt,
    required this.characteristics,
    this.boundingBoxes = const [],
  })  : className = className ?? _buildClassName(coffeeType, grade),
        confidencePercent = confidencePercent ?? _normalizePercent(confidence);

  final String id;
  final String? imagePath;
  final String imageName;
  final String className;
  final String coffeeType;
  final String grade;
  final double confidence;
  final double confidencePercent;
  final String status;
  final String description;
  final String recommendation;
  final DateTime detectedAt;
  final Map<String, String> characteristics;
  final List<BoundingBox> boundingBoxes;

  String get confidenceText => '${confidencePercent.toStringAsFixed(1)}%';

  double get confidenceRatio =>
      confidencePercent.clamp(0, 100).toDouble() / 100;

  bool get isDetected => className != 'Tidak Terdeteksi' && grade != '-';

  factory DetectionResult.fromApiJson(
    Map<String, dynamic> json, {
    String? localImagePath,
  }) {
    final characteristicsJson = json['characteristics'];
    final boxesJson = json['bounding_boxes'];
    final className = json['class_name']?.toString() ?? 'Tidak Terdeteksi';

    return DetectionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: localImagePath,
      imageName: json['image_name']?.toString() ?? '',
      className: className,
      coffeeType: json['coffee_type']?.toString() ?? '-',
      grade: json['grade']?.toString() ?? '-',
      confidence: _toDouble(json['confidence']),
      confidencePercent: _toDouble(json['confidence_percent']),
      status: json['status']?.toString() ?? 'Tidak Terdeteksi',
      description: json['description']?.toString() ?? '-',
      recommendation: json['recommendation']?.toString() ?? '-',
      detectedAt: DateTime.now(),
      characteristics: _parseCharacteristics(characteristicsJson),
      boundingBoxes: _parseBoundingBoxes(boxesJson, className),
    );
  }

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    final boxesJson = json['boundingBoxes'] ?? json['bounding_boxes'];
    final confidence = _toDouble(json['confidence']);
    final confidencePercentValue = json['confidencePercent'];
    return DetectionResult(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: json['imagePath']?.toString(),
      imageName: json['imageName']?.toString() ?? '',
      className: json['className']?.toString(),
      coffeeType: json['coffeeType']?.toString() ?? '-',
      grade: json['grade']?.toString() ?? '-',
      confidence: confidence,
      confidencePercent: confidencePercentValue == null
          ? _normalizePercent(confidence)
          : _toDouble(confidencePercentValue),
      status: json['status']?.toString() ?? 'Tidak Terdeteksi',
      description: json['description']?.toString() ?? '-',
      recommendation: json['recommendation']?.toString() ?? '-',
      detectedAt: DateTime.tryParse(json['detectedAt']?.toString() ?? '') ??
          DateTime.now(),
      characteristics: _parseCharacteristics(json['characteristics']),
      boundingBoxes: _parseBoundingBoxes(
        boxesJson,
        json['className']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'imageName': imageName,
      'className': className,
      'coffeeType': coffeeType,
      'grade': grade,
      'confidence': confidence,
      'confidencePercent': confidencePercent,
      'status': status,
      'description': description,
      'recommendation': recommendation,
      'detectedAt': detectedAt.toIso8601String(),
      'characteristics': characteristics,
      'boundingBoxes': boundingBoxes.map((box) => box.toJson()).toList(),
    };
  }

  static String _buildClassName(String coffeeType, String grade) {
    if (coffeeType == '-' || grade == '-') return 'Tidak Terdeteksi';
    return '$coffeeType $grade';
  }

  static double _normalizePercent(double value) {
    return value <= 1 ? value * 100 : value;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, String> _parseCharacteristics(dynamic value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        entry.key.toString(): entry.value.toString(),
    };
  }

  static List<BoundingBox> _parseBoundingBoxes(dynamic value, String label) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (box) => BoundingBox.fromJson(
            box.map((key, dynamic value) => MapEntry(key.toString(), value)),
          ),
        )
        .map(
          (box) => BoundingBox(
            x: box.x,
            y: box.y,
            width: box.width,
            height: box.height,
            confidence: box.confidence,
            label: box.label.isEmpty ? label : box.label,
          ),
        )
        .toList();
  }
}
