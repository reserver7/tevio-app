import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../shared/design_system/tevio_design_system.dart';
import '../state/my_tab_session.dart';
import '../state/theme_mode.dart';

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
                  TevioListRow(icon: Icons.person_outline, title: '내 프로필'),
                  Divider(height: TevioSpacing.xl),
                  TevioListRow(icon: Icons.groups_outlined, title: '가족 관리'),
                  Divider(height: TevioSpacing.xl),
                  TevioListRow(
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
                  TevioListRow(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                    onTap: () => context.push('/settings/notifications'),
                  ),
                  Divider(height: TevioSpacing.xl),
                  TevioListRow(
                    icon: Icons.brightness_6_outlined,
                    title: '화면 설정',
                    value: _themeModeLabel(ref.watch(themeModeProvider)),
                    onTap: () => _showThemeModeSheet(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '앱 정보'),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              child: Column(
                children: [
                  const TevioListRow(
                    icon: Icons.support_agent_outlined,
                    title: '고객센터',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  const TevioListRow(
                    icon: Icons.campaign_outlined,
                    title: '공지사항',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  const TevioListRow(
                    icon: Icons.description_outlined,
                    title: '이용약관',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  const TevioListRow(
                    icon: Icons.policy_outlined,
                    title: '개인정보처리방침',
                  ),
                  const Divider(height: TevioSpacing.xl),
                  const TevioListRow(
                    icon: Icons.info_outline,
                    title: '앱 정보',
                    value: '1.0.0',
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
                  TevioListRow(icon: Icons.logout, title: '로그아웃'),
                  Divider(height: TevioSpacing.xl),
                  TevioListRow(
                    icon: Icons.delete_outline,
                    title: '회원 탈퇴',
                    isDestructive: true,
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

String _themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => '기기 설정',
  ThemeMode.light => '라이트',
  ThemeMode.dark => '다크',
};

Future<void> _showThemeModeSheet(BuildContext context, WidgetRef ref) async {
  final current = ref.read(themeModeProvider);
  final selected = await TevioSheet.show<ThemeMode>(
    context,
    builder: (context) => TevioSheet(
      title: '화면 설정',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final mode in ThemeMode.values)
            TevioRadioControl<ThemeMode>(
              value: mode,
              groupValue: current,
              label: _themeModeLabel(mode),
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
          const SizedBox(height: TevioSpacing.sm),
        ],
      ),
    ),
  );
  if (selected != null) ref.read(themeModeProvider.notifier).setMode(selected);
}
