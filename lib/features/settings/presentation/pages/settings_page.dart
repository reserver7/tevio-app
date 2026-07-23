import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../shared/design_system/tevio_design_system.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(appEnvironmentProvider);

    return Scaffold(
      appBar: const TevioAppBar(title: '설정', automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            const TevioCard(
              child: Row(
                children: [
                  TevioLogo(variant: TevioLogoVariant.symbol, size: 44),
                  SizedBox(width: TevioSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TEVIO - 테비오', style: TevioTypography.titleMedium),
                        SizedBox(height: TevioSpacing.xxs),
                        Text('구매 이후까지, 테비오', style: TevioTypography.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '계정'),
            const SizedBox(height: TevioSpacing.sm),
            const TevioCard(
              child: Column(
                children: [
                  _SettingsRow(icon: Icons.person_outline, title: '프로필'),
                  Divider(height: TevioSpacing.xl),
                  _SettingsRow(icon: Icons.groups_outlined, title: '가족 관리'),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '알림'),
            const SizedBox(height: TevioSpacing.sm),
            const TevioCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                  ),
                  Divider(height: TevioSpacing.xl),
                  _SettingsRow(icon: Icons.bedtime_outlined, title: '조용한 시간'),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '앱 정보'),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              child: Column(
                children: [
                  TevioInfoRow(label: '환경', value: environment.name),
                  const Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: 'API URL', value: environment.apiBaseUrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: TevioColors.primary),
        const SizedBox(width: TevioSpacing.md),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const Icon(Icons.chevron_right, color: TevioColors.textTertiary),
      ],
    );
  }
}
