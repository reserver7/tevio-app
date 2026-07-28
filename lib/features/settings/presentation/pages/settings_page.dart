import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../shared/design_system/tevio_design_system.dart';
import '../state/my_tab_session.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(appEnvironmentProvider);
    final session = ref.watch(myTabSessionProvider);

    return Scaffold(
      key: ValueKey('my-tab-$session'),
      appBar: const TevioAppBar(title: '마이', automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            const TevioSectionHeader(title: '계정'),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              child: Column(
                children: [
                  _SettingsRow(icon: Icons.person_outline, title: '내 프로필'),
                  Divider(height: TevioSpacing.xl),
                  _SettingsRow(icon: Icons.groups_outlined, title: '가족 관리'),
                  Divider(height: TevioSpacing.xl),
                  _SettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    title: '개인정보 관리',
                  ),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '알림'),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                    onTap: () => context.push('/settings/notifications'),
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
                  const _SettingsRow(
                    icon: Icons.support_agent_outlined,
                    title: '고객센터',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  const _SettingsRow(
                    icon: Icons.campaign_outlined,
                    title: '공지사항',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  const _SettingsRow(
                    icon: Icons.description_outlined,
                    title: '이용약관',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  const _SettingsRow(
                    icon: Icons.policy_outlined,
                    title: '개인정보처리방침',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  const _SettingsRow(
                    icon: Icons.info_outline,
                    title: '앱 정보',
                    trailing: '1.0.0',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '환경', value: environment.name),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '계정 관리'),
            const SizedBox(height: TevioSpacing.sm),
            const TevioCard(
              child: Column(
                children: [
                  _SettingsRow(icon: Icons.logout, title: '로그아웃'),
                  Divider(height: TevioSpacing.xl),
                  _SettingsRow(
                    icon: Icons.delete_outline,
                    title: '회원 탈퇴',
                    isDanger: true,
                  ),
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
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.isDanger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final bool isDanger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? TevioColors.danger : TevioColors.primary;
    final textColor = isDanger ? TevioColors.danger : TevioColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: TevioRadius.mediumBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TevioSpacing.xs),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: TevioSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: textColor),
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: Theme.of(context).textTheme.bodyMedium)
            else
              const Icon(Icons.chevron_right, color: TevioColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
