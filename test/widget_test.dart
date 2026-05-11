import 'package:beans_detection/app.dart';
import 'package:beans_detection/core/constants/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CoffeeQualityApp());

    expect(find.text(AppStrings.appName), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
