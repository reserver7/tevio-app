import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TevioAppBar(title: '제품', automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            const TevioSectionHeader(title: '내 제품'),
            const SizedBox(height: TevioSpacing.sm),
            _ProductCard(
              name: '무선청소기',
              brand: 'XYZ',
              model: 'VC-2401',
              purchasedAt: '2025.11.03',
              status: RightsStatus.urgent,
              action: '리콜 내용 확인',
              onTap: () => context.push('/products/1'),
            ),
            const SizedBox(height: TevioSpacing.sm),
            _ProductCard(
              name: '노트북',
              brand: 'Sample',
              model: 'NB-16P',
              purchasedAt: '2025.08.20',
              status: RightsStatus.actionRequired,
              action: '보증 정보 확인',
              onTap: () => context.push('/products/2'),
            ),
            const SizedBox(height: TevioSpacing.sm),
            _ProductCard(
              name: '공기청정기',
              brand: 'ABC',
              model: 'ABC-123',
              purchasedAt: '2024.03.10',
              status: RightsStatus.safe,
              action: '상세보기',
              onTap: () => context.push('/products/3'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.brand,
    required this.model,
    required this.purchasedAt,
    required this.status,
    required this.action,
    required this.onTap,
  });

  final String name;
  final String brand;
  final String model;
  final String purchasedAt;
  final RightsStatus status;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: TevioColors.primaryBackground,
              borderRadius: TevioRadius.mediumBorder,
            ),
            child: const Padding(
              padding: EdgeInsets.all(TevioSpacing.md),
              child: Icon(Icons.devices_other, color: TevioColors.primary),
            ),
          ),
          const SizedBox(width: TevioSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TevioStatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: TevioSpacing.xs),
                Text(
                  '$brand · $model · 구매일 $purchasedAt',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: TevioSpacing.sm),
                Text(
                  action,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: TevioColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
