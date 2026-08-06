import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/design_system/tevio_design_system.dart';
import '../../products/domain/models/product_summary.dart';
import '../../settings/presentation/state/notification_settings.dart';
import '../domain/models/tevio_notification.dart';
import 'dtos/notification_dto.dart';
import 'mappers/notification_mapper.dart';
import 'mock_notifications.dart';

abstract interface class NotificationRepository {
  List<TevioNotification> watchNotifications();

  bool addIfAllowed({
    required TevioNotification notification,
    required NotificationSettings globalSettings,
    ProductSummary? product,
    bool devicePermissionGranted = true,
  });

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

  List<TevioNotification> removeForProduct(String productId);

  void restoreMany(List<TevioNotification> notifications);
}

final notificationInboxProvider =
    NotifierProvider<NotificationInbox, List<TevioNotification>>(
      NotificationInbox.new,
    );

class NotificationInbox extends Notifier<List<TevioNotification>>
    implements NotificationRepository {
  static const _storageKey = 'notifications.inbox';

  @override
  List<TevioNotification> build() {
    final fallback = [for (final dto in mockNotificationDtos) dto.toDomain()];
    unawaited(_restore(fallback));
    return fallback;
  }

  @override
  List<TevioNotification> watchNotifications() {
    return state;
  }

  @override
  bool addIfAllowed({
    required TevioNotification notification,
    required NotificationSettings globalSettings,
    ProductSummary? product,
    bool devicePermissionGranted = true,
  }) {
    final allowed = NotificationPolicy.allows(
      category: notification.category,
      globalSettings: globalSettings,
      product: product,
      devicePermissionGranted: devicePermissionGranted,
    );

    if (!allowed ||
        state.any(
          (item) =>
              item.id == notification.id ||
              (item.route == notification.route &&
                  item.category == notification.category),
        )) {
      return false;
    }

    state = [notification, ...state];
    unawaited(_persist());
    return true;
  }

  @override
  void markAsRead(String id) {
    state = [
      for (final notification in state)
        notification.id == id
            ? notification.copyWith(isRead: true)
            : notification,
    ];
    unawaited(_persist());
  }

  @override
  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
    unawaited(_persist());
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
    unawaited(_persist());
  }

  @override
  void remove(String id) {
    state = [
      for (final notification in state)
        if (notification.id != id) notification,
    ];
    unawaited(_persist());
  }

  @override
  void restore(TevioNotification notification) {
    final alreadyExists = state.any((item) => item.id == notification.id);

    if (alreadyExists) {
      return;
    }

    state = [notification, ...state];
    unawaited(_persist());
  }

  @override
  List<TevioNotification> removeForProduct(String productId) {
    final productRoute = '/products/$productId';
    final removed = [
      for (final notification in state)
        if (notification.route == productRoute) notification,
    ];
    state = [
      for (final notification in state)
        if (notification.route != productRoute) notification,
    ];
    unawaited(_persist());
    return removed;
  }

  @override
  void restoreMany(List<TevioNotification> notifications) {
    state = [
      ...notifications.where(
        (notification) => !state.any((item) => item.id == notification.id),
      ),
      ...state,
    ];
    unawaited(_persist());
  }

  Future<void> _restore(List<TevioNotification> fallback) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);

    if (!ref.mounted || encoded == null) {
      return;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        return;
      }

      state = [
        for (final item in decoded)
          if (item is Map<String, dynamic>) _dtoFromJson(item).toDomain(),
      ];
    } on Object {
      state = fallback;
    }
  }

  NotificationDto _dtoFromJson(Map<String, dynamic> item) {
    return NotificationDto(
      id: item['id'] as String,
      category: item['category'] as String,
      status: item['status'] as String,
      productName: item['productName'] as String,
      typeLabel: item['typeLabel'] as String,
      title: item['title'] as String,
      description: item['description'] as String,
      receivedAt: item['receivedAt'] as String,
      groupLabel: item['groupLabel'] as String,
      actionLabel: item['actionLabel'] as String,
      route: item['route'] as String,
      isRead: item['isRead'] as bool? ?? false,
    );
  }

  Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    final payload = [
      for (final notification in state) _jsonFromDto(notification.toDto()),
    ];
    await preferences.setString(_storageKey, jsonEncode(payload));
  }

  Map<String, Object?> _jsonFromDto(NotificationDto dto) {
    return {
      'id': dto.id,
      'category': dto.category,
      'status': dto.status,
      'productName': dto.productName,
      'typeLabel': dto.typeLabel,
      'title': dto.title,
      'description': dto.description,
      'receivedAt': dto.receivedAt,
      'groupLabel': dto.groupLabel,
      'actionLabel': dto.actionLabel,
      'route': dto.route,
      'isRead': dto.isRead,
    };
  }
}
