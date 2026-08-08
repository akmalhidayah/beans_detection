import 'package:flutter/painting.dart';

import '../../models/bounding_box.dart';

Rect containedImageRect({required Size imageSize, required Size viewportSize}) {
  if (imageSize.isEmpty || viewportSize.isEmpty) return Rect.zero;
  final fitted = applyBoxFit(BoxFit.contain, imageSize, viewportSize);
  return Alignment.center
      .inscribe(fitted.destination, Offset.zero & viewportSize);
}

Rect boundingBoxRect(BoundingBox box, Rect imageRect) => Rect.fromLTWH(
      imageRect.left + box.x.clamp(0, 1) * imageRect.width,
      imageRect.top + box.y.clamp(0, 1) * imageRect.height,
      box.width.clamp(0, 1) * imageRect.width,
      box.height.clamp(0, 1) * imageRect.height,
    ).intersect(imageRect);
