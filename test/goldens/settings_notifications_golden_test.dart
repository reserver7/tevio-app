@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/app/theme/app_theme.dart';
import 'package:tevio_app/features/notifications/domain/models/tevio_notification.dart';
import 'package:tevio_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tevio_app/features/notifications/presentation/state/notification_queries.dart';
import 'package:tevio_app/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:tevio_app/features/settings/presentation/state/notification_settings.dart';

void main() {
  final pages = <String, Widget>{
    'notifications': const NotificationsPage(),
    'notification_settings': const NotificationSettingsPage(),
  };

  for (final entry in pages.entries) {
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
            notificationSettingsProvider.overrideWith(
              _GoldenNotificationSettings.new,
            ),
            notificationsQueryProvider.overrideWithValue(
              const <TevioNotification>[],
            ),
            unreadNotificationsCountQueryProvider.overrideWithValue(0),
          ],
          child: MaterialApp(theme: AppTheme.light(), home: entry.value),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(entry.value.runtimeType),
        matchesGoldenFile('settings_${entry.key}.png'),
      );
    });
  }
}

class _GoldenNotificationSettings extends NotificationSettingsController {
  @override
  NotificationSettings build() => const NotificationSettings();
}
