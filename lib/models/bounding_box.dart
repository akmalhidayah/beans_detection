class BoundingBox {
  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    this.label = '',
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;
  final String label;

  double get left => x;
  double get top => y;

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: _toDouble(json['x']),
      y: _toDouble(json['y']),
      width: _toDouble(json['width']),
      height: _toDouble(json['height']),
      confidence: _toDouble(json['confidence']),
      label: json['label']?.toString() ?? '',
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
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
