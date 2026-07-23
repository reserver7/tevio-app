import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const TevioLogo(variant: TevioLogoVariant.symbol, size: 32),
        actions: [
          IconButton(
            tooltip: '설정',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            Text('구매 이후의 모든 권리,\n테비오가 먼저 챙깁니다.', style: textTheme.displaySmall),
            const SizedBox(height: TevioSpacing.sm),
            Text(
              '구매 이후의 권리를 발견하고, 가장 필요한 행동으로 연결합니다.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: TevioSpacing.xl),
            TevioButton(
              label: '제품 등록하기',
              icon: Icons.add_box_outlined,
              onPressed: () => context.push('/register'),
            ),
            const SizedBox(height: TevioSpacing.sm),
            TevioButton(
              label: '공개 리콜 조회',
              icon: Icons.search_outlined,
              variant: TevioButtonVariant.secondary,
              onPressed: () => context.push('/recalls'),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '지금 확인할 권리'),
            const SizedBox(height: TevioSpacing.sm),
            TevioRightsCard(
              status: RightsStatus.urgent,
              productName: '무선청소기',
              title: '리콜 가능성이 감지됐어요',
              description: '등록된 모델번호와 유사한 공식 리콜 정보가 있어요.',
              dueText: '즉시 확인 권장',
              actionLabel: '리콜 내용 확인',
              onPressed: () => context.push('/recalls'),
            ),
            const SizedBox(height: TevioSpacing.sm),
            const TevioRightsCard(
              status: RightsStatus.actionRequired,
              productName: '노트북',
              title: '보증 만료가 가까워요',
              description: '무상보증 종료 전 필요한 점검과 서류를 확인하세요.',
              dueText: '28일 남음',
              actionLabel: '보증 정보 보기',
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '테비오가 하는 일'),
            const SizedBox(height: TevioSpacing.sm),
            const _BrandSteps(),
          ],
        ),
      ),
    );
  }
}

class _BrandSteps extends StatelessWidget {
  const _BrandSteps();

  @override
  Widget build(BuildContext context) {
    return const TevioCard(
      child: Column(
        children: [
          _StepRow(
            icon: Icons.receipt_long_outlined,
            title: '등록',
            description: '영수증과 제품 정보를 간편하게 모아요.',
          ),
          Divider(height: TevioSpacing.xl),
          _StepRow(
            icon: Icons.radar_outlined,
            title: '감지',
            description: '리콜, 보증 만료, 반품과 교환 가능 시점을 확인해요.',
          ),
          Divider(height: TevioSpacing.xl),
          _StepRow(
            icon: Icons.psychology_alt_outlined,
            title: '판단',
            description: '지금 필요한 권리와 대응 시점을 정리해요.',
          ),
          Divider(height: TevioSpacing.xl),
          _StepRow(
            icon: Icons.near_me_outlined,
            title: '행동',
            description: 'A/S, 교환, 반품 같은 실제 행동으로 연결해요.',
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: TevioColors.primaryBackground,
            borderRadius: TevioRadius.mediumBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.all(TevioSpacing.sm),
            child: Icon(icon, color: TevioColors.primary),
          ),
        ),
        const SizedBox(width: TevioSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TevioSpacing.xxs),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
