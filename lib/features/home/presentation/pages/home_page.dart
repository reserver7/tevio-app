import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

enum _HomeScenario {
  noProducts,
  allSafe,
  actionRequired,
  groupedInfoRequired,
  urgentRecall,
  processing,
  registrationInProgress,
  notificationPermissionOff,
  loading,
  error,
  offline,
}

enum _HomePresentationType {
  empty,
  safe,
  singleAction,
  groupedAction,
  mixedActions,
  processing,
  contextual,
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _scenario = _HomeScenario.urgentRecall;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TevioLogo(variant: TevioLogoVariant.symbol, size: 32),
        actions: [
          _NotificationBell(onPressed: () => context.push('/notifications')),
        ],
      ),
      body: SafeArea(child: _HomeContent(scenario: _scenario)),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.scenario});

  final _HomeScenario scenario;

  @override
  Widget build(BuildContext context) {
    if (scenario == _HomeScenario.loading) {
      return const TevioLoadingState(label: '제품 상태를 확인하고 있어요');
    }

    if (scenario == _HomeScenario.error) {
      return const TevioErrorState(
        title: '상태를 불러오지 못했어요',
        description: '잠시 후 다시 확인해 주세요.',
      );
    }

    if (scenario == _HomeScenario.offline) {
      return const TevioErrorState(
        title: '인터넷 연결이 필요해요',
        description: '연결되면 테비오가 제품 권리를 다시 확인할게요.',
      );
    }

    final snapshot = _HomeSnapshot.from(scenario);

    return ListView(
      key: const PageStorageKey('home-scroll'),
      padding: const EdgeInsets.all(TevioSpacing.lg),
      children: [
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
          const TevioSectionHeader(title: '내 제품 요약'),
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
  const _NotificationBell({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '알림',
      onPressed: onPressed,
      icon: const Badge(
        backgroundColor: TevioColors.danger,
        textColor: TevioColors.white,
        label: Text('2'),
        child: Icon(Icons.notifications_none_outlined),
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
              onPressed: () => context.push(snapshot.primaryAction!.route),
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
      onPressed: () => context.push(action.route),
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
            onPressed: () => context.push(cta.route),
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

  factory _HomeSnapshot.from(_HomeScenario scenario) {
    return switch (scenario) {
      _HomeScenario.noProducts => const _HomeSnapshot(
        presentationType: _HomePresentationType.empty,
        status: RightsStatus.unknown,
        title: '첫 제품을 등록해 보세요',
        description: '제품과 구매 정보를 등록하면 테비오가 리콜, 보증, A/S 정보를 계속 확인해 드려요.',
        contextualCta: _HomeCta(
          title: '구매 이후 권리 확인을 시작하세요',
          description: '영수증이나 모델번호만 있어도 제품 등록을 시작할 수 있어요.',
          label: '제품 등록하기',
          icon: Icons.add_box_outlined,
          route: '/register',
        ),
      ),
      _HomeScenario.allSafe => const _HomeSnapshot(
        presentationType: _HomePresentationType.safe,
        status: RightsStatus.safe,
        title: '현재 확인할 내용이 없어요',
        description: '등록한 제품 8개를 테비오가 계속 확인하고 있어요.',
        summary: '마지막 확인 오늘 오후 2:30',
        productSummary: _ProductSummaryData(
          totalCount: 8,
          safeCount: 8,
          actionRequiredCount: 0,
          highlight: '새로운 리콜 대상은 없어요.',
        ),
        recentChecks: [
          _RecentCheck(
            status: RightsStatus.safe,
            title: '등록 제품 8개의 리콜 정보를 확인했어요',
            description: '새로운 리콜 대상은 없어요.',
            checkedAt: '오늘 오후 2:30',
          ),
        ],
      ),
      _HomeScenario.actionRequired => const _HomeSnapshot(
        presentationType: _HomePresentationType.mixedActions,
        status: RightsStatus.actionRequired,
        title: '오늘 확인할 내용이 2개 있어요',
        description: '보증 만료 임박 1개 · 정보 보완 1개',
        primaryAction: _HomeAction(
          status: RightsStatus.actionRequired,
          productName: 'ABC 노트북',
          title: '무상 보증이 곧 종료돼요',
          reason: '최근 문제가 있었다면 종료 전에 점검받는 것이 좋아요.',
          dueText: 'D-14 · 보증',
          ctaLabel: '보증 내용 확인',
          route: '/products/notebook-sample-nb-16p',
        ),
        nextActions: [
          _HomeAction(
            status: RightsStatus.actionRequired,
            productName: '공기청정기',
            title: '구매일 입력이 필요해요',
            reason: '구매일을 입력하면 보증기간과 반품 가능 기간을 확인할 수 있어요.',
            dueText: '정보 보완',
            ctaLabel: '구매일 입력',
            route: '/products/air-purifier-abc-123',
          ),
        ],
      ),
      _HomeScenario.groupedInfoRequired => const _HomeSnapshot(
        presentationType: _HomePresentationType.groupedAction,
        status: RightsStatus.actionRequired,
        title: '제품 정보 보완이 필요해요',
        description: '4개 제품의 모델번호가 없어 리콜과 보증을 정확히 판단할 수 없어요.',
        summary: '모델번호 필요 4개',
        primaryAction: _HomeAction(
          status: RightsStatus.actionRequired,
          productName: '제품 4개',
          title: '모델번호 확인 필요',
          reason: '정확한 리콜과 보증 판단을 위해 모델번호가 필요합니다.',
          dueText: '정보 보완',
          ctaLabel: '정보 보완하기',
          route: '/products',
        ),
      ),
      _HomeScenario.urgentRecall => const _HomeSnapshot(
        presentationType: _HomePresentationType.singleAction,
        status: RightsStatus.urgent,
        eyebrow: 'XYZ 무선청소기',
        title: '무선청소기 리콜 확인이 필요해요',
        description: '배터리 과열 관련 리콜 대상일 수 있어요. 먼저 모델번호를 확인해 주세요.',
        summary: '리콜 1개 · 보증 만료 임박 1개',
        primaryAction: _HomeAction(
          status: RightsStatus.urgent,
          productName: 'XYZ 무선청소기',
          title: '배터리 과열 관련 리콜 대상일 수 있어요',
          reason: '모델번호를 확인하면 정확하게 판단할 수 있어요.',
          dueText: '즉시 확인 권장',
          ctaLabel: '모델번호 확인하기',
          route: '/products/vacuum-xyz-vc-2401',
        ),
        nextActions: [
          _HomeAction(
            status: RightsStatus.actionRequired,
            productName: 'Sample 노트북',
            title: '보증 만료가 가까워요',
            reason: '무상보증 종료 전 필요한 점검과 서류를 확인하세요.',
            dueText: '28일 남음',
            ctaLabel: '보증 정보 보기',
            route: '/products/notebook-sample-nb-16p',
          ),
        ],
        processing: _ProcessingItem(
          title: '공기청정기 A/S 접수 완료',
          description: '제조사 확인이 진행 중이에요.',
          meta: '7월 25일 방문 예정',
        ),
        recentChecks: [
          _RecentCheck(
            status: RightsStatus.safe,
            title: '공기청정기 보증기간을 확인했어요',
            description: '보증 종료까지 364일 남았어요.',
            checkedAt: '오늘 오후 2:30',
          ),
        ],
      ),
      _HomeScenario.processing => const _HomeSnapshot(
        presentationType: _HomePresentationType.processing,
        status: RightsStatus.processing,
        title: '확인할 긴급 항목은 없어요',
        description: '진행 중인 A/S 일정만 확인하면 됩니다.',
        summary: '제품 3개 확인 중',
        processing: _ProcessingItem(
          title: '노트북 무상 점검',
          description: '제조사 접수 완료',
          meta: '7월 25일 방문 예정',
        ),
        productSummary: _ProductSummaryData(
          totalCount: 3,
          safeCount: 2,
          actionRequiredCount: 1,
          highlight: '처리 중인 항목은 제품 상세에서 이어서 확인할 수 있어요.',
        ),
      ),
      _HomeScenario.registrationInProgress => const _HomeSnapshot(
        presentationType: _HomePresentationType.contextual,
        status: RightsStatus.processing,
        title: '등록 중인 제품이 있어요',
        description: '구매 정보를 마저 입력하면 테비오가 권리 확인을 시작할 수 있어요.',
        contextualCta: _HomeCta(
          title: '제품 등록을 이어서 완료하세요',
          description: '중단된 등록 정보를 이어서 확인할 수 있어요.',
          label: '등록 이어하기',
          icon: Icons.arrow_forward_outlined,
          route: '/register',
        ),
      ),
      _HomeScenario.notificationPermissionOff => const _HomeSnapshot(
        presentationType: _HomePresentationType.contextual,
        status: RightsStatus.actionRequired,
        title: '중요한 알림이 꺼져 있어요',
        description: '리콜과 보증 만료를 놓치지 않으려면 알림 허용이 필요해요.',
        contextualCta: _HomeCta(
          title: '중요한 순간은 테비오가 알려드릴게요',
          description: '알림을 허용하면 리콜과 기한 임박 항목을 바로 받을 수 있어요.',
          label: '알림 켜기',
          icon: Icons.notifications_active_outlined,
          route: '/settings',
        ),
      ),
      _HomeScenario.loading ||
      _HomeScenario.error ||
      _HomeScenario.offline => throw StateError('Handled before snapshot.'),
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
