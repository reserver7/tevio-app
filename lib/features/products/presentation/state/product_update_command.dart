import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../../../shared/infrastructure/result/tevio_failure.dart';
import '../../../../shared/infrastructure/result/tevio_result.dart';
import '../../data/product_repository.dart';
import '../../domain/models/product_summary.dart';

final productUpdateCommandProvider = Provider<ProductUpdateCommand>((ref) {
  return ProductUpdateCommand(ref);
});

class ProductUpdateCommand {
  ProductUpdateCommand(this._ref);

  final Ref _ref;
  final Set<String> _rechecking = {};

  Future<void> recheck(ProductSummary product) async {
    if (!_rechecking.add(product.id)) {
      return;
    }

    final processing = product.copyWith(
      status: RightsStatus.processing,
      statusSummary: '저장된 정보로 권리 상태를 다시 확인하고 있어요.',
      recommendedAction: '확인 상태 보기',
    );
    save(processing);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    save(
      processing.copyWith(
        status: RightsStatus.safe,
        statusSummary: '최근 확인 기준으로 확인할 문제는 없어요.',
        recommendedAction: '상태 상세 보기',
        lastCheckedAt: DateTime.now(),
      ),
    );
    _rechecking.remove(product.id);
  }

  TevioResult<ProductSummary> save(ProductSummary product) {
    try {
      final savedProduct = _ref
          .read(productCatalogProvider.notifier)
          .updateProduct(product);

      return TevioSuccess(savedProduct);
    } on Exception {
      return const TevioFailureResult(
        TevioFailure(message: '제품 정보를 저장하지 못했어요. 잠시 후 다시 시도해 주세요.'),
      );
    }
  }

  TevioResult<ProductSummary> delete(ProductSummary product) {
    try {
      final removed = _ref
          .read(productCatalogProvider.notifier)
          .removeProduct(product.id);

      if (removed == null) {
        return const TevioFailureResult(
          TevioFailure(message: '제품을 찾을 수 없어 삭제하지 못했어요.'),
        );
      }

      return TevioSuccess(removed);
    } on Exception {
      return const TevioFailureResult(
        TevioFailure(message: '제품을 삭제하지 못했어요. 잠시 후 다시 시도해 주세요.'),
      );
    }
  }

  void restore(ProductSummary product) {
    _ref.read(productCatalogProvider.notifier).restoreProduct(product);
  }
}
