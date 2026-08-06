import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../../products/domain/models/product_summary.dart';
import '../../../settings/presentation/state/notification_settings.dart';
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

  bool addIfAllowed({
    required TevioNotification notification,
    ProductSummary? product,
    bool devicePermissionGranted = true,
  }) {
    return _ref
        .read(notificationInboxProvider.notifier)
        .addIfAllowed(
          notification: notification,
          globalSettings: _ref.read(notificationSettingsProvider),
          product: product,
          devicePermissionGranted: devicePermissionGranted,
        );
  }

  void syncProductAlerts(List<ProductSummary> products) {
    for (final product in products) {
      final category = switch (product.status) {
        RightsStatus.urgent => TevioNotificationCategory.immediate,
        RightsStatus.actionRequired => TevioNotificationCategory.dueSoon,
        RightsStatus.detected => TevioNotificationCategory.infoRequired,
        RightsStatus.processing => TevioNotificationCategory.processing,
        RightsStatus.unknown => TevioNotificationCategory.infoRequired,
        RightsStatus.safe || RightsStatus.completed => null,
      };

      if (category == null) {
        continue;
      }

      addIfAllowed(
        product: product,
        notification: TevioNotification(
          id: 'status-${product.id}-${category.name}',
          category: category,
          status: product.status,
          productName: product.name,
          typeLabel: category.label,
          title: _titleFor(product),
          description: product.statusSummary,
          receivedAt: '지금',
          groupLabel: '오늘',
          actionLabel: product.recommendedAction,
          route: '/products/${product.id}',
        ),
      );
    }
  }

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

  List<TevioNotification> removeForProduct(String productId) {
    return _ref
        .read(notificationInboxProvider.notifier)
        .removeForProduct(productId);
  }

  void restoreMany(List<TevioNotification> notifications) {
    _ref.read(notificationInboxProvider.notifier).restoreMany(notifications);
  }

  String _titleFor(ProductSummary product) {
    return switch (product.status) {
      RightsStatus.urgent => '${product.name} 리콜 확인이 필요해요',
      RightsStatus.actionRequired => '${product.name} 보증 정보를 확인해 주세요',
      RightsStatus.detected => '${product.name} 정보를 보완해 주세요',
      RightsStatus.unknown => '${product.name} 정보를 더 확인해 주세요',
      RightsStatus.processing => '${product.name} 처리 상태가 진행 중이에요',
      RightsStatus.safe || RightsStatus.completed => product.statusSummary,
    };
  }
}
