class ProductDto {
  const ProductDto({
    required this.id,
    required this.name,
    required this.brand,
    required this.modelNumber,
    required this.purchasedAt,
    required this.purchaseStore,
    required this.warrantyText,
    required this.returnText,
    required this.receiptStatus,
    required this.status,
    required this.statusSummary,
    required this.recommendedAction,
    this.recallAlertEnabled = true,
    this.warrantyAlertEnabled = true,
    this.returnAlertEnabled = true,
  });

  final String id;
  final String name;
  final String brand;
  final String modelNumber;
  final String purchasedAt;
  final String purchaseStore;
  final String warrantyText;
  final String returnText;
  final String receiptStatus;
  final String status;
  final String statusSummary;
  final String recommendedAction;
  final bool recallAlertEnabled;
  final bool warrantyAlertEnabled;
  final bool returnAlertEnabled;
}
