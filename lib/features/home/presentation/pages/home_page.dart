import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../../notifications/presentation/state/notification_queries.dart';
import '../../../products/domain/models/product_summary.dart';
import '../../../products/presentation/state/product_queries.dart';

enum _HomePresentationType {
  empty,
  safe,
  singleAction,
  groupedAction,
  mixedActions,
  processing,
  contextual,
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productSummariesQueryProvider);
    final unreadNotificationsCount = ref.watch(
      unreadNotificationsCountQueryProvider,
    );
    final snapshot = _HomeSnapshot.fromProducts(products);

    return Scaffold(
      appBar: AppBar(
        title: const TevioLogo(variant: TevioLogoVariant.symbol, size: 32),
        actions: [
          _NotificationBell(
            unreadCount: unreadNotificationsCount,
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(child: _HomeContent(snapshot: snapshot)),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.snapshot});

  final _HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('home-scroll'),
      padding: const EdgeInsets.all(TevioSpacing.lg),
      children: [
        if (snapshot.presentationType != _HomePresentationType.empty)
          _TodayStatusCard(snapshot: snapshot),
        if (snapshot.nextActions.isNotEmpty) ...[
          const SizedBox(height: TevioSpacing.xl),
          TevioSectionHeader(title: snapshot.secondarySectionTitle),
          const SizedBox(height: TevioSpacing.sm),
          for (final action in snapshot.nextActions.take(2)) ...[
            _ActionCard(action: action),
            const SizedBox(height: TevioSpacing.sm),
          ],
        ],
        if (snapshot.processing != null) ...[
          const SizedBox(height: TevioSpacing.lg),
          const TevioSectionHeader(title: '진행 중인 처리'),
          const SizedBox(height: TevioSpacing.sm),
          _ProcessingCard(item: snapshot.processing!),
        ],
        if (snapshot.productSummary != null) ...[
          const SizedBox(height: TevioSpacing.xl),
          TevioSectionHeader(
            title: '내 제품 요약',
            actionLabel: '전체 보기',
            onActionPressed: () => context.go('/products'),
          ),
          const SizedBox(height: TevioSpacing.sm),
          _ProductSummary(summary: snapshot.productSummary!),
        ],
        if (snapshot.recentChecks.isNotEmpty) ...[
          const SizedBox(height: TevioSpacing.xl),
          const TevioSectionHeader(title: '테비오가 최근 확인했어요'),
          const SizedBox(height: TevioSpacing.sm),
          TevioCard(
            child: Column(
              children: [
                for (final check in snapshot.recentChecks.take(2)) ...[
                  _RecentCheckRow(check: check),
                  if (check != snapshot.recentChecks.take(2).last)
                    const Divider(height: TevioSpacing.xl),
                ],
              ],
            ),
          ),
        ],
        if (snapshot.contextualCta != null) ...[
          const SizedBox(height: TevioSpacing.xl),
          _ContextualCta(cta: snapshot.contextualCta!),
        ],
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unreadCount, required this.onPressed});

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = const Icon(Icons.notifications_none_outlined);

    return IconButton(
      tooltip: '알림',
      onPressed: onPressed,
      icon: unreadCount == 0
          ? icon
          : Badge(
              backgroundColor: TevioColors.danger,
              textColor: TevioColors.white,
              label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
              child: icon,
            ),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard({required this.snapshot});

  final _HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final eyebrow = snapshot.eyebrow;

    return TevioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TevioStatusBadge(status: snapshot.status),
              if (eyebrow != null) ...[
                const SizedBox(width: TevioSpacing.xs),
                Expanded(
                  child: Text(
                    eyebrow,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: TevioSpacing.md),
          Text(
            snapshot.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: TevioSpacing.xs),
          Text(
            snapshot.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (snapshot.summary != null) ...[
            const SizedBox(height: TevioSpacing.md),
            _SummaryPill(label: snapshot.summary!, status: snapshot.status),
          ],
          if (snapshot.primaryAction != null) ...[
            const SizedBox(height: TevioSpacing.lg),
            TevioButton(
              label: snapshot.primaryAction!.ctaLabel,
              icon: Icons.arrow_forward_outlined,
              onPressed: () => context.go(snapshot.primaryAction!.route),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.status});

  final String label;
  final RightsStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: TevioRadius.fullBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TevioSpacing.sm,
          vertical: TevioSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: status.foreground),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final _HomeAction action;

  @override
  Widget build(BuildContext context) {
    return TevioRightsCard(
      status: action.status,
      productName: action.productName,
      title: action.title,
      description: action.reason,
      dueText: action.dueText,
      actionLabel: action.ctaLabel,
      onPressed: () => context.go(action.route),
    );
  }
}

class _ProcessingCard extends StatelessWidget {
  const _ProcessingCard({required this.item});

  final _ProcessingItem item;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      child: _InfoRow(
        status: RightsStatus.processing,
        title: item.title,
        description: item.description,
        meta: item.meta,
      ),
    );
  }
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.summary});

  final _ProductSummaryData summary;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      child: _InfoRow(
        status: RightsStatus.safe,
        title: '전체 ${summary.totalCount}개',
        description:
            '정상 ${summary.safeCount}개 · 확인 필요 ${summary.actionRequiredCount}개',
        meta: summary.highlight,
      ),
    );
  }
}

