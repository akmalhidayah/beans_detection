import 'package:beans_detection/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': false});

    await tester.pumpWidget(const CoffeeQualityApp());

    expect(find.text('Coffee Quality'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();

    expect(find.text('Masuk'), findsWidgets);
  });
}
