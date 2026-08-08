import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active image picker does not request compression or resizing', () {
    final source = File('lib/screens/detection_screen.dart').readAsStringSync();
    final pickerCall = RegExp(
      r'_imagePicker\.pickImage\(([\s\S]*?)\);',
    ).firstMatch(source)!.group(1)!;

    expect(pickerCall, isNot(contains('imageQuality')));
    expect(pickerCall, isNot(contains('maxWidth')));
    expect(pickerCall, isNot(contains('maxHeight')));
  });
}