class _RecentCheckRow extends StatelessWidget {
  const _RecentCheckRow({required this.check});

  final _RecentCheck check;

  @override
  Widget build(BuildContext context) {
    return _InfoRow(
      status: check.status,
      title: check.title,
      description: check.description,
      meta: check.checkedAt,
    );
  }
}

class _ContextualCta extends StatelessWidget {
  const _ContextualCta({required this.cta});

  final _HomeCta cta;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cta.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TevioSpacing.xs),
          Text(cta.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: TevioSpacing.lg),
          TevioButton(
            label: cta.label,
            icon: cta.icon,
            onPressed: () => context.go(cta.route),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.status,
    required this.title,
    required this.description,
    required this.meta,
  });

  final RightsStatus status;
  final String title;
  final String description;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIcon(status: status),
        const SizedBox(width: TevioSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TevioSpacing.xxs),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: TevioSpacing.xs),
              Text(meta, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final RightsStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: TevioRadius.mediumBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TevioSpacing.sm),
        child: Icon(status.icon, color: status.foreground),
      ),
    );
  }
}

class _HomeSnapshot {
  const _HomeSnapshot({
    required this.presentationType,
    required this.status,
    required this.title,
    required this.description,
    this.eyebrow,
    this.summary,
    this.primaryAction,
    this.nextActions = const [],
    this.processing,
    this.productSummary,
    this.recentChecks = const [],
    this.contextualCta,
  });

  final _HomePresentationType presentationType;
  final RightsStatus status;
  final String title;
  final String description;
  final String? eyebrow;
  final String? summary;
  final _HomeAction? primaryAction;
  final List<_HomeAction> nextActions;
  final _ProcessingItem? processing;
  final _ProductSummaryData? productSummary;
  final List<_RecentCheck> recentChecks;
  final _HomeCta? contextualCta;

  String get secondarySectionTitle {
    return switch (presentationType) {
      _HomePresentationType.singleAction => '다음으로 확인할 일',
      _HomePresentationType.groupedAction => '포함된 항목',
      _HomePresentationType.mixedActions => '우선순위가 낮은 항목',
      _HomePresentationType.empty ||
      _HomePresentationType.safe ||
      _HomePresentationType.processing ||
      _HomePresentationType.contextual => '다음으로 확인할 일',
    };
  }

  factory _HomeSnapshot.fromProducts(List<ProductSummary> products) {
    if (products.isEmpty) {
      return const _HomeSnapshot(
        presentationType: _HomePresentationType.empty,
        status: RightsStatus.unknown,
        title: '첫 제품을 등록해 보세요',
        description: '제품과 구매 정보를 등록하면 테비오가 리콜, 보증, A/S 정보를 계속 확인해 드려요.',
        contextualCta: _HomeCta(
          title: '첫 제품을 등록해 보세요',
          description: '영수증이나 모델번호만 있어도 구매 이후 권리 확인을 시작할 수 있어요.',
          label: '제품 등록하기',
          icon: Icons.add_box_outlined,
          route: '/register',
        ),
      );
    }

    final urgentProducts = products
        .where((product) => product.status == RightsStatus.urgent)
        .toList();
    final actionRequiredProducts = products
        .where((product) => product.status == RightsStatus.actionRequired)
        .toList();
    final processingProducts = products
        .where((product) => product.status == RightsStatus.processing)
        .toList();
    final detectedProducts = products
        .where((product) => product.status == RightsStatus.detected)
        .toList();
    final safeCount = products
        .where(
          (product) =>
              product.status == RightsStatus.safe ||
              product.status == RightsStatus.completed,
        )
        .length;
    final attentionProducts = [
      ...urgentProducts,
      ...actionRequiredProducts,
      ...detectedProducts,
    ];
    final primaryProduct = attentionProducts.isNotEmpty
        ? attentionProducts.first
        : null;
    final productSummary = _ProductSummaryData(
      totalCount: products.length,
      safeCount: safeCount,
      actionRequiredCount: attentionProducts.length,
      highlight: attentionProducts.isEmpty
          ? '새로운 리콜 대상은 없어요.'
          : '${attentionProducts.first.name}부터 확인해 주세요.',
    );

    if (primaryProduct == null && processingProducts.isNotEmpty) {
      final processingProduct = processingProducts.first;

      return _HomeSnapshot(
        presentationType: _HomePresentationType.processing,
        status: RightsStatus.processing,
        eyebrow: '${processingProduct.brand} ${processingProduct.name}',
        title: '요청한 처리가 진행 중이에요',
        description: processingProduct.statusSummary,
        summary: processingProduct.recommendedAction,
        recentChecks: [
          _RecentCheck(
            status: RightsStatus.processing,
            title: '${processingProduct.name} 처리 상태를 확인했어요',
            description: processingProduct.statusSummary,
            checkedAt: '오늘 오후 2:30',
          ),
        ],
      );
    }

    if (primaryProduct == null) {
      return _HomeSnapshot(
        presentationType: _HomePresentationType.safe,
        status: RightsStatus.safe,
        title: '현재 확인할 내용이 없어요',
        description: '등록한 제품 ${products.length}개를 테비오가 계속 확인하고 있어요.',
        summary: '마지막 확인 오늘 오후 2:30',
        productSummary: productSummary,
        recentChecks: [
          _RecentCheck(
            status: RightsStatus.safe,
            title: '등록 제품 ${products.length}개의 권리 정보를 확인했어요',
            description: '새로운 리콜 대상은 없어요.',
            checkedAt: '오늘 오후 2:30',
          ),
        ],
      );
    }

    final primaryAction = _HomeAction.fromProduct(primaryProduct);
    final nextActions = attentionProducts
        .skip(1)
        .map(_HomeAction.fromProduct)
        .toList();
    final urgentCount = urgentProducts.length;
    final actionCount = actionRequiredProducts.length + detectedProducts.length;

    return _HomeSnapshot(
      presentationType: nextActions.isEmpty
          ? _HomePresentationType.singleAction
          : _HomePresentationType.mixedActions,
      status: primaryProduct.status,
      eyebrow: '${primaryProduct.brand} ${primaryProduct.name}',
      title: _headlineFor(primaryProduct),
      description: primaryProduct.statusSummary,
      summary: [
        if (urgentCount > 0) '긴급 $urgentCount개',
        if (actionCount > 0) '확인 필요 $actionCount개',
        if (processingProducts.isNotEmpty) '처리 중 ${processingProducts.length}개',
      ].join(' · '),
      primaryAction: primaryAction,
      nextActions: nextActions,
      processing: processingProducts.isEmpty
          ? null
          : _ProcessingItem.fromProduct(processingProducts.first),
      recentChecks: [
        _RecentCheck(
          status: RightsStatus.safe,
          title: '등록 제품 ${products.length}개의 권리 정보를 확인했어요',
          description: attentionProducts.isEmpty
              ? '새로운 리콜 대상은 없어요.'
              : '${attentionProducts.length}개 항목은 추가 확인이 필요해요.',
          checkedAt: '오늘 오후 2:30',
        ),
      ],
    );
  }

