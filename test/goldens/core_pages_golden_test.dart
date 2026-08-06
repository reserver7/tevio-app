@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/app/theme/app_theme.dart';
import 'package:tevio_app/features/home/presentation/pages/home_page.dart';
import 'package:tevio_app/features/notifications/presentation/state/notification_queries.dart';
import 'package:tevio_app/features/products/presentation/pages/products_page.dart';
import 'package:tevio_app/features/products/presentation/state/product_queries.dart';

void main() {
  for (final entry in <String, Widget>{
    'home': const HomePage(),
    'products': const ProductsPage(),
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
        ProviderScope(
          overrides: [
            productSummariesQueryProvider.overrideWithValue(const []),
            unreadNotificationsCountQueryProvider.overrideWithValue(0),
          ],
          child: MaterialApp(theme: AppTheme.light(), home: entry.value),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(entry.value.runtimeType),
        matchesGoldenFile('core_${entry.key}.png'),
      );
    });
  }
}
