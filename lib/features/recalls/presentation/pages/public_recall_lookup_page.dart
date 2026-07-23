import 'package:flutter/material.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class PublicRecallLookupPage extends StatelessWidget {
  const PublicRecallLookupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TevioAppBar(title: '공개 리콜 조회'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: const [
            Text('리콜 정보를 확인하세요', style: TevioTypography.titleLarge),
            SizedBox(height: TevioSpacing.xs),
            Text(
              '제품명, 제조사, 모델번호로 공식 리콜 가능성을 조회합니다.',
              style: TevioTypography.bodyMedium,
            ),
            SizedBox(height: TevioSpacing.xl),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_outlined),
                hintText: '제품명, 제조사, 모델번호 검색',
              ),
            ),
            SizedBox(height: TevioSpacing.lg),
            TevioEmptyState(
              title: '아직 조회 결과가 없어요',
              description: '리콜 유사도 결과는 확정 정보처럼 표시하지 않고 공식 근거와 함께 안내합니다.',
            ),
          ],
        ),
      ),
    );
  }
}
