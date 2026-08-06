@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/app/theme/app_theme.dart';
import 'package:tevio_app/features/auth/presentation/pages/login_page.dart';
import 'package:tevio_app/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  for (final entry in <String, Widget>{
    'onboarding': const OnboardingPage(),
    'login': const LoginPage(),
  }.entries) {
    testWidgets('${entry.key} screen matches the visual contract', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: entry.value),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(entry.value.runtimeType),
        matchesGoldenFile('entry_${entry.key}.png'),
      );
    });
  }
}
