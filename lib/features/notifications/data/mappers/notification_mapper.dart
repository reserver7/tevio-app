import '../../../../shared/design_system/tevio_design_system.dart';
import '../../domain/models/tevio_notification.dart';
import '../dtos/notification_dto.dart';

extension NotificationDtoMapper on NotificationDto {
  TevioNotification toDomain() {
    return TevioNotification(
      id: id,
      category: _categoryFromCode(category),
      status: _rightsStatusFromCode(status),
      productName: productName,
      typeLabel: typeLabel,
      title: title,
      description: description,
      receivedAt: receivedAt,
      groupLabel: groupLabel,
      actionLabel: actionLabel,
      route: route,
      isRead: isRead,
    );
  }
}

extension TevioNotificationMapper on TevioNotification {
  NotificationDto toDto() {
    return NotificationDto(
      id: id,
      category: category.code,
      status: status.code,
      productName: productName,
      typeLabel: typeLabel,
      title: title,
      description: description,
      receivedAt: receivedAt,
      groupLabel: groupLabel,
      actionLabel: actionLabel,
      route: route,
      isRead: isRead,
    );
  }
}

TevioNotificationCategory _categoryFromCode(String code) {
  return switch (code) {
    'immediate' => TevioNotificationCategory.immediate,
    'dueSoon' => TevioNotificationCategory.dueSoon,
    'infoRequired' => TevioNotificationCategory.infoRequired,
    'processing' => TevioNotificationCategory.processing,
    _ => TevioNotificationCategory.general,
  };
}

RightsStatus _rightsStatusFromCode(String code) {
  return switch (code) {
    'safe' => RightsStatus.safe,
    'detected' => RightsStatus.detected,
    'actionRequired' => RightsStatus.actionRequired,
    'urgent' => RightsStatus.urgent,
    'processing' => RightsStatus.processing,
    'completed' => RightsStatus.completed,
    _ => RightsStatus.unknown,
  };
}

extension _NotificationCategoryCode on TevioNotificationCategory {
  String get code {
    return switch (this) {
      TevioNotificationCategory.immediate => 'immediate',
      TevioNotificationCategory.dueSoon => 'dueSoon',
      TevioNotificationCategory.infoRequired => 'infoRequired',
      TevioNotificationCategory.processing => 'processing',
      TevioNotificationCategory.general => 'general',
    };
  }
}

extension _RightsStatusCode on RightsStatus {
  String get code {
    return switch (this) {
      RightsStatus.safe => 'safe',
      RightsStatus.detected => 'detected',
      RightsStatus.actionRequired => 'actionRequired',
      RightsStatus.urgent => 'urgent',
      RightsStatus.processing => 'processing',
      RightsStatus.completed => 'completed',
      RightsStatus.unknown => 'unknown',
    };
  }
}
