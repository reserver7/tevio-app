@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/app/theme/app_theme.dart';
import 'package:tevio_app/shared/design_system/catalog/tevio_catalog_page.dart';

void main() {
  testWidgets('design system catalog matches the visual contract', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const TevioCatalogPage()),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TevioCatalogPage),
      matchesGoldenFile('design_system_catalog.png'),
    );
  });
}
