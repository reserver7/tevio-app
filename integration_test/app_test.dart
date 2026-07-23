import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tevio_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.text('제품을 등록하면'), findsOneWidget);
  });
}
