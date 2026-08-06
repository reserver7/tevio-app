import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/product_activity.dart';
import 'mappers/product_mapper.dart';

abstract interface class ProductActivityRepository {
  List<ProductActivity> watchActivities();

  void record(ProductActivity activity);

  List<ProductActivity> removeForProduct(String productId);

  void restoreMany(List<ProductActivity> activities);
}

final productActivityLogProvider =
    NotifierProvider<ProductActivityLog, List<ProductActivity>>(
      ProductActivityLog.new,
    );

class ProductActivityLog extends Notifier<List<ProductActivity>>
    implements ProductActivityRepository {
  @override
  List<ProductActivity> build() {
    return const [];
  }

  @override
  List<ProductActivity> watchActivities() {
    return state;
  }

  @override
  void record(ProductActivity activity) {
    final dto = activity.toDto();

    state = [
      dto.toDomain(),
      for (final item in state)
        if (item.id != dto.id) item,
    ];
  }

  @override
  List<ProductActivity> removeForProduct(String productId) {
    final removed = [
      for (final activity in state)
        if (activity.productId == productId) activity,
    ];
    state = [
      for (final activity in state)
        if (activity.productId != productId) activity,
    ];
    return removed;
  }

  @override
  void restoreMany(List<ProductActivity> activities) {
    state = [
      ...activities.where(
        (activity) => !state.any((item) => item.id == activity.id),
      ),
      ...state,
    ];
  }
}
