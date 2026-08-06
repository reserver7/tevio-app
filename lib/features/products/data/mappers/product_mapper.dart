import '../../../../shared/design_system/tevio_design_system.dart';
import '../../domain/models/product_activity.dart';
import '../../domain/models/product_summary.dart';
import '../dtos/product_activity_dto.dart';
import '../dtos/product_dto.dart';

extension ProductDtoMapper on ProductDto {
  ProductSummary toDomain() {
    return ProductSummary(
      id: id,
      name: name,
      brand: brand,
      modelNumber: modelNumber,
      purchasedAt: purchasedAt,
      purchaseStore: purchaseStore,
      warrantyText: warrantyText,
      returnText: returnText,
      receiptStatus: receiptStatus,
      status: _rightsStatusFromCode(status),
      statusSummary: statusSummary,
      recommendedAction: recommendedAction,
      recallAlertEnabled: recallAlertEnabled,
      warrantyAlertEnabled: warrantyAlertEnabled,
      returnAlertEnabled: returnAlertEnabled,
      lastCheckedAt: lastCheckedAt,
    );
  }
}

extension ProductSummaryMapper on ProductSummary {
  ProductDto toDto() {
    return ProductDto(
      id: id,
      name: name,
      brand: brand,
      modelNumber: modelNumber,
      purchasedAt: purchasedAt,
      purchaseStore: purchaseStore,
      warrantyText: warrantyText,
      returnText: returnText,
      receiptStatus: receiptStatus,
      status: status.code,
      statusSummary: statusSummary,
      recommendedAction: recommendedAction,
      recallAlertEnabled: recallAlertEnabled,
      warrantyAlertEnabled: warrantyAlertEnabled,
      returnAlertEnabled: returnAlertEnabled,
      lastCheckedAt: lastCheckedAt,
    );
  }
}

extension ProductActivityDtoMapper on ProductActivityDto {
  ProductActivity toDomain() {
    return ProductActivity(
      id: id,
      productId: productId,
      occurredAtLabel: occurredAtLabel,
      title: title,
      description: description,
    );
  }
}

extension ProductActivityMapper on ProductActivity {
  ProductActivityDto toDto() {
    return ProductActivityDto(
      id: id,
      productId: productId,
      occurredAtLabel: occurredAtLabel,
      title: title,
      description: description,
    );
  }
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
