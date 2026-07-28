class NotificationDto {
  const NotificationDto({
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
    required this.route,
    this.isRead = false,
  });

  final String id;
  final String category;
  final String status;
  final String productName;
  final String typeLabel;
  final String title;
  final String description;
  final String receivedAt;
  final String groupLabel;
  final String actionLabel;
  final String route;
  final bool isRead;
}
