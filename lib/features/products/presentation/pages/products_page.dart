import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../state/product_queries.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productSummariesQueryProvider);

    return Scaffold(
      appBar: const TevioAppBar(title: '제품', automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          key: const PageStorageKey('products-scroll'),
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            Text(
              '제품별 권리 상태와 다음 행동을 확인하세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TevioSpacing.lg),
            for (final product in products) ...[
              TevioProductCard(
                name: product.name,
                brand: product.brand,
                modelNumber: product.modelNumber,
                purchasedAt: product.purchasedAt,
                warrantyText: product.warrantyText,
                status: product.status,
                summary: product.statusSummary,
                actionLabel: product.recommendedAction,
                onTap: () => context.push('/products/${product.id}'),
              ),
              const SizedBox(height: TevioSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
