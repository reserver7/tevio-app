import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../../../shared/infrastructure/result/tevio_failure.dart';
import '../../../../shared/infrastructure/result/tevio_result.dart';
import '../../data/product_repository.dart';
import '../../domain/models/product_activity.dart';
import '../../domain/models/product_summary.dart';
import '../../domain/services/product_status_resolver.dart';
import 'product_activity_queries.dart';

final productRegistrationResultProvider = Provider<ProductRegistrationResult>((
  ref,
) {
  return ProductRegistrationResult(ref);
});

class ProductRegistrationResult {
  const ProductRegistrationResult(this._ref);

  final Ref _ref;
  static const _statusResolver = ProductStatusResolver();

  TevioResult<ProductSummary> registerProduct(ProductRegistrationInput input) {
    try {
      if (!input.isValid) {
        return const TevioFailureResult(
          TevioFailure(message: '필수 제품 정보를 확인해 주세요.'),
        );
      }

      final normalizedInput = input.normalized();
      final statusResult = _statusResolver.resolve(
        modelNumber: normalizedInput.modelNumber,
        receiptStatus: normalizedInput.receiptStatus,
      );
      final product = ProductSummary(
        id: normalizedInput.productId,
        name: normalizedInput.name,
        brand: normalizedInput.brand,
        modelNumber: normalizedInput.modelNumber,
        purchasedAt: normalizedInput.purchasedAt,
        purchaseStore: normalizedInput.purchaseStore,
        warrantyText: '365일 남음',
        returnText: '14일 남음',
        receiptStatus: normalizedInput.receiptStatus,
        status: statusResult.status,
        statusSummary: statusResult.summary,
        recommendedAction: statusResult.actionLabel,
        lastCheckedAt: DateTime.now(),
        recallAlertEnabled: normalizedInput.recallAlert,
        warrantyAlertEnabled: normalizedInput.warrantyAlert,
        returnAlertEnabled: normalizedInput.returnAlert,
      );

      final savedProduct = _ref
          .read(productCatalogProvider.notifier)
          .addProduct(product);

      _ref
          .read(productActivityCommandProvider)
          .record(
            ProductActivity(
              id: '${savedProduct.id}-registered',
              productId: savedProduct.id,
              occurredAtLabel: '방금',
              title: '제품이 등록됐어요',
              description:
                  '${savedProduct.status.label} · ${savedProduct.statusSummary} ${normalizedInput.alertSummary}',
            ),
          );

      return TevioSuccess(savedProduct);
    } on Exception {
      return const TevioFailureResult(
        TevioFailure(message: '제품을 등록하지 못했어요. 정보를 확인한 뒤 다시 시도해 주세요.'),
      );
    }
  }
}

class ProductRegistrationInput {
  const ProductRegistrationInput({
    required this.name,
    required this.brand,
    required this.modelNumber,
    required this.purchasedAt,
    required this.purchaseStore,
    this.receiptStatus = '보관됨',
    this.recallAlert = true,
    this.warrantyAlert = true,
    this.returnAlert = true,
  });

  final String name;
  final String brand;
  final String modelNumber;
  final String purchasedAt;
  final String purchaseStore;
  final String receiptStatus;
  final bool recallAlert;
  final bool warrantyAlert;
  final bool returnAlert;

  bool get isValid {
    return name.isNotEmpty &&
        brand.isNotEmpty &&
        (modelNumber.trim().isEmpty || hasValidModelNumber) &&
        (purchasedAt.trim().isEmpty || hasValidPurchaseDate);
  }

  bool get hasValidModelNumber {
    return RegExp(
      r'^[A-Za-z0-9가-힣][A-Za-z0-9가-힣._-]{2,}$',
    ).hasMatch(modelNumber.trim());
  }

  bool get hasValidPurchaseDate {
    final parts = purchasedAt.split('.');
    if (parts.length != 3) {
      return false;
    }

    final date = DateTime.tryParse(
      '${parts[0].padLeft(4, '0')}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}',
    );
    if (date == null) {
      return false;
    }

    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    return !date.isAfter(currentDate);
  }

  String get productId {
    final rawId = '${brand}_${name}_$modelNumber'
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9가-힣]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    if (rawId.isEmpty) {
      return 'registered-product';
    }

    return '$rawId-registered';
  }

  String get alertSummary {
    final enabledAlerts = [
      if (recallAlert) '리콜',
      if (warrantyAlert) '보증',
      if (returnAlert) '반품·교환',
    ];

    if (enabledAlerts.isEmpty) {
      return '등록한 알림은 없어요.';
    }

    return '${enabledAlerts.join(', ')} 알림을 설정했어요.';
  }

  ProductRegistrationInput normalized() {
    return ProductRegistrationInput(
      name: _valueOrDefault(name, '제품'),
      brand: _valueOrDefault(brand, '제조사 미상'),
      modelNumber: _valueOrDefault(modelNumber, '모델번호 미확인'),
      purchasedAt: _valueOrDefault(purchasedAt, '구매일 미상'),
      purchaseStore: _valueOrDefault(purchaseStore, '구매처 미상'),
      receiptStatus: _valueOrDefault(receiptStatus, '보관됨'),
      recallAlert: recallAlert,
      warrantyAlert: warrantyAlert,
      returnAlert: returnAlert,
    );
  }

  static String _valueOrDefault(String value, String defaultValue) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return defaultValue;
    }

    return trimmed;
  }
}
