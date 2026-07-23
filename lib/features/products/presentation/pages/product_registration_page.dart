import 'package:flutter/material.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class ProductRegistrationPage extends StatelessWidget {
  const ProductRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TevioAppBar(title: '제품 등록'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: const [
            Text('테비오에 내 제품을 등록하세요', style: TevioTypography.titleLarge),
            SizedBox(height: TevioSpacing.xs),
            Text(
              '영수증과 제품 정보를 모아두면 리콜, 보증, A/S 시점을 계속 확인할 수 있어요.',
              style: TevioTypography.bodyMedium,
            ),
            SizedBox(height: TevioSpacing.xl),
            TevioSectionHeader(title: '등록 방식'),
            SizedBox(height: TevioSpacing.sm),
            _RegistrationOption(
              icon: Icons.camera_alt_outlined,
              title: '영수증 촬영',
              description: '구매 정보를 빠르게 읽어올 준비를 합니다.',
            ),
            SizedBox(height: TevioSpacing.sm),
            _RegistrationOption(
              icon: Icons.image_outlined,
              title: '앨범에서 선택',
              description: '저장된 영수증 또는 주문 화면을 사용합니다.',
            ),
            SizedBox(height: TevioSpacing.sm),
            _RegistrationOption(
              icon: Icons.keyboard_alt_outlined,
              title: '모델번호 직접 입력',
              description: '제품 라벨의 모델번호로 권리 정보를 확인합니다.',
            ),
            SizedBox(height: TevioSpacing.xl),
            TevioSectionHeader(title: '진행 단계'),
            SizedBox(height: TevioSpacing.sm),
            TevioCard(
              child: Column(
                children: [
                  TevioInfoRow(label: '1단계', value: '등록 방식 선택'),
                  Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '2단계', value: '제품 정보 확인'),
                  Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '3단계', value: '알림 항목 선택'),
                ],
              ),
            ),
            SizedBox(height: TevioSpacing.xl),
            _FieldLabel('제품명'),
            TextField(decoration: InputDecoration(hintText: '예: 공기청정기')),
            SizedBox(height: TevioSpacing.md),
            _FieldLabel('제조사'),
            TextField(decoration: InputDecoration(hintText: '예: ABC')),
            SizedBox(height: TevioSpacing.md),
            _FieldLabel('모델번호'),
            TextField(decoration: InputDecoration(hintText: '예: ABC-123')),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(TevioSpacing.lg),
        child: TevioButton(
          label: '등록 계속하기',
          icon: Icons.arrow_forward_outlined,
          onPressed: null,
        ),
      ),
    );
  }
}

class _RegistrationOption extends StatelessWidget {
  const _RegistrationOption({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      child: Row(
        children: [
          Icon(icon, color: TevioColors.primary),
          const SizedBox(width: TevioSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: TevioSpacing.xxs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TevioSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
