import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../../notifications/presentation/state/notification_queries.dart';
import '../../../products/domain/models/product_summary.dart';
import '../../../products/presentation/state/product_queries.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productSummariesQueryProvider);
    final unreadCount = ref.watch(unreadNotificationsCountQueryProvider);
    final viewData = _HomeViewData.from(products);

    return Scaffold(
      appBar: TevioAppBar(
        title: '테비오',
        titleWidget: const TevioLogo(
          variant: TevioLogoVariant.symbol,
          size: 32,
        ),
        actions: [
          TevioIconButton(
            tooltip: unreadCount == 0 ? '활동' : '읽지 않은 활동 $unreadCount개',
            icon: unreadCount == 0
                ? Icons.notifications_none_outlined
                : Icons.notifications_outlined,
            variant: unreadCount == 0
                ? TevioIconButtonVariant.plain
                : TevioIconButtonVariant.tinted,
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: TevioPageScrollView(
        storageKey: 'home-scroll',
        children: [
          TevioPageIntro(
            eyebrow: '오늘의 권리 상태',
            title: viewData.headline,
            description: viewData.description,
          ),
          const SizedBox(height: TevioSpacing.lg),
          if (products.isEmpty)
            const _EmptyHome()
          else ...[
            _CoverageSummary(viewData: viewData),
            if (viewData.primaryProduct != null) ...[
              const SizedBox(height: TevioSpacing.xl),
              const TevioSectionHeader(title: '지금 할 일'),
              const SizedBox(height: TevioSpacing.sm),
              TevioDecisionPanel(
                status: viewData.primaryProduct!.status,
                contextLabel:
                    '${viewData.primaryProduct!.brand} · ${viewData.primaryProduct!.name}',
                title: _decisionTitleFor(viewData.primaryProduct!),
                reason: viewData.primaryProduct!.statusSummary,
                deadline: _deadlineFor(viewData.primaryProduct!),
                actionLabel: viewData.primaryProduct!.recommendedAction,
                onPressed: () =>
                    context.push('/products/${viewData.primaryProduct!.id}'),
              ),
              if (viewData.remainingActionCount > 0) ...[
                const SizedBox(height: TevioSpacing.sm),
                TevioTextAction(
                  label: '나머지 ${viewData.remainingActionCount}건 제품에서 보기',
                  onPressed: () => context.go('/products'),
                ),
              ],
            ],
            if (viewData.processingProducts.isNotEmpty) ...[
              const SizedBox(height: TevioSpacing.xl),
              _ProcessingList(products: viewData.processingProducts),
            ],
          ],
        ],
      ),
    );
  }
}

class _CoverageSummary extends StatelessWidget {
  const _CoverageSummary({required this.viewData});

  final _HomeViewData viewData;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '등록 제품 ${viewData.productCount}개, 확인 필요 ${viewData.actionCount}개, 처리 중 ${viewData.processingProducts.length}개',
      child: Row(
        children: [
          Expanded(
            child: _SummaryValue(
              value: '${viewData.productCount}',
              label: '등록 제품',
            ),
          ),
          const SizedBox(
            height: 32,
            child: VerticalDivider(width: TevioSpacing.xl),
          ),
          Expanded(
            child: _SummaryValue(
              value: '${viewData.actionCount}',
              label: '확인 필요',
            ),
          ),
          const SizedBox(
            height: 32,
            child: VerticalDivider(width: TevioSpacing.xl),
          ),
          Expanded(
            child: _SummaryValue(
              value: '${viewData.processingProducts.length}',
              label: '처리 중',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TevioTypography.titleLarge),
        const SizedBox(height: TevioSpacing.xxs),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

String? _deadlineFor(ProductSummary product) => switch (product.status) {
  RightsStatus.actionRequired => product.warrantyText,
  RightsStatus.detected => product.returnText,
  _ => null,
};

String _decisionTitleFor(ProductSummary product) => switch (product.status) {
  RightsStatus.urgent => '안전을 위해 리콜 대상을 확인하세요',
  RightsStatus.actionRequired => '보증이 끝나기 전에 필요한 내용을 확인하세요',
  RightsStatus.detected => '새로 감지된 권리 변화를 확인하세요',
  RightsStatus.processing => '권리 정보를 확인하고 있어요',
  RightsStatus.unknown => '판단에 필요한 제품 정보를 보완하세요',
  RightsStatus.safe || RightsStatus.completed => '현재 확인할 문제는 없어요',
};

class _ProcessingList extends StatelessWidget {
  const _ProcessingList({required this.products});

  final List<ProductSummary> products;

  @override
  Widget build(BuildContext context) {
    final product = products.first;
    return TevioListSection(
      title: '진행 중인 처리',
      description: '상태가 바뀌면 활동에서 알려드려요.',
      children: [
        TevioProcessTracker(
          steps: const [
            TevioProcessStep(label: '접수'),
            TevioProcessStep(
              label: '확인 중',
              description: '제품 정보와 권리 상태를 확인하고 있어요.',
            ),
            TevioProcessStep(label: '처리'),
            TevioProcessStep(label: '완료'),
          ],
          currentStep: 1,
          updatedAt: '오늘',
        ),
        if (products.length > 1)
          TevioTextAction(
            label: '진행 중 ${products.length}건 제품에서 보기',
            onPressed: () => context.go('/products'),
          )
        else
          TevioTextAction(
            label: '${product.name} 상태 확인',
            onPressed: () => context.push('/products/${product.id}'),
          ),
      ],
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: TevioSpacing.sm),
        Text('제품 하나로 시작하세요', style: TevioTypography.titleLarge),
        const SizedBox(height: TevioSpacing.xs),
        Text(
          '영수증이나 모델번호를 등록하면 리콜과 보증 정보를 계속 확인해 드려요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TevioSpacing.lg),
        TevioButton(
          label: '첫 제품 등록하기',
          icon: Icons.add,
          onPressed: () => context.push('/register'),
        ),
      ],
    );
  }
}

class _HomeViewData {
  const _HomeViewData({
    required this.productCount,
    required this.actionCount,
    required this.headline,
    required this.description,
    required this.processingProducts,
    this.primaryProduct,
  });

  final int productCount;
  final int actionCount;
  final String headline;
  final String description;
  final ProductSummary? primaryProduct;
  final List<ProductSummary> processingProducts;

  int get remainingActionCount => actionCount > 0 ? actionCount - 1 : 0;

  factory _HomeViewData.from(List<ProductSummary> products) {
    final actionProducts = products.where(_needsAction).toList()
      ..sort((a, b) => _priority(a.status).compareTo(_priority(b.status)));
    final processing = products
        .where((product) => product.status == RightsStatus.processing)
        .toList();

    if (products.isEmpty) {
      return const _HomeViewData(
        productCount: 0,
        actionCount: 0,
        headline: '구매 이후 관리를 시작해 보세요',
        description: '제품을 한 번 등록하면 필요한 순간을 놓치지 않게 알려드려요.',
        processingProducts: [],
      );
    }

    if (actionProducts.isNotEmpty) {
      return _HomeViewData(
        productCount: products.length,
        actionCount: actionProducts.length,
        headline: '확인할 권리가 있어요',
        description: '가장 중요한 내용부터 한 가지씩 처리해 보세요.',
        primaryProduct: actionProducts.first,
        processingProducts: processing,
      );
    }

    if (processing.isNotEmpty) {
      return _HomeViewData(
        productCount: products.length,
        actionCount: 0,
        headline: '요청한 처리가 진행 중이에요',
        description: '새로운 상태가 확인되면 활동에서 알려드릴게요.',
        processingProducts: processing,
      );
    }

    return _HomeViewData(
      productCount: products.length,
      actionCount: 0,
      headline: '지금은 확인할 내용이 없어요',
      description: '등록한 제품을 테비오가 계속 살펴보고 있어요.',
      processingProducts: const [],
    );
  }

  static bool _needsAction(ProductSummary product) =>
      product.status == RightsStatus.urgent ||
      product.status == RightsStatus.actionRequired ||
      product.status == RightsStatus.detected ||
      product.status == RightsStatus.unknown;

  static int _priority(RightsStatus status) => switch (status) {
    RightsStatus.urgent => 0,
    RightsStatus.actionRequired => 1,
    RightsStatus.unknown => 2,
    RightsStatus.detected => 3,
    _ => 4,
  };
}
