import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/tevio_design_system.dart';
import '../domain/models/tevio_notification.dart';
import 'mock_notifications.dart';

abstract interface class NotificationRepository {
  List<TevioNotification> watchNotifications();

  void markAsRead(String id);

  void markAllAsRead();

  void resolveProductNotification({
    required String productId,
    required TevioNotificationCategory category,
    required String title,
    required String description,
  });

  void remove(String id);

  void restore(TevioNotification notification);
}

final notificationInboxProvider =
    NotifierProvider<NotificationInbox, List<TevioNotification>>(
      NotificationInbox.new,
    );

class NotificationInbox extends Notifier<List<TevioNotification>>
    implements NotificationRepository {
  @override
  List<TevioNotification> build() {
    return mockNotifications;
  }

  @override
  List<TevioNotification> watchNotifications() {
    return state;
  }

  @override
  void markAsRead(String id) {
    state = [
      for (final notification in state)
        notification.id == id
            ? notification.copyWith(isRead: true)
            : notification,
    ];
  }

  @override
  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
  }

  @override
  void resolveProductNotification({
    required String productId,
    required TevioNotificationCategory category,
    required String title,
    required String description,
  }) {
    final productRoute = '/products/$productId';

    state = [
      for (final notification in state)
        notification.route == productRoute && notification.category == category
            ? notification.copyWith(
                status: RightsStatus.completed,
                typeLabel: '확인 완료',
                title: title,
                description: description,
                receivedAt: '방금',
                groupLabel: '오늘',
                actionLabel: '내역 보기',
                isRead: true,
              )
            : notification,
    ];
  }

  @override
  void remove(String id) {
    state = [
      for (final notification in state)
        if (notification.id != id) notification,
    ];
  }

  @override
  void restore(TevioNotification notification) {
    final alreadyExists = state.any((item) => item.id == notification.id);

    if (alreadyExists) {
      return;
    }

    state = [notification, ...state];
  }
}
