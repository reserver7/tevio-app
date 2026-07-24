import 'package:flutter/material.dart';

import '../../data/mock_notifications.dart';
import '../../../../shared/design_system/tevio_design_system.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final notifications = _showUnreadOnly
        ? mockNotifications.where((notification) => !notification.isRead)
        : mockNotifications;
    final groups = notifications
        .map((notification) => notification.groupLabel)
        .toSet()
        .toList();

    return Scaffold(
      appBar: const TevioAppBar(title: '알림', automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          key: const PageStorageKey('notifications-scroll'),
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            _NotificationFilterBar(
              showUnreadOnly: _showUnreadOnly,
              unreadCount: mockNotifications
                  .where((notification) => !notification.isRead)
                  .length,
              onChanged: (value) {
                setState(() {
                  _showUnreadOnly = value;
                });
              },
            ),
            const SizedBox(height: TevioSpacing.lg),
            if (groups.isEmpty)
              const TevioEmptyState(
                title: '읽지 않은 알림이 없어요',
                description: '새로운 알림이 도착하면 여기에 표시됩니다.',
              )
            else
              for (final group in groups) ..._buildGroupSection(group),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupSection(String groupLabel) {
    final notifications = mockNotifications
        .where((notification) => notification.groupLabel == groupLabel)
        .where((notification) => !_showUnreadOnly || !notification.isRead)
        .toList();

    if (notifications.isEmpty) {
      return [];
    }

    return [
      TevioSectionHeader(title: groupLabel),
      const SizedBox(height: TevioSpacing.sm),
      for (final notification in notifications) ...[
        TevioNotificationCard(
          status: notification.status,
          productName: notification.productName,
          typeLabel: notification.typeLabel,
          title: notification.title,
          description: notification.description,
          receivedAt: notification.receivedAt,
          actionLabel: notification.actionLabel,
          isRead: notification.isRead,
        ),
        const SizedBox(height: TevioSpacing.sm),
      ],
      const SizedBox(height: TevioSpacing.md),
    ];
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.showUnreadOnly,
    required this.unreadCount,
    required this.onChanged,
  });

  final bool showUnreadOnly;
  final int unreadCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        _NotificationFilterChip(
          label: '전체',
          selected: !showUnreadOnly,
          onTap: () => onChanged(false),
        ),
        const SizedBox(width: TevioSpacing.xs),
        _NotificationFilterChip(
          label: '읽지 않음 $unreadCount',
          selected: showUnreadOnly,
          onTap: () => onChanged(true),
        ),
        const Spacer(),
        Text(
          '최근 30일',
          style: textTheme.labelMedium?.copyWith(
            color: TevioColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _NotificationFilterChip extends StatelessWidget {
  const _NotificationFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: selected ? TevioColors.white : TevioColors.textSecondary,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: selected ? TevioColors.primary : TevioColors.white,
      side: const BorderSide(color: TevioColors.divider),
      shape: const RoundedRectangleBorder(borderRadius: TevioRadius.fullBorder),
    );
  }
}
