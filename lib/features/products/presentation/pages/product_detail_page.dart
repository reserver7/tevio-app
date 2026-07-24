import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_products.dart';
import '../../../../shared/design_system/tevio_design_system.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final product = findMockProduct(
      GoRouterState.of(context).pathParameters['id'],
    );

    return Scaffold(
      appBar: const TevioAppBar(title: '제품 상세'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            TevioCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TevioStatusBadge(status: product.status),
                  const SizedBox(height: TevioSpacing.md),
                  Text(product.name, style: TevioTypography.titleLarge),
                  const SizedBox(height: TevioSpacing.xs),
                  Text(
                    '${product.brand} · ${product.modelNumber}',
                    style: TevioTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.lg),
            const TevioSectionHeader(title: '권리 요약'),
            const SizedBox(height: TevioSpacing.sm),
            TevioRightsCard(
              status: product.status,
              productName: product.name,
              title: product.recommendedAction,
              description: product.statusSummary,
              dueText: product.warrantyText,
              actionLabel: product.recommendedAction,
            ),
            const SizedBox(height: TevioSpacing.lg),
            const TevioSectionHeader(title: '제품 정보'),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              child: Column(
                children: [
                  TevioInfoRow(label: '구매일', value: product.purchasedAt),
                  const Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '구매처', value: product.purchaseStore),
                  const Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '영수증', value: product.receiptStatus),
                  const Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '반품·교환', value: product.returnText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
