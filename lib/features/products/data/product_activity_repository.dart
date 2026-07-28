import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/product_activity.dart';
import 'mappers/product_mapper.dart';

abstract interface class ProductActivityRepository {
  List<ProductActivity> watchActivities();

  void record(ProductActivity activity);
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
}
