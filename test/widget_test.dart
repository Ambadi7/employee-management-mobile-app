import 'package:flutter_test/flutter_test.dart';
import 'package:emp_management/main.dart';
import 'package:emp_management/core/routes/app_routes.dart';

void main() {
  testWidgets('App smoke test initializes on login view', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.login));
    expect(find.text('Smart Attendance'), findsOneWidget);
  });
}
