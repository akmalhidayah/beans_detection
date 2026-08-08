import 'package:beans_detection/core/utils/image_box_transform.dart';
import 'package:beans_detection/models/bounding_box.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates landscape, portrait, and square destinations', () {
    expect(
      containedImageRect(
          imageSize: const Size(1000, 500), viewportSize: const Size(400, 400)),
      const Rect.fromLTWH(0, 100, 400, 200),
    );
    expect(
      containedImageRect(
          imageSize: const Size(500, 1000), viewportSize: const Size(400, 400)),
      const Rect.fromLTWH(100, 0, 200, 400),
    );
    expect(
      containedImageRect(
          imageSize: const Size(500, 500), viewportSize: const Size(400, 400)),
      const Rect.fromLTWH(0, 0, 400, 400),
    );
  });

  test('maps normalized box into centered BoxFit.contain image', () {
    const image = Rect.fromLTWH(0, 100, 400, 200);
    final box = boundingBoxRect(
      const BoundingBox(
        x: .25,
        y: .25,
        width: .5,
        height: .5,
        confidence: .9,
      ),
      image,
    );
    expect(box, const Rect.fromLTWH(100, 150, 200, 100));
  });
}
