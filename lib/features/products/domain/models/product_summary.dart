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

  ProductSummary copyWith({
    String? name,
    String? brand,
    String? modelNumber,
    String? purchasedAt,
    String? purchaseStore,
    String? warrantyText,
    String? returnText,
    String? receiptStatus,
    RightsStatus? status,
    String? statusSummary,
    String? recommendedAction,
  }) {
    return ProductSummary(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      modelNumber: modelNumber ?? this.modelNumber,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      warrantyText: warrantyText ?? this.warrantyText,
      returnText: returnText ?? this.returnText,
      receiptStatus: receiptStatus ?? this.receiptStatus,
      status: status ?? this.status,
      statusSummary: statusSummary ?? this.statusSummary,
      recommendedAction: recommendedAction ?? this.recommendedAction,
    );
  }
}
