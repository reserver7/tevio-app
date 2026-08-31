import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../data/device_permission_service.dart';
import '../state/notification_settings.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage>
    with WidgetsBindingObserver {
  final _permissions = const DevicePermissionService();
  TevioPermissionState? _permissionState;
  bool _permissionActionRunning = false;
  bool _waitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForSettings) {
      _waitingForSettings = false;
      _refreshPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: const TevioAppBar(title: '알림 설정'),
      body: TevioPageScrollView(
        children: [
          const TevioPageIntro(
            title: '알림 정책',
            description: '전체 제품에 적용할 알림과 이 기기의 수신 권한을 구분해 관리하세요.',
          ),
          const SizedBox(height: TevioSpacing.xl),
          TevioListSection(
            title: '전체 제품 알림',
            description: '제품별 설정이 없을 때 적용되는 기본값이에요.',
            children: [
              _NotificationToggle(
                title: '리콜 및 안전 문제',
                description: '사용 중지나 공식 조치가 필요한 경우',
                value: settings.recall,
                onChanged: controller.setRecall,
              ),
              _NotificationToggle(
                title: '보증 만료',
                description: '보증 기간이 끝나기 전에 미리 알려드려요.',
                value: settings.warranty,
                onChanged: controller.setWarranty,
              ),
              _NotificationToggle(
                title: '반품·교환 기간',
                description: '구매 이후 가능한 기간이 얼마 남지 않았을 때',
                value: settings.returnWindow,
                onChanged: controller.setReturnWindow,
              ),
              _NotificationToggle(
                title: '처리 상태 변경',
                description: '리콜, 점검, A/S 처리 상태가 바뀌었을 때',
                value: settings.processing,
                onChanged: controller.setProcessing,
              ),
            ],
          ),
          const SizedBox(height: TevioSpacing.xl),
          TevioListSection(
            title: '이 기기',
            children: [
              TevioListRow(
                icon: Icons.notifications_active_outlined,
                title: '알림 권한',
                description: '선택한 알림을 받으려면 기기 권한이 필요해요.',
                value: _permissionLabel,
                onTap: _permissionActionRunning ? null : _handlePermission,
                showChevron: true,
              ),
              TevioListRow(
                icon: Icons.volume_up_outlined,
                title: '알림 소리',
                description: '소리와 진동은 기기 알림 설정을 따라요.',
                value: '기기 설정',
                onTap: _permissionActionRunning
                    ? null
                    : () => _confirmAndOpenSettings(
                        title: '알림 소리 설정',
                        description: '기기 설정에서 테비오 알림의 소리와 진동을 변경할 수 있어요.',
                      ),
                showChevron: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _permissionLabel => switch (_permissionState) {
    null => '확인 중',
    TevioPermissionState.allowed => '허용됨',
    TevioPermissionState.limited => '일부 허용',
    TevioPermissionState.denied => '허용 안 됨',
  };

  Future<void> _refreshPermission() async {
    final status = await _permissions.status(
      TevioDevicePermission.notifications,
    );
    if (!mounted) return;
    setState(() => _permissionState = status);
  }

  Future<void> _handlePermission() async {
    if (_permissionActionRunning) return;
    setState(() => _permissionActionRunning = true);

    final current = await Permission.notification.status;
    if (!mounted) return;

    if (current.isGranted || current.isLimited) {
      setState(() => _permissionActionRunning = false);
      await _confirmAndOpenSettings();
      return;
    }

    if (current.isPermanentlyDenied || current.isRestricted) {
      setState(() => _permissionActionRunning = false);
      await _confirmAndOpenSettings();
      return;
    }

    final requested = await _permissions.request(
      TevioDevicePermission.notifications,
    );
    if (!mounted) return;
    setState(() {
      _permissionActionRunning = false;
      _permissionState = requested.isGranted
          ? TevioPermissionState.allowed
          : requested.isLimited
          ? TevioPermissionState.limited
          : TevioPermissionState.denied;
    });
  }

  Future<void> _confirmAndOpenSettings({
    String title = '알림 권한 설정',
    String description = '기기 설정에서 테비오 알림의 허용 여부를 변경할 수 있어요.',
  }) async {
    if (_permissionActionRunning) return;
    setState(() => _permissionActionRunning = true);
    final confirmed = await TevioSheet.show<bool>(
      context,
      builder: (sheetContext) => TevioSheet(
        title: title,
        child: Text(
          description,
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
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _permissionActionRunning = false);
      return;
    }

    _waitingForSettings = true;
    final opened = await _permissions.openSettings(
      TevioSettingsDestination.notifications,
    );
    if (!mounted) return;
    setState(() => _permissionActionRunning = false);
    if (!opened) {
      _waitingForSettings = false;
      TevioSnackbar.show(context, '설정을 열지 못했어요. 기기 설정에서 테비오 알림을 확인해 주세요.');
    }
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TevioSpacing.xs),
      child: TevioSwitch(
        value: value,
        onChanged: onChanged,
        label: title,
        description: description,
      ),
    );
  }
}
