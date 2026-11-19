import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rhetorique/main.dart';
import 'package:rhetorique/services/storage_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    await tester.pumpWidget(RhetoriqueApp(storageService: storage));
    expect(find.byType(RhetoriqueApp), findsOneWidget);
  });
}
