import 'package:flutter/material.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TevioAppBar(title: '제품 상세'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: const [
            TevioCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TevioStatusBadge(status: RightsStatus.urgent),
                  SizedBox(height: TevioSpacing.md),
                  Text('무선청소기', style: TevioTypography.titleLarge),
                  SizedBox(height: TevioSpacing.xs),
                  Text('XYZ · VC-2401', style: TevioTypography.bodyMedium),
                ],
              ),
            ),
            SizedBox(height: TevioSpacing.lg),
            TevioSectionHeader(title: '권리 요약'),
            SizedBox(height: TevioSpacing.sm),
            TevioRightsCard(
              status: RightsStatus.urgent,
              productName: '무선청소기',
              title: '리콜 가능성이 감지됐어요',
              description: '모델번호가 공식 리콜 정보와 유사합니다. 확정 전 공식 페이지 확인이 필요해요.',
              dueText: '즉시 확인 권장',
              actionLabel: '공식 정보 확인',
            ),
            SizedBox(height: TevioSpacing.lg),
            TevioSectionHeader(title: '제품 정보'),
            SizedBox(height: TevioSpacing.sm),
            TevioCard(
              child: Column(
                children: [
                  TevioInfoRow(label: '구매일', value: '2025.11.03'),
                  Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '구매처', value: '온라인 스토어'),
                  Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '영수증', value: '보관됨'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
