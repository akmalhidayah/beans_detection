class BoundingBox {
  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    this.label = '',
    this.className = '',
    this.coffeeType = '',
    this.grade = '',
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final String label;
  final String className;
  final String coffeeType;
  final String grade;

  double get left => x;
  double get top => y;

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    final x = _toDouble(json['x']).clamp(0.0, 1.0).toDouble();
    final y = _toDouble(json['y']).clamp(0.0, 1.0).toDouble();
    final rawWidth = _toDouble(json['width']);
    final rawHeight = _toDouble(json['height']);
    return BoundingBox(
      x: x,
      y: y,
      width: rawWidth.clamp(0.0, 1.0 - x).toDouble(),
      height: rawHeight.clamp(0.0, 1.0 - y).toDouble(),
      confidence: _normalizeConfidence(_toDouble(json['confidence'])),
      label: json['label']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      coffeeType: json['coffee_type']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'confidence': confidence,
      'label': label,
      'class_name': className,
      'coffee_type': coffeeType,
      'grade': grade,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _normalizeConfidence(double value) =>
      (value > 1 ? value / 100 : value).clamp(0.0, 1.0).toDouble();
}
