import '../../../../shared/design_system/tevio_design_system.dart';

enum TevioNotificationCategory {
  immediate,
  dueSoon,
  infoRequired,
  processing,
  general,
}

class TevioNotification {
  const TevioNotification({
    required this.id,
    required this.category,
    required this.status,
    required this.productName,
    required this.typeLabel,
    required this.title,
    required this.description,
    required this.receivedAt,
    required this.groupLabel,
    required this.actionLabel,
    this.isRead = false,
  });

  final String id;
  final TevioNotificationCategory category;
  final RightsStatus status;
  final String productName;
  final String typeLabel;
  final String title;
  final String description;
  final String receivedAt;
  final String groupLabel;
  final String actionLabel;
  final bool isRead;
}

extension TevioNotificationCategoryLabel on TevioNotificationCategory {
  String get label {
    return switch (this) {
      TevioNotificationCategory.immediate => '안전',
      TevioNotificationCategory.dueSoon => '기한',
      TevioNotificationCategory.infoRequired => '요청',
      TevioNotificationCategory.processing => '처리',
      TevioNotificationCategory.general => '안내',
    };
  }
}
