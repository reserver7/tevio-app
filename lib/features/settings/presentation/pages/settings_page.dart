import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../data/device_permission_service.dart';
import '../state/my_tab_session.dart';
import '../state/theme_mode.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with WidgetsBindingObserver {
  final _permissions = const DevicePermissionService();
  Map<TevioDevicePermission, TevioPermissionState> _permissionStates = {};
  TevioDevicePermission? _pendingSettingsPermission;
  bool _settingsActionRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _pendingSettingsPermission != null) {
      _pendingSettingsPermission = null;
      _refreshPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(myTabSessionProvider);

    return Scaffold(
      key: ValueKey('my-tab-$session'),
      appBar: const TevioAppBar(title: '마이', automaticallyImplyLeading: false),
      body: TevioPageScrollView(
        children: [
          const _GuestAccountSummary(),
          const SizedBox(height: TevioSpacing.xl),
          TevioListSection(
            title: '설정',
            children: [
              TevioListRow(
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                description: '받을 알림과 기기 권한을 관리해요.',
                onTap: () => context.push('/settings/notifications'),
              ),
              TevioListRow(
                icon: Icons.brightness_6_outlined,
                title: '화면 설정',
                value: _themeModeLabel(ref.watch(themeModeProvider)),
                onTap: () => _showThemeModeSheet(context, ref),
              ),
            ],
          ),
          const SizedBox(height: TevioSpacing.xl),
          TevioListSection(
            title: '기기 권한',
            description: '테비오에서 실제로 사용하는 권한만 표시해요.',
            children: [
              _permissionRow(
                TevioDevicePermission.camera,
                icon: Icons.camera_alt_outlined,
                title: '카메라',
                description: '영수증 촬영',
              ),
              if (_permissions.supportsPhotosPermission)
                _permissionRow(
                  TevioDevicePermission.photos,
                  icon: Icons.photo_outlined,
                  title: '사진',
                  description: '영수증 이미지 선택',
                ),
              _permissionRow(
                TevioDevicePermission.notifications,
                icon: Icons.notifications_active_outlined,
                title: '알림',
                description: '리콜·보증·기한 알림',
              ),
            ],
          ),
          const SizedBox(height: TevioSpacing.xl),
          TevioListSection(
            title: '도구 및 정보',
            children: [
              TevioListRow(
                icon: Icons.policy_outlined,
                title: '공개 리콜 조회',
                description: '등록하지 않은 제품도 공식 공지를 검색해요.',
                onTap: () => context.push('/recalls/public'),
              ),
              const TevioListRow(
                icon: Icons.info_outline,
                title: '앱 정보',
                value: '1.0.0',
                showChevron: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permissionRow(
    TevioDevicePermission permission, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return TevioListRow(
      icon: icon,
      title: title,
      description: description,
      value: _permissionLabel(_permissionStates[permission]),
      onTap: () => _openPermissionSettings(permission, title: title),
    );
  }

  Future<void> _refreshPermissions() async {
    final types = <TevioDevicePermission>[
      TevioDevicePermission.camera,
      if (_permissions.supportsPhotosPermission) TevioDevicePermission.photos,
      TevioDevicePermission.notifications,
    ];
    final entries = await Future.wait(
      types.map(
        (type) async => MapEntry(type, await _permissions.status(type)),
      ),
    );
    if (!mounted) return;
    setState(() => _permissionStates = Map.fromEntries(entries));
  }

  Future<void> _openPermissionSettings(
    TevioDevicePermission permission, {
    required String title,
  }) async {
    if (_settingsActionRunning) return;
    setState(() => _settingsActionRunning = true);
    final confirmed = await _showSettingsSheet(context, title: title);
    if (!mounted) return;
    if (!confirmed) {
      setState(() => _settingsActionRunning = false);
      return;
    }
    _pendingSettingsPermission = permission;
    final opened = await _permissions.openSettings(
      _permissions.settingsDestinationFor(permission),
    );
    if (!mounted) return;
    setState(() => _settingsActionRunning = false);
    if (!opened) {
      _pendingSettingsPermission = null;
      TevioSnackbar.show(context, '설정을 열지 못했어요. 기기 설정에서 테비오 권한을 확인해 주세요.');
    }
  }
}

String _permissionLabel(TevioPermissionState? state) => switch (state) {
  null => '확인 중',
  TevioPermissionState.allowed => '허용됨',
  TevioPermissionState.limited => '일부 허용',
  TevioPermissionState.denied => '허용 안 됨',
};

Future<bool> _showSettingsSheet(
  BuildContext context, {
  required String title,
}) async {
  final result = await TevioSheet.show<bool>(
    context,
    builder: (sheetContext) => TevioSheet(
      title: '$title 권한 설정',
      child: Text(
        '기기 설정에서 테비오의 $title 권한을 변경할 수 있어요.',
        style: Theme.of(sheetContext).textTheme.bodyLarge,
      ),
      footer: Row(
        children: [
          Expanded(
            child: TevioButton(
              label: '취소',
              variant: TevioButtonVariant.secondary,
              onPressed: () => Navigator.of(sheetContext).pop(false),
            ),
          ),
          const SizedBox(width: TevioSpacing.sm),
          Expanded(
            child: TevioButton(
              label: '설정 열기',
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

class _GuestAccountSummary extends StatelessWidget {
  const _GuestAccountSummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: TevioDimensions.buttonHeight,
          height: TevioDimensions.buttonHeight,
          child: TevioLogo(variant: TevioLogoVariant.symbol, size: 40),
        ),
        const SizedBox(width: TevioSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('둘러보기 모드', style: TevioTypography.titleMedium),
              const SizedBox(height: TevioSpacing.xxs),
              Text(
                '제품과 설정은 이 기기에 저장돼요.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: TevioSpacing.xs),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: TevioColors.mint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: TevioSpacing.xs),
                  Text(
                    '기기 저장 사용 중',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
