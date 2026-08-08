import 'dart:convert';
import 'dart:typed_data';

import 'bounding_box.dart';
import 'detection_summary.dart';

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
    DetectionSummary? summary,
    this.characteristicsSource = '',
    this.characteristicsNote = '',
    this.recommendationSource = '',
    this.recommendationNote = '',
    this.aggregationMethod = '',
    this.inputInfo = const {},
    this.inferenceParameters = const {},
  })  : className = className ?? _buildClassName(coffeeType, grade),
        confidencePercent = confidencePercent ?? _normalizePercent(confidence),
        summary = summary ?? DetectionSummary.empty();

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
  final DetectionSummary summary;
  final String characteristicsSource;
  final String characteristicsNote;
  final String recommendationSource;
  final String recommendationNote;
  final String aggregationMethod;
  final Map<String, dynamic> inputInfo;
  final Map<String, dynamic> inferenceParameters;

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
    final firstDetection = detections.isEmpty ? null : detections.first;
    final summaryJson = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'])
        : data['summary'] is Map
            ? Map<String, dynamic>.from(data['summary'])
            : null;
    final parsedSummary =
        summaryJson == null ? null : DetectionSummary.fromJson(summaryJson);
    final className = api['class_name']?.toString() ??
        api['label']?.toString() ??
        (parsedSummary?.dominantClass != '-'
            ? parsedSummary?.dominantClass
            : null) ??
        firstDetection?['class_name']?.toString() ??
        firstDetection?['label']?.toString() ??
        (responseStatus == 'detected' ? '' : 'Tidak Terdeteksi');
    final coffeeType = api['coffee_type']?.toString() ??
        api['jenis_kopi']?.toString() ??
        (parsedSummary?.dominantCoffeeType != '-'
            ? parsedSummary?.dominantCoffeeType
            : null) ??
        firstDetection?['coffee_type']?.toString() ??
        firstDetection?['jenis_kopi']?.toString() ??
        '-';
    final grade = api['grade']?.toString() ??
        (parsedSummary?.dominantGrade != '-'
            ? parsedSummary?.dominantGrade
            : null) ??
        firstDetection?['grade']?.toString() ??
        '-';
    final confidence = _toDouble(api['confidence'] ??
        parsedSummary?.dominantAverageConfidence ??
        firstDetection?['confidence']);
    final dataBoxes = data['bounding_boxes'] ?? data['boundingBoxes'];
    final rootBoxes = json['bounding_boxes'] ?? json['boundingBoxes'];
    final boxesJson = dataBoxes is List && dataBoxes.isNotEmpty
        ? dataBoxes
        : rootBoxes is List && rootBoxes.isNotEmpty
            ? rootBoxes
            : _boxesFromDetections(detections);
    final boxes = _parseBoundingBoxes(
      boxesJson,
      className.isEmpty ? _buildClassName(coffeeType, grade) : className,
    );
    final totalDetected = _toInt(
      api['total_detected'] ?? api['totalDetected'],
      fallback: detections.isNotEmpty ? detections.length : boxes.length,
    );
    final summary = parsedSummary ??
        DetectionSummary.fromLegacy(
          detections: detections,
          className: className,
          coffeeType: coffeeType,
          grade: grade,
          totalDetected: totalDetected,
          confidence: confidence,
        );

    return DetectionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: localImagePath,
      imageName:
          api['image_name']?.toString() ?? api['imageName']?.toString() ?? '',
      className: className.isEmpty ? null : className,
      coffeeType: coffeeType,
      grade: grade,
      confidence: confidence,
      confidencePercent: (api['confidence_percent'] ??
                  api['confidencePercent']) ==
              null
          ? _normalizePercent(confidence)
          : _toDouble(api['confidence_percent'] ?? api['confidencePercent']),
      status: _qualityStatus(data['status'] ?? api['status'], responseStatus),
      description:
          api['description']?.toString() ?? api['message']?.toString() ?? '-',
      recommendation: api['recommendation']?.toString() ??
          api['rekomendasi']?.toString() ??
          firstDetection?['recommendation']?.toString() ??
          firstDetection?['rekomendasi']?.toString() ??
          '-',
      detectedAt: _parseDate(api['detected_at'] ??
              api['detectedAt'] ??
              firstDetection?['detected_at']) ??
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
      summary: summary,
      characteristicsSource: api['characteristics_source']?.toString() ?? '',
      characteristicsNote: api['characteristics_note']?.toString() ?? '',
      recommendationSource: api['recommendation_source']?.toString() ?? '',
      recommendationNote: api['recommendation_note']?.toString() ?? '',
      aggregationMethod: api['aggregation_method']?.toString() ?? '',
      inputInfo: _parseDynamicMap(api['input_info']),
      inferenceParameters: _parseDynamicMap(api['inference_parameters']),
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
          (className != null && className != 'Tidak Terdeteksi') &&
              grade != '-',
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
      summary: json['summary'] is Map
          ? DetectionSummary.fromJson(
              Map<String, dynamic>.from(json['summary']))
          : DetectionSummary.fromLegacy(
              detections: _parseDetectionMaps(json['detections']),
              className: className ??
                  _buildClassName(
                    json['coffeeType']?.toString() ?? '-',
                    grade,
                  ),
              coffeeType: json['coffeeType']?.toString() ?? '-',
              grade: grade,
              totalDetected: _toInt(json['totalDetected']),
              confidence: confidence,
            ),
      characteristicsSource: json['characteristicsSource']?.toString() ?? '',
      characteristicsNote: json['characteristicsNote']?.toString() ?? '',
      recommendationSource: json['recommendationSource']?.toString() ?? '',
      recommendationNote: json['recommendationNote']?.toString() ?? '',
      aggregationMethod: json['aggregationMethod']?.toString() ?? '',
      inputInfo: _parseDynamicMap(json['inputInfo'] ?? json['input_info']),
      inferenceParameters: _parseDynamicMap(
        json['inferenceParameters'] ?? json['inference_parameters'],
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
      'imageBytes': imageBytes == null ? null : base64Encode(imageBytes!),
      'responseStatus': responseStatus,
      'message': message,
      'totalDetected': totalDetected,
      'confidenceThreshold': confidenceThreshold,
      'detections': detections,
      'summary': summary.toJson(),
      'characteristicsSource': characteristicsSource,
      'characteristicsNote': characteristicsNote,
      'recommendationSource': recommendationSource,
      'recommendationNote': recommendationNote,
      'aggregationMethod': aggregationMethod,
      'inputInfo': inputInfo,
      'inferenceParameters': inferenceParameters,
    };
  }

  DetectionResult copyWith({String? imagePath, Uint8List? imageBytes}) {
    return DetectionResult(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      imageName: imageName,
      className: className,
      coffeeType: coffeeType,
      grade: grade,
      confidence: confidence,
      confidencePercent: confidencePercent,
      status: status,
      description: description,
      recommendation: recommendation,
      detectedAt: detectedAt,
      characteristics: characteristics,
      boundingBoxes: boundingBoxes,
      imageBytes: imageBytes ?? this.imageBytes,
      responseStatus: responseStatus,
      message: message,
      totalDetected: totalDetected,
      confidenceThreshold: confidenceThreshold,
      detections: detections,
      summary: summary,
      characteristicsSource: characteristicsSource,
      characteristicsNote: characteristicsNote,
      recommendationSource: recommendationSource,
      recommendationNote: recommendationNote,
      aggregationMethod: aggregationMethod,
      inputInfo: inputInfo,
      inferenceParameters: inferenceParameters,
    );
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

  static Map<String, dynamic> _parseDynamicMap(dynamic value) {
    if (value is! Map) return const {};
    return Map<String, dynamic>.unmodifiable(
      value.map((key, item) => MapEntry(key.toString(), item)),
    );
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
        .whereType<Map>()
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
        .where((box) => box.width > 0 && box.height > 0)
        .map(
          (box) => BoundingBox(
            x: box.x,
            y: box.y,
            width: box.width,
            height: box.height,
            confidence: box.confidence,
            label: box.label.isEmpty ? label : box.label,
            className: box.className,
            coffeeType: box.coffeeType,
            grade: box.grade,
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
