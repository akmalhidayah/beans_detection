import 'package:beans_detection/models/detection_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> detected({dynamic confidence = 0.91}) => {
        'success': true,
        'status': 'detected',
        'total_detected': 1,
        'detections': [
          {
            'class_name': 'Arabica Grade A',
            'coffee_type': 'Arabica',
            'grade': 'Grade A',
            'confidence': confidence,
            'bbox': {'x': .12, 'y': .2, 'width': .4, 'height': .3},
          }
        ],
        'data': {'status': 'Kualitas Tinggi', 'bounding_boxes': []},
      };

  test('normalizes ratio and already-percent confidence', () {
    expect(DetectionResult.fromApiJson(detected()).confidencePercent, 91);
    expect(
      DetectionResult.fromApiJson(detected(confidence: 91)).confidencePercent,
      91,
    );
  });

  test('uses bbox from detections and total_detected', () {
    final result = DetectionResult.fromApiJson(detected());
    expect(result.boundingBoxes, hasLength(1));
    expect(result.boundingBoxes.single.x, .12);
    expect(result.totalDetected, 1);
  });

  test('handles not_detected and error statuses', () {
    final none = DetectionResult.fromApiJson({
      'success': true,
      'status': 'not_detected',
      'detections': [],
      'total_detected': 0,
      'data': {'status': 'Tidak Terdeteksi'},
    });
    expect(none.isNotDetected, isTrue);
    expect(none.isDetected, isFalse);
    expect(none.totalDetected, 0);
    expect(DetectionResult.fromApiJson({'status': 'error'}).isError, isTrue);
  });

  test('prefers top-level aggregate over individual detections', () {
    final json = detected();
    json['class_name'] = 'Dominant';
    json['coffee_type'] = 'Arabica';
    json['grade'] = 'Grade C';
    json['confidence'] = .8;
    json['detections'] = [
      {
        'class_name': 'Low',
        'coffee_type': 'Robusta',
        'grade': 'C',
        'confidence': .4
      },
      {
        'class_name': 'High',
        'coffee_type': 'Arabica',
        'grade': 'A',
        'confidence': .95
      },
    ];
    expect(DetectionResult.fromApiJson(json).className, 'Dominant');
  });

  test('old history without summary remains readable with fallback summary',
      () {
    final result = DetectionResult.fromJson({
      'id': 'old',
      'className': 'Robusta Grade B',
      'coffeeType': 'Robusta',
      'grade': 'Grade B',
      'confidence': .75,
      'totalDetected': 2,
      'status': 'Kualitas Sedang',
      'description': '-',
      'recommendation': '-',
      'detectedAt': '2026-01-01T00:00:00Z',
      'characteristics': <String, String>{},
    });
    expect(result.summary.total, 2);
    expect(result.summary.classCounts['Robusta Grade B'], 2);
    expect(result.inputInfo, isEmpty);
    expect(result.inferenceParameters, isEmpty);
  });

  test('parses and persists optional input and inference metadata', () {
    final json = detected()
      ..['input_info'] = {
        'original_width': 3024,
        'exif_transposed': true,
      }
      ..['inference_parameters'] = {
        'image_size': 640,
        'confidence_threshold': .5,
      };
    final result = DetectionResult.fromApiJson(json);
    expect(result.inputInfo['original_width'], 3024);
    expect(result.inputInfo['exif_transposed'], isTrue);
    expect(result.inferenceParameters['image_size'], 640);

    final restored = DetectionResult.fromJson(result.toJson());
    expect(restored.inputInfo, result.inputInfo);
    expect(restored.inferenceParameters, result.inferenceParameters);
  });

  test('clamps or ignores invalid bounding boxes', () {
    final json = detected();
    json['data'] = {
      'bounding_boxes': [
        {'x': .9, 'y': -.2, 'width': .8, 'height': .5},
        {'x': .2, 'y': .2, 'width': 0, 'height': .3},
      ],
    };
    final boxes = DetectionResult.fromApiJson(json).boundingBoxes;
    expect(boxes, hasLength(1));
    expect(boxes.single.x + boxes.single.width, lessThanOrEqualTo(1));
    expect(boxes.single.y, 0);
  });
}
