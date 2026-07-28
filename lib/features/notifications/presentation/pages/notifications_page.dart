import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../domain/models/tevio_notification.dart';
import '../state/notification_queries.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final allNotifications = ref.watch(notificationsQueryProvider);
    final unreadCount = ref.watch(unreadNotificationsCountQueryProvider);
    final notifications = _showUnreadOnly
        ? allNotifications.where((notification) => !notification.isRead)
        : allNotifications;
    final groups = notifications
        .map((notification) => notification.groupLabel)
        .toSet()
        .toList();

    return Scaffold(
      appBar: const TevioAppBar(title: '알림'),
      body: SafeArea(
        child: ListView(
          key: const PageStorageKey('notifications-scroll'),
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            _NotificationFilterBar(
              showUnreadOnly: _showUnreadOnly,
              unreadCount: unreadCount,
              onMarkAllAsRead: unreadCount == 0
                  ? null
                  : () {
                      ref.read(notificationCommandProvider).markAllAsRead();
                    },
              onChanged: (value) {
                setState(() {
                  _showUnreadOnly = value;
                });
              },
            ),
            const SizedBox(height: TevioSpacing.lg),
            if (groups.isEmpty)
              _NotificationEmptyState(showUnreadOnly: _showUnreadOnly)
            else
              for (final group in groups)
                ..._buildGroupSection(group, allNotifications),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupSection(
    String groupLabel,
    List<TevioNotification> allNotifications,
  ) {
    final notifications = allNotifications
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
        Dismissible(
          key: ValueKey(notification.id),
          direction: DismissDirection.endToStart,
          background: const _DismissBackground(),
          onDismissed: (_) => _removeNotification(notification),
          child: TevioNotificationCard(
            status: notification.status,
            productName: notification.productName,
            typeLabel: notification.typeLabel,
            title: notification.title,
            description: notification.description,
            receivedAt: notification.receivedAt,
            isRead: notification.isRead,
            onTap: () => _openNotification(notification),
          ),
        ),
        const SizedBox(height: TevioSpacing.sm),
      ],
      const SizedBox(height: TevioSpacing.md),
    ];
  }

  void _openNotification(TevioNotification notification) {
    ref.read(notificationCommandProvider).markAsRead(notification.id);

    if (notification.route.startsWith('/products/')) {
      context.push(_targetRouteFor(notification));
      return;
    }

    context.go(notification.route);
  }

  void _removeNotification(TevioNotification notification) {
    final commands = ref.read(notificationCommandProvider);
    commands.remove(notification.id);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('알림을 삭제했어요'),
          action: SnackBarAction(
            label: '되돌리기',
            onPressed: () => commands.restore(notification),
          ),
        ),
      );
  }

  String _targetRouteFor(TevioNotification notification) {
    if (notification.route.startsWith('/products/')) {
      final productId = notification.route.replaceFirst('/products/', '');

      return '/notification-products/$productId?from=notifications';
    }

    return notification.route;
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState({required this.showUnreadOnly});

  final bool showUnreadOnly;

  @override
  Widget build(BuildContext context) {
    if (showUnreadOnly) {
      return const TevioEmptyState(
        title: '읽지 않은 알림이 없어요',
        description: '새로운 알림이 도착하면 여기에 표시됩니다.',
      );
    }

    return const TevioEmptyState(
      title: '알림이 없어요',
      description: '리콜, 보증, 처리 상태 변화가 생기면 여기에 기록됩니다.',
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TevioColors.dangerBackground,
        borderRadius: TevioRadius.largeBorder,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: TevioSpacing.lg),
          child: Text(
            '삭제',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: TevioColors.danger,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.showUnreadOnly,
    required this.unreadCount,
    required this.onMarkAllAsRead,
    required this.onChanged,
  });

  final bool showUnreadOnly;
  final int unreadCount;
  final VoidCallback? onMarkAllAsRead;
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
        TextButton(
          onPressed: onMarkAllAsRead,
          child: Text(
            '모두 읽음',
            style: textTheme.labelLarge?.copyWith(
              color: onMarkAllAsRead == null
                  ? TevioColors.textTertiary
                  : TevioColors.primary,
              fontWeight: FontWeight.w800,
            ),
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
