import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/app/app.dart';
import 'package:tevio_app/core/config/app_environment.dart';

void main() {
  testWidgets('shows TEVIO onboarding copy', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            const AppEnvironment(
              type: Environment.development,
              apiBaseUrl: 'https://api.dev.tevio.app',
              sentryDsn: '',
            ),
          ),
        ],
        child: TevioApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('제품을 등록하면'), findsOneWidget);
    expect(find.text('테비오 시작하기'), findsNothing);
  });
}
