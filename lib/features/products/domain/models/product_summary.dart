import '../../../../shared/design_system/tevio_design_system.dart';

class ProductSummary {
  const ProductSummary({
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
  final RightsStatus status;
  final String statusSummary;
  final String recommendedAction;
}
