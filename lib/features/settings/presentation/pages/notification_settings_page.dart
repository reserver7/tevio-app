import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../state/notification_settings.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: const TevioAppBar(title: '알림 설정'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            Text('필요한 알림만 받아보세요', style: TevioTypography.titleLarge),
            const SizedBox(height: TevioSpacing.xs),
            Text(
              '테비오가 확인한 변화 중 원하는 항목만 알려드려요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TevioSpacing.xl),
            TevioCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _NotificationToggle(
                    title: '리콜 및 안전 문제',
                    description: '사용 중지나 공식 조치가 필요한 경우',
                    value: settings.recall,
                    onChanged: controller.setRecall,
                    isFirst: true,
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
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '기기 알림'),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('알림 권한'),
                        SizedBox(height: TevioSpacing.xxs),
                        Text('긴급한 리콜과 상태 변화를 놓치지 않도록 설정하세요.'),
                      ],
                    ),
                  ),
                  TevioTextAction(
                    label: '설정하기',
                    onPressed: () => _requestPermission(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission(BuildContext context) async {
    final status = await Permission.notification.request();

    if (!context.mounted) {
      return;
    }

    final message = status.isGranted
        ? '기기 알림을 켰어요.'
        : '기기 설정에서 알림 권한을 허용해 주세요.';

    TevioSnackbar.show(context, message);
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst) const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TevioSpacing.md),
          child: TevioSwitch(
            value: value,
            onChanged: onChanged,
            label: title,
            description: description,
          ),
        ),
        if (isLast) const SizedBox(height: TevioSpacing.xs),
      ],
    );
  }
}
