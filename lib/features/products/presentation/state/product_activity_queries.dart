import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_activity_repository.dart';
import '../../domain/models/product_activity.dart';

final productActivitiesQueryProvider =
    Provider.family<List<ProductActivity>, String>((ref, productId) {
      final activities = ref.watch(productActivityLogProvider);

      return [
        for (final activity in activities)
          if (activity.productId == productId) activity,
      ];
    });

final productActivityCommandProvider = Provider<ProductActivityCommand>((ref) {
  return ProductActivityCommand(ref);
});

class ProductActivityCommand {
  const ProductActivityCommand(this._ref);

  final Ref _ref;

  void record(ProductActivity activity) {
    _ref.read(productActivityLogProvider.notifier).record(activity);
  }
}
