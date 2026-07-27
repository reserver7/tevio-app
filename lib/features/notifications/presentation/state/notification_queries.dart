import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notification_repository.dart';
import '../../domain/models/tevio_notification.dart';

final notificationsQueryProvider = Provider<List<TevioNotification>>((ref) {
  return ref.watch(notificationInboxProvider);
});

final unreadNotificationsCountQueryProvider = Provider<int>((ref) {
  return ref
      .watch(notificationsQueryProvider)
      .where((notification) => !notification.isRead)
      .length;
});

final notificationCommandProvider = Provider<NotificationCommands>((ref) {
  return NotificationCommands(ref);
});

class NotificationCommands {
  const NotificationCommands(this._ref);

  final Ref _ref;

  void markAsRead(String id) {
    _ref.read(notificationInboxProvider.notifier).markAsRead(id);
  }

  void markAllAsRead() {
    _ref.read(notificationInboxProvider.notifier).markAllAsRead();
  }

  void resolveProductNotification({
    required String productId,
    required TevioNotificationCategory category,
    required String title,
    required String description,
  }) {
    _ref
        .read(notificationInboxProvider.notifier)
        .resolveProductNotification(
          productId: productId,
          category: category,
          title: title,
          description: description,
        );
  }

  void remove(String id) {
    _ref.read(notificationInboxProvider.notifier).remove(id);
  }

  void restore(TevioNotification notification) {
    _ref.read(notificationInboxProvider.notifier).restore(notification);
  }
}
