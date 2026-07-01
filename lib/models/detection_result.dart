import 'dart:convert';
import 'dart:typed_data';

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
    this.imageBytes,
    this.responseStatus = 'detected',
    this.message = '',
    this.totalDetected = 0,
    this.confidenceThreshold = 0.5,
    this.detections = const [],
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
  final Uint8List? imageBytes;
  final String responseStatus;
  final String message;
  final int totalDetected;
  final double confidenceThreshold;
  final List<Map<String, dynamic>> detections;

  String get confidenceText => '${confidencePercent.toStringAsFixed(1)}%';

  double get confidenceRatio =>
      confidencePercent.clamp(0, 100).toDouble() / 100;

  bool get isDetected => responseStatus == 'detected';
  bool get isNotDetected => responseStatus == 'not_detected';
  bool get isError => responseStatus == 'error';

  factory DetectionResult.fromApiJson(
    Map<String, dynamic> json, {
    String? localImagePath,
    Uint8List? localImageBytes,
  }) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final api = {
      ...data,
      ...json,
    };

    final rawStatus = api['response_status']?.toString() ??
        api['api_status']?.toString() ??
        api['detection_status']?.toString() ??
        _responseStatusFromRaw(api['status']);
    final responseStatus =
        _normalizeResponseStatus(rawStatus, fallbackDetected: true);
    final detections = _parseDetectionMaps(api['detections']);
    final firstDetection = detections.isNotEmpty ? detections.first : null;
    final className = api['class_name']?.toString() ??
        api['label']?.toString() ??
        firstDetection?['class_name']?.toString() ??
        firstDetection?['label']?.toString() ??
        (responseStatus == 'detected' ? '' : 'Tidak Terdeteksi');
    final coffeeType = api['coffee_type']?.toString() ??
        api['jenis_kopi']?.toString() ??
        firstDetection?['coffee_type']?.toString() ??
        firstDetection?['jenis_kopi']?.toString() ??
        '-';
    final grade = api['grade']?.toString() ??
        firstDetection?['grade']?.toString() ??
        '-';
    final confidence = _toDouble(
      api['confidence'] ?? firstDetection?['confidence'],
    );
    final boxesJson = api['bounding_boxes'] ??
        api['boundingBoxes'] ??
        _boxesFromDetections(detections);
    final boxes = _parseBoundingBoxes(
      boxesJson,
      className.isEmpty ? _buildClassName(coffeeType, grade) : className,
    );
    final totalDetected = _toInt(
      api['total_detected'] ?? api['totalDetected'],
      fallback: detections.isNotEmpty ? detections.length : boxes.length,
    );

    return DetectionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: localImagePath,
      imageName: api['image_name']?.toString() ?? api['imageName']?.toString() ?? '',
      className: className.isEmpty ? null : className,
      coffeeType: coffeeType,
      grade: grade,
      confidence: confidence,
      confidencePercent: _toDouble(
        api['confidence_percent'] ?? api['confidencePercent'],
      ),
      status: _qualityStatus(data['status'] ?? api['status'], responseStatus),
      description: api['description']?.toString() ??
          api['message']?.toString() ??
          '-',
      recommendation: api['recommendation']?.toString() ??
          api['rekomendasi']?.toString() ??
          firstDetection?['recommendation']?.toString() ??
          firstDetection?['rekomendasi']?.toString() ??
          '-',
      detectedAt: _parseDate(api['detected_at'] ?? api['detectedAt']) ??
          DateTime.now(),
      characteristics: _parseCharacteristics(
        api['characteristics'] ??
            api['karakteristik'] ??
            firstDetection?['characteristics'] ??
            firstDetection?['karakteristik'],
      ),
      boundingBoxes: boxes,
      imageBytes: localImageBytes,
      responseStatus: responseStatus,
      message: api['message']?.toString() ?? '',
      totalDetected: totalDetected,
      confidenceThreshold: _toDouble(
        api['confidence_threshold'] ?? api['confidenceThreshold'] ?? 0.5,
      ),
      detections: detections,
    );
  }

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    final boxesJson = json['boundingBoxes'] ?? json['bounding_boxes'];
    final confidence = _toDouble(json['confidence']);
    final confidencePercentValue = json['confidencePercent'];
    final className = json['className']?.toString();
    final grade = json['grade']?.toString() ?? '-';
    final responseStatus = _normalizeResponseStatus(
      json['responseStatus'] ?? json['apiStatus'],
      fallbackDetected:
          (className != null && className != 'Tidak Terdeteksi') && grade != '-',
    );
    return DetectionResult(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: json['imagePath']?.toString(),
      imageName: json['imageName']?.toString() ?? '',
      className: className,
      coffeeType: json['coffeeType']?.toString() ?? '-',
      grade: grade,
      confidence: confidence,
      confidencePercent: confidencePercentValue == null
          ? _normalizePercent(confidence)
          : _toDouble(confidencePercentValue),
      status: json['status']?.toString() ?? 'Tidak Terdeteksi',
      description: json['description']?.toString() ?? '-',
      recommendation: json['recommendation']?.toString() ?? '-',
      detectedAt: _parseDate(json['detectedAt']) ?? DateTime.now(),
      characteristics: _parseCharacteristics(json['characteristics']),
      boundingBoxes: _parseBoundingBoxes(
        boxesJson,
        json['className']?.toString() ?? '',
      ),
      imageBytes: _parseImageBytes(json['imageBytes']),
      responseStatus: responseStatus,
      message: json['message']?.toString() ?? '',
      totalDetected: _toInt(json['totalDetected']),
      confidenceThreshold: _toDouble(json['confidenceThreshold'] ?? 0.5),
      detections: _parseDetectionMaps(json['detections']),
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
      'imageBytes': imageBytes == null ? null : base64Encode(imageBytes!),
      'responseStatus': responseStatus,
      'message': message,
      'totalDetected': totalDetected,
      'confidenceThreshold': confidenceThreshold,
      'detections': detections,
    };
  }

  static String _buildClassName(String coffeeType, String grade) {
    if (coffeeType == '-' || grade == '-') return 'Tidak Terdeteksi';
    return '$coffeeType $grade';
  }

  static String _qualityStatus(dynamic status, String responseStatus) {
    final text = status?.toString();
    if (text == null || text.isEmpty) {
      return responseStatus == 'detected' ? 'Terdeteksi' : 'Tidak Terdeteksi';
    }
    if (text == 'detected') return 'Terdeteksi';
    if (text == 'not_detected') return 'Tidak Terdeteksi';
    if (text == 'error') return 'Error';
    return text;
  }

  static String? _responseStatusFromRaw(dynamic value) {
    final text = value?.toString();
    if (text == 'detected' || text == 'not_detected' || text == 'error') {
      return text;
    }
    return null;
  }

  static String _normalizeResponseStatus(
    dynamic value, {
    bool fallbackDetected = false,
  }) {
    final text = value?.toString().toLowerCase();
    if (text == 'detected' || text == 'not_detected' || text == 'error') {
      return text!;
    }
    return fallbackDetected ? 'detected' : 'not_detected';
  }

  static double _normalizePercent(double value) {
    return value <= 1 ? value * 100 : value;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime? _parseDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static Map<String, String> _parseCharacteristics(dynamic value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        entry.key.toString(): entry.value.toString(),
    };
  }

  static List<Map<String, dynamic>> _parseDetectionMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static List<dynamic> _boxesFromDetections(
    List<Map<String, dynamic>> detections,
  ) {
    return detections
        .map((detection) => detection['bbox'] ?? detection['bounding_box'])
        .where((box) => box is Map)
        .toList();
  }

  static List<BoundingBox> _parseBoundingBoxes(dynamic value, String label) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (box) => BoundingBox.fromJson(
            Map<String, dynamic>.from(box),
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

  static Uint8List? _parseImageBytes(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }
}