  static String _headlineFor(ProductSummary product) {
    return switch (product.status) {
      RightsStatus.urgent => '${product.name} 리콜 확인이 필요해요',
      RightsStatus.actionRequired => '${product.name} 확인이 필요해요',
      RightsStatus.detected => '${product.name} 등록 정보를 확인 중이에요',
      RightsStatus.processing => '${product.name} 처리가 진행 중이에요',
      RightsStatus.safe ||
      RightsStatus.completed ||
      RightsStatus.unknown => '${product.name} 상태를 확인했어요',
    };
  }
}

class _HomeAction {
  const _HomeAction({
    required this.status,
    required this.productName,
    required this.title,
    required this.reason,
    required this.dueText,
    required this.ctaLabel,
    required this.route,
  });

  final RightsStatus status;
  final String productName;
  final String title;
  final String reason;
  final String dueText;
  final String ctaLabel;
  final String route;

  factory _HomeAction.fromProduct(ProductSummary product) {
    return _HomeAction(
      status: product.status,
      productName: '${product.brand} ${product.name}',
      title: product.recommendedAction,
      reason: product.statusSummary,
      dueText: _dueTextFor(product),
      ctaLabel: product.recommendedAction,
      route: '/products/${product.id}',
    );
  }

  static String _dueTextFor(ProductSummary product) {
    return switch (product.status) {
      RightsStatus.urgent => '즉시 확인 권장',
      RightsStatus.actionRequired => product.warrantyText,
      RightsStatus.detected => '확인 중',
      RightsStatus.processing => '처리 중',
      RightsStatus.safe ||
      RightsStatus.completed ||
      RightsStatus.unknown => product.warrantyText,
    };
  }
}

class _ProcessingItem {
  const _ProcessingItem({
    required this.title,
    required this.description,
    required this.meta,
  });

  final String title;
  final String description;
  final String meta;

  factory _ProcessingItem.fromProduct(ProductSummary product) {
    return _ProcessingItem(
      title: '${product.name} 상태를 확인하고 있어요',
      description: product.statusSummary,
      meta: product.recommendedAction,
    );
  }
}

class _ProductSummaryData {
  const _ProductSummaryData({
    required this.totalCount,
    required this.safeCount,
    required this.actionRequiredCount,
    required this.highlight,
  });

  final int totalCount;
  final int safeCount;
  final int actionRequiredCount;
  final String highlight;
}

class _RecentCheck {
  const _RecentCheck({
    required this.status,
    required this.title,
    required this.description,
    required this.checkedAt,
  });

  final RightsStatus status;
  final String title;
  final String description;
  final String checkedAt;
}

class _HomeCta {
  const _HomeCta({
    required this.title,
    required this.description,
    required this.label,
    required this.icon,
    required this.route,
  });

  final String title;
  final String description;
  final String label;
  final IconData icon;
  final String route;
}
