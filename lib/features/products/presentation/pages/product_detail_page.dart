import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../../notifications/domain/models/tevio_notification.dart';
import '../../../notifications/presentation/state/notification_queries.dart';
import '../../domain/models/product_activity.dart';
import '../../domain/models/product_summary.dart';
import '../state/product_activity_queries.dart';
import '../state/product_queries.dart';
import '../state/product_update_command.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerState = GoRouterState.of(context);
    final productId = routerState.pathParameters['id'];
    final openedFromNotifications =
        routerState.uri.queryParameters['from'] == 'notifications';
    final product = ref.watch(productSummaryQueryProvider(productId));
    final activities = product == null
        ? const <ProductActivity>[]
        : ref.watch(productActivitiesQueryProvider(product.id));
    final detail = product == null
        ? null
        : _ProductDetailViewData.from(product, activities);

    if (product == null) {
      return Scaffold(
        appBar: TevioAppBar(
          title: '제품 상세',
          leading: openedFromNotifications
              ? TevioIconButton(
                  tooltip: '알림으로 돌아가기',
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () => _goBackToNotifications(context),
                )
              : null,
        ),
        body: const SafeArea(
          child: TevioEmptyState(
            title: '제품을 찾을 수 없어요',
            description: '삭제되었거나 등록되지 않은 제품입니다.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: TevioAppBar(
        title: '제품 상세',
        actions: [
          TevioIconButton(
            tooltip: '제품 관리',
            icon: Icons.more_horiz,
            onPressed: () => _showProductManagementSheet(context, ref, product),
          ),
        ],
        leading: openedFromNotifications
            ? TevioIconButton(
                tooltip: '알림으로 돌아가기',
                icon: Icons.arrow_back_ios_new,
                onPressed: () => _goBackToNotifications(context),
              )
            : null,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            _ProductHeader(product: product),
            const SizedBox(height: TevioSpacing.xl),
            _PrimaryActionPanel(
              status: product.status,
              title: detail!.primaryTitle,
              description: product.statusSummary,
              actionLabel: product.recommendedAction,
              onTap:
                  product.status == RightsStatus.unknown &&
                      product.recommendedAction == '다시 확인하기'
                  ? () => _retryProductCheck(context, ref, product)
                  : product.status == RightsStatus.unknown
                  ? () => _showProductEditSheet(context, ref, product)
                  : () => _showRightsActionSheet(
                      context,
                      ref,
                      product,
                      detail.primaryAction,
                    ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '권리 상태'),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              padding: const EdgeInsets.symmetric(
                horizontal: TevioSpacing.md,
                vertical: TevioSpacing.xs,
              ),
              child: Column(
                children: [
                  for (final item in detail.rights) ...[
                    _RightsStatusRow(
                      item: item,
                      onTap: () => _showRightsActionSheet(
                        context,
                        ref,
                        product,
                        item.action,
                      ),
                    ),
                    if (item != detail.rights.last)
                      const Divider(height: TevioSpacing.xl),
                  ],
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            TevioSectionHeader(
              title: '제품 정보',
              actionLabel: '수정',
              onActionPressed: () =>
                  _showProductEditSheet(context, ref, product),
            ),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              padding: const EdgeInsets.all(TevioSpacing.md),
              child: Column(
                children: [
                  TevioInfoRow(label: '구매일', value: product.purchasedAt),
                  const Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '구매처', value: product.purchaseStore),
                  const Divider(height: TevioSpacing.xl),
                  TevioInfoRow(label: '영수증', value: product.receiptStatus),
                  const Divider(height: TevioSpacing.xl),
                  TevioInfoRow(
                    label: '마지막 확인',
                    value: product.lastCheckedAt == null
                        ? '확인 기록 없음'
                        : product.needsRecheck
                        ? '다시 확인 필요'
                        : '최근 확인됨',
                  ),
                ],
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            TevioSectionHeader(
              title: '상태 확인',
              actionLabel: '지금 확인',
              onActionPressed: product.status == RightsStatus.processing
                  ? null
                  : () => _confirmRecheck(context, ref, product),
            ),
            const SizedBox(height: TevioSpacing.xs),
            Text(
              product.status == RightsStatus.processing
                  ? '테비오가 최신 상태를 확인하고 있어요.'
                  : '마지막 확인 이후 변경된 권리 정보를 확인해요.',
              style: TevioTypography.bodyMedium.copyWith(
                color: TevioColors.textSecondary,
              ),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '이 제품 알림'),
            const SizedBox(height: TevioSpacing.sm),
            _ProductAlertSettings(product: product, ref: ref),
            const SizedBox(height: TevioSpacing.xl),
            const TevioSectionHeader(title: '최근 기록'),
            const SizedBox(height: TevioSpacing.sm),
            TevioCard(
              padding: const EdgeInsets.all(TevioSpacing.md),
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < detail.events.take(3).length;
                    index++
                  )
                    _TimelineRow(
                      event: detail.events[index],
                      isFirst: index == 0,
                      isLast: index == detail.events.take(3).length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goBackToNotifications(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/notifications');
  }

  Future<void> _showProductManagementSheet(
    BuildContext context,
    WidgetRef ref,
    ProductSummary product,
  ) async {
    final shouldDelete = await TevioSheet.show<bool>(
      context,
      builder: (sheetContext) => TevioSheet(
        title: '제품 관리',
        child: TevioListRow(
          icon: Icons.delete_outline,
          title: '제품 삭제',
          description: '제품 정보와 상태 확인 대상에서 제외합니다.',
          isDestructive: true,
          onTap: () => Navigator.of(sheetContext).pop(true),
        ),
      ),
    );
    if (shouldDelete == true && context.mounted) {
      await _confirmDelete(context, ref, product);
    }
  }

  Future<void> _confirmRecheck(
    BuildContext context,
    WidgetRef ref,
    ProductSummary product,
  ) async {
    final confirmed = await TevioSheet.show<bool>(
      context,
      builder: (sheetContext) => const TevioConfirmSheet(
        title: '권리 상태를 다시 확인할까요?',
        description: '등록된 제품 정보로 리콜, 보증, 반품·교환 상태를 다시 확인합니다.',
        confirmLabel: '지금 확인하기',
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    unawaited(ref.read(productUpdateCommandProvider).recheck(product));
    TevioSnackbar.show(context, '최신 상태를 확인하고 있어요.');
  }

  Future<void> _showRightsActionSheet(
    BuildContext context,
    WidgetRef ref,
    ProductSummary product,
    _RightsActionDetail action,
  ) async {
    final confirmed = await TevioSheet.show<bool>(
      context,
      builder: (context) => _RightsActionSheet(action: action),
    );

    if (confirmed != true || !context.mounted || !action.canComplete) {
      return;
    }

    final result = ref
        .read(productUpdateCommandProvider)
        .save(action.completedProduct(product));

    result.when(
      success: (savedProduct) {
        ref
            .read(productActivityCommandProvider)
            .record(
              ProductActivity(
                id: '${savedProduct.id}-${action.type.name}-${DateTime.now().millisecondsSinceEpoch}',
                productId: savedProduct.id,
                occurredAtLabel: '방금',
                title: action.resultTitle,
                description: action.resultDescription,
              ),
            );
        ref
            .read(notificationCommandProvider)
            .resolveProductNotification(
              productId: savedProduct.id,
              category: action.notificationCategory,
              title: action.notificationResultTitle,
              description: action.notificationResultDescription,
            );

        TevioSnackbar.show(context, action.resultToast);
      },
      failure: (failure) {
        TevioSnackbar.show(context, failure.message);
      },
    );
  }

  Future<void> _showProductEditSheet(
    BuildContext context,
    WidgetRef ref,
    ProductSummary product,
  ) async {
    final updatedProduct = await TevioSheet.show<ProductSummary>(
      context,
      builder: (context) => _ProductEditSheet(product: product),
    );

    if (updatedProduct == null || !context.mounted) {
      return;
    }

    final requiresRecheck = product.status == RightsStatus.unknown;
    final productToSave = requiresRecheck
        ? updatedProduct.copyWith(
            status: RightsStatus.processing,
            statusSummary: '보완한 정보로 권리 상태를 다시 확인하고 있어요.',
            recommendedAction: '확인 상태 보기',
          )
        : updatedProduct;
    final result = ref.read(productUpdateCommandProvider).save(productToSave);

    result.when(
      success: (savedProduct) {
        ref
            .read(productActivityCommandProvider)
            .record(
              ProductActivity(
                id: '${savedProduct.id}-updated-${DateTime.now().millisecondsSinceEpoch}',
                productId: savedProduct.id,
                occurredAtLabel: '방금',
                title: '제품 정보가 수정됐어요',
                description: requiresRecheck
                    ? '보완한 정보로 권리 상태를 다시 확인하기 시작했어요.'
                    : '변경된 정보로 권리 상태를 다시 확인합니다.',
              ),
            );

        TevioSnackbar.show(
          context,
          requiresRecheck
              ? '정보를 저장했어요. 테비오가 다시 확인하고 있어요.'
              : '제품 정보를 저장했어요. 테비오가 다시 확인합니다.',
        );
        if (requiresRecheck) {
          Future<void>.delayed(TevioMotion.slow, () {
            if (!context.mounted) {
              return;
            }
            final completed = savedProduct.copyWith(
              status: RightsStatus.safe,
              statusSummary: '보완한 정보 기준으로 확인할 문제는 없어요.',
              recommendedAction: '상태 상세 보기',
            );
            ref.read(productUpdateCommandProvider).save(completed);
            ref
                .read(productActivityCommandProvider)
                .record(
                  ProductActivity(
                    id: '${completed.id}-rechecked-${DateTime.now().millisecondsSinceEpoch}',
                    productId: completed.id,
                    occurredAtLabel: '방금',
                    title: '권리 상태를 다시 확인했어요',
                    description: completed.statusSummary,
                  ),
                );
            ref
                .read(notificationCommandProvider)
                .resolveProductNotification(
                  productId: completed.id,
                  category: TevioNotificationCategory.infoRequired,
                  title: '제품 정보를 확인했어요',
                  description: completed.statusSummary,
                );
            TevioSnackbar.show(context, '확인이 끝났어요. 현재 문제는 없어요.');
          });
        }
      },
      failure: (failure) {
        TevioSnackbar.show(context, failure.message);
      },
    );
  }

  Future<void> _retryProductCheck(
    BuildContext context,
    WidgetRef ref,
    ProductSummary product,
  ) async {
    final processing = product.copyWith(
      status: RightsStatus.processing,
      statusSummary: '연결을 확인하고 권리 상태를 다시 조회하고 있어요.',
      recommendedAction: '확인 상태 보기',
    );
    ref.read(productUpdateCommandProvider).save(processing);
    ref
        .read(productActivityCommandProvider)
        .record(
          ProductActivity(
            id: '${product.id}-retry-${DateTime.now().millisecondsSinceEpoch}',
            productId: product.id,
            occurredAtLabel: '방금',
            title: '권리 상태를 다시 확인하고 있어요',
            description: '연결이 복구되면 확인 결과를 바로 알려드릴게요.',
          ),
        );
    TevioSnackbar.show(context, '다시 확인하고 있어요.');

    await Future<void>.delayed(TevioMotion.slow);
    if (!context.mounted) {
      return;
    }
    final completed = processing.copyWith(
      status: RightsStatus.safe,
      statusSummary: '연결이 복구되어 현재 확인할 문제는 없어요.',
      recommendedAction: '상태 상세 보기',
    );
    ref.read(productUpdateCommandProvider).save(completed);
    ref
        .read(productActivityCommandProvider)
        .record(
          ProductActivity(
            id: '${product.id}-retry-complete-${DateTime.now().millisecondsSinceEpoch}',
            productId: product.id,
            occurredAtLabel: '방금',
            title: '권리 상태 확인을 완료했어요',
            description: completed.statusSummary,
          ),
        );
    ref
        .read(notificationCommandProvider)
        .resolveProductNotification(
          productId: product.id,
          category: TevioNotificationCategory.infoRequired,
          title: '권리 상태를 확인했어요',
          description: completed.statusSummary,
        );
    TevioSnackbar.show(context, '확인이 끝났어요.');
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ProductSummary product,
  ) async {
    final confirmed = await TevioSheet.show<bool>(
      context,
      builder: (sheetContext) => TevioConfirmSheet(
        title: '제품을 삭제할까요?',
        description:
            '${product.name}의 제품 정보와 상태 확인 대상에서 제외합니다. 삭제 직후에는 되돌릴 수 있어요.',
        confirmLabel: '제품 삭제',
        isDestructive: true,
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final result = ref.read(productUpdateCommandProvider).delete(product);
    result.when(
      success: (removedProduct) {
        final removedNotifications = ref
            .read(notificationCommandProvider)
            .removeForProduct(product.id);
        final removedActivities = ref
            .read(productActivityCommandProvider)
            .removeForProduct(product.id);
        context.go('/products');
        TevioSnackbar.show(
          context,
          '제품을 삭제했어요.',
          actionLabel: '되돌리기',
          onAction: () {
            ref.read(productUpdateCommandProvider).restore(removedProduct);
            ref
                .read(notificationCommandProvider)
                .restoreMany(removedNotifications);
            ref
                .read(productActivityCommandProvider)
                .restoreMany(removedActivities);
          },
        );
      },
      failure: (failure) {
        TevioSnackbar.show(context, failure.message);
      },
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: TevioTypography.titleLarge),
              const SizedBox(height: TevioSpacing.xxs),
              Text(
                '${product.brand} · ${product.modelNumber}',
                style: TevioTypography.bodyMedium.copyWith(
                  color: TevioColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: TevioSpacing.md),
        TevioStatusBadge(status: product.status),
      ],
    );
  }
}

class _PrimaryActionPanel extends StatelessWidget {
  const _PrimaryActionPanel({
    required this.status,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  final RightsStatus status;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TevioCard(
      padding: const EdgeInsets.all(TevioSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ActionIndicator(status: status),
              const SizedBox(width: TevioSpacing.xs),
              Text(
                _actionEyebrow,
                style: textTheme.labelLarge?.copyWith(
                  color: status.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: TevioSpacing.md),
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: TevioSpacing.xs),
          Text(description, style: textTheme.bodyMedium),
          const SizedBox(height: TevioSpacing.lg),
          TevioButton(label: actionLabel, onPressed: onTap),
        ],
      ),
    );
  }

  String get _actionEyebrow {
    return switch (status) {
      RightsStatus.urgent => '지금 확인해 주세요',
      RightsStatus.actionRequired => '확인이 필요해요',
      RightsStatus.detected => '확인하고 있어요',
      RightsStatus.processing => '처리 중이에요',
      RightsStatus.safe || RightsStatus.completed => '현재 상태',
      RightsStatus.unknown => '정보가 필요해요',
    };
  }
}

class _ProductAlertSettings extends StatelessWidget {
  const _ProductAlertSettings({required this.product, required this.ref});

  final ProductSummary product;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ProductAlertToggle(
            title: '리콜 및 안전 문제',
            value: product.recallAlertEnabled,
            onChanged: (value) =>
                _save(context, product.copyWith(recallAlertEnabled: value)),
            isFirst: true,
          ),
          _ProductAlertToggle(
            title: '보증 만료',
            value: product.warrantyAlertEnabled,
            onChanged: (value) =>
                _save(context, product.copyWith(warrantyAlertEnabled: value)),
          ),
          _ProductAlertToggle(
            title: '반품·교환 기간',
            value: product.returnAlertEnabled,
            onChanged: (value) =>
                _save(context, product.copyWith(returnAlertEnabled: value)),
            isLast: true,
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context, ProductSummary updatedProduct) {
    final result = ref.read(productUpdateCommandProvider).save(updatedProduct);

    result.when(
      success: (_) {
        TevioSnackbar.show(context, '이 제품 알림 설정을 저장했어요.');
      },
      failure: (failure) {
        TevioSnackbar.show(context, failure.message);
      },
    );
  }
}

class _ProductAlertToggle extends StatelessWidget {
  const _ProductAlertToggle({
    required this.title,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
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
          child: TevioSwitch(value: value, onChanged: onChanged, label: title),
        ),
        if (isLast) const SizedBox(height: TevioSpacing.xs),
      ],
    );
  }
}

class _ActionIndicator extends StatelessWidget {
  const _ActionIndicator({required this.status});

  final RightsStatus status;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: TevioSpacing.sm,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: status.foreground,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _RightsStatusRow extends StatelessWidget {
  const _RightsStatusRow({required this.item, required this.onTap});

  final _RightsDetailItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: TevioColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: TevioRadius.mediumBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TevioSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title, style: textTheme.titleMedium),
                        ),
                        _RightsValuePill(item: item),
                      ],
                    ),
                    const SizedBox(height: TevioSpacing.xxs),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RightsValuePill extends StatelessWidget {
  const _RightsValuePill({required this.item});

  final _RightsDetailItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: item.status.background,
        borderRadius: TevioRadius.fullBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TevioSpacing.sm,
          vertical: TevioSpacing.xxs,
        ),
        child: Text(
          item.value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: item.status.foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RightsActionSheet extends StatelessWidget {
  const _RightsActionSheet({required this.action});

  final _RightsActionDetail action;

  @override
  Widget build(BuildContext context) {
    return TevioSheet(
      title: action.title,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.66,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: action.status.background,
                  borderRadius: TevioRadius.fullBorder,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(TevioSpacing.md),
                  child: Icon(action.icon, color: action.status.foreground),
                ),
              ),
              const SizedBox(height: TevioSpacing.md),
              Text(
                action.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TevioSpacing.lg),
              TevioCard(
                padding: const EdgeInsets.all(TevioSpacing.md),
                child: Column(
                  children: [
                    for (final item in action.items) ...[
                      TevioInfoRow(label: item.label, value: item.value),
                      if (item != action.items.last)
                        const Divider(height: TevioSpacing.xl),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: TevioSpacing.lg),
              TevioButton(
                label: action.ctaLabel,
                icon: action.ctaIcon,
                onPressed: () => Navigator.of(context).pop(action.canComplete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionInfoItem {
  const _ActionInfoItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _ProductEditSheet extends StatefulWidget {
  const _ProductEditSheet({required this.product});

  final ProductSummary product;

  @override
  State<_ProductEditSheet> createState() => _ProductEditSheetState();
}

class _ProductEditSheetState extends State<_ProductEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelNumberController;
  late final TextEditingController _purchasedAtController;
  late final TextEditingController _purchaseStoreController;
  late final TextEditingController _receiptStatusController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _brandController = TextEditingController(text: widget.product.brand);
    _modelNumberController = TextEditingController(
      text: widget.product.modelNumber,
    );
    _purchasedAtController = TextEditingController(
      text: widget.product.purchasedAt,
    );
    _purchaseStoreController = TextEditingController(
      text: widget.product.purchaseStore,
    );
    _receiptStatusController = TextEditingController(
      text: widget.product.receiptStatus,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelNumberController.dispose();
    _purchasedAtController.dispose();
    _purchaseStoreController.dispose();
    _receiptStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TevioSheet(
      title: '제품 정보 수정',
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom + TevioSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정보를 바꾸면 테비오가 리콜, 보증, 반품·교환 가능 기간을 다시 확인합니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TevioSpacing.lg),
              _EditField(label: '제품명', controller: _nameController),
              const SizedBox(height: TevioSpacing.md),
              _EditField(label: '제조사', controller: _brandController),
              const SizedBox(height: TevioSpacing.md),
              _EditField(label: '모델번호', controller: _modelNumberController),
              const SizedBox(height: TevioSpacing.md),
              _EditField(label: '구매일', controller: _purchasedAtController),
              const SizedBox(height: TevioSpacing.md),
              _EditField(label: '구매처', controller: _purchaseStoreController),
              const SizedBox(height: TevioSpacing.md),
              _EditField(label: '영수증', controller: _receiptStatusController),
              const SizedBox(height: TevioSpacing.lg),
              TevioButton(
                label: '저장',
                icon: Icons.check,
                onPressed: () => Navigator.of(context).pop(
                  widget.product.copyWith(
                    name: _valueOrCurrent(_nameController, widget.product.name),
                    brand: _valueOrCurrent(
                      _brandController,
                      widget.product.brand,
                    ),
                    modelNumber: _valueOrCurrent(
                      _modelNumberController,
                      widget.product.modelNumber,
                    ),
                    purchasedAt: _valueOrCurrent(
                      _purchasedAtController,
                      widget.product.purchasedAt,
                    ),
                    purchaseStore: _valueOrCurrent(
                      _purchaseStoreController,
                      widget.product.purchaseStore,
                    ),
                    receiptStatus: _valueOrCurrent(
                      _receiptStatusController,
                      widget.product.receiptStatus,
                    ),
                    status: RightsStatus.detected,
                    statusSummary: '제품 정보가 수정되어 테비오가 다시 확인하고 있어요.',
                    recommendedAction: '권리 상태 확인',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _valueOrCurrent(
    TextEditingController controller,
    String currentValue,
  ) {
    final value = controller.text.trim();

    if (value.isEmpty) {
      return currentValue;
    }

    return value;
  }
}

class _EditField extends StatelessWidget {
  const _EditField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TevioTextField(controller: controller, label: label);
  }
}

class _RightsActionDetail {
  const _RightsActionDetail({
    required this.type,
    required this.icon,
    required this.status,
    required this.title,
    required this.description,
    required this.items,
    required this.ctaLabel,
    required this.ctaIcon,
  });

  final _RightsActionType type;
  final IconData icon;
  final RightsStatus status;
  final String title;
  final String description;
  final List<_ActionInfoItem> items;
  final String ctaLabel;
  final IconData ctaIcon;

  TevioNotificationCategory get notificationCategory {
    return switch (type) {
      _RightsActionType.recall => TevioNotificationCategory.immediate,
      _RightsActionType.warranty => TevioNotificationCategory.dueSoon,
      _RightsActionType.productInfo => TevioNotificationCategory.infoRequired,
      _RightsActionType.returnWindow => TevioNotificationCategory.general,
      _RightsActionType.service => TevioNotificationCategory.processing,
      _RightsActionType.overview => TevioNotificationCategory.general,
    };
  }

  bool get canComplete {
    return switch (type) {
      _RightsActionType.recall ||
      _RightsActionType.warranty ||
      _RightsActionType.productInfo => true,
      _RightsActionType.returnWindow ||
      _RightsActionType.service ||
      _RightsActionType.overview => false,
    };
  }

  String get resultTitle {
    return switch (type) {
      _RightsActionType.recall => '리콜 정보를 확인했어요',
      _RightsActionType.warranty => '보증 정보를 확인했어요',
      _RightsActionType.productInfo => '권리 상태를 확인했어요',
      _RightsActionType.returnWindow => '반품·교환 정보를 확인했어요',
      _RightsActionType.service => 'A/S 정보를 확인했어요',
      _RightsActionType.overview => '권리 상태를 확인했어요',
    };
  }

  String get resultDescription {
    return switch (type) {
      _RightsActionType.recall => '모델번호 확인이 완료되어 대응 상태로 전환했어요.',
      _RightsActionType.warranty => '영수증과 구매 정보를 기준으로 보증 대응 준비를 마쳤어요.',
      _RightsActionType.productInfo => '등록된 제품 정보 기준으로 확인할 문제는 없어요.',
      _RightsActionType.returnWindow => '반품·교환 가능 조건을 확인했어요.',
      _RightsActionType.service => 'A/S 접수에 필요한 정보를 확인했어요.',
      _RightsActionType.overview => '현재 필요한 조치가 없는 상태를 확인했어요.',
    };
  }

  String get resultToast {
    return switch (type) {
      _RightsActionType.recall => '리콜 확인 상태로 변경했어요.',
      _RightsActionType.warranty => '보증 확인 상태로 변경했어요.',
      _RightsActionType.productInfo => '권리 상태 확인을 완료했어요.',
      _RightsActionType.returnWindow ||
      _RightsActionType.service ||
      _RightsActionType.overview => '확인했어요.',
    };
  }

  String get notificationResultTitle {
    return switch (type) {
      _RightsActionType.recall => '리콜 정보를 확인했어요',
      _RightsActionType.warranty => '보증 정보를 확인했어요',
      _RightsActionType.productInfo => '제품 권리 상태를 확인했어요',
      _RightsActionType.returnWindow => '반품·교환 정보를 확인했어요',
      _RightsActionType.service => 'A/S 정보를 확인했어요',
      _RightsActionType.overview => '권리 상태를 확인했어요',
    };
  }

  String get notificationResultDescription {
    return switch (type) {
      _RightsActionType.recall => '모델번호 확인 후 대응 상태로 전환됐습니다.',
      _RightsActionType.warranty => '보증 종료 전 필요한 정보를 확인했습니다.',
      _RightsActionType.productInfo => '등록된 제품 정보 기준으로 확인할 문제는 없어요.',
      _RightsActionType.returnWindow => '반품·교환 가능 조건을 확인했습니다.',
      _RightsActionType.service => 'A/S 접수에 필요한 정보를 확인했습니다.',
      _RightsActionType.overview => '현재 필요한 조치가 없는 상태입니다.',
    };
  }

  ProductSummary completedProduct(ProductSummary product) {
    return switch (type) {
      _RightsActionType.recall => product.copyWith(
        status: RightsStatus.processing,
        statusSummary: '리콜 정보를 확인했어요. 필요한 대응을 준비하고 있습니다.',
        recommendedAction: '대응 상태 보기',
      ),
      _RightsActionType.warranty => product.copyWith(
        status: RightsStatus.processing,
        statusSummary: '보증 정보를 확인했어요. A/S나 점검 접수를 준비할 수 있어요.',
        recommendedAction: 'A/S 준비 보기',
      ),
      _RightsActionType.productInfo => product.copyWith(
        status: RightsStatus.safe,
        statusSummary: '현재 등록된 정보 기준으로 확인할 문제는 없어요.',
        recommendedAction: '상태 상세 보기',
      ),
      _RightsActionType.returnWindow ||
      _RightsActionType.service ||
      _RightsActionType.overview => product,
    };
  }

  factory _RightsActionDetail.forPrimary(ProductSummary product) {
    return switch (product.status) {
      RightsStatus.urgent => _RightsActionDetail.forRecall(product),
      RightsStatus.actionRequired => _RightsActionDetail.forWarranty(product),
      RightsStatus.detected => _RightsActionDetail.forProductInfo(product),
      RightsStatus.processing => _RightsActionDetail.forService(product),
      RightsStatus.safe ||
      RightsStatus.completed => _RightsActionDetail.forOverview(product),
      RightsStatus.unknown => _RightsActionDetail.forProductInfo(product),
    };
  }

  factory _RightsActionDetail.forRecall(ProductSummary product) {
    return _RightsActionDetail(
      type: _RightsActionType.recall,
      icon: Icons.warning_amber_rounded,
      status: product.status == RightsStatus.urgent
          ? RightsStatus.urgent
          : RightsStatus.safe,
      title: product.status == RightsStatus.urgent
          ? '리콜 대상 여부를 확인하세요'
          : '확인된 리콜 대상은 없어요',
      description: product.status == RightsStatus.urgent
          ? '등록된 모델과 유사한 공식 리콜 정보가 있습니다. 모델번호를 한 번 더 확인한 뒤 사용 여부를 판단하세요.'
          : '테비오가 현재 등록 정보 기준으로 리콜 정보를 확인하고 있어요.',
      items: [
        _ActionInfoItem(label: '제품', value: '${product.brand} ${product.name}'),
        _ActionInfoItem(label: '모델번호', value: product.modelNumber),
        _ActionInfoItem(label: '상태', value: product.status.label),
      ],
      ctaLabel: product.status == RightsStatus.urgent ? '확인했어요' : '닫기',
      ctaIcon: Icons.check,
    );
  }

  factory _RightsActionDetail.forWarranty(ProductSummary product) {
    return _RightsActionDetail(
      type: _RightsActionType.warranty,
      icon: Icons.verified_user_outlined,
      status: product.status == RightsStatus.actionRequired
          ? RightsStatus.actionRequired
          : RightsStatus.safe,
      title: '보증 정보를 확인하세요',
      description: '무상보증 종료 전에 영수증, 구매처, 점검 가능 여부를 확인해 두면 대응이 쉬워집니다.',
      items: [
        _ActionInfoItem(label: '남은 기간', value: product.warrantyText),
        _ActionInfoItem(label: '구매일', value: product.purchasedAt),
        _ActionInfoItem(label: '영수증', value: product.receiptStatus),
      ],
      ctaLabel: '확인했어요',
      ctaIcon: Icons.check,
    );
  }

  factory _RightsActionDetail.forReturn(ProductSummary product) {
    return _RightsActionDetail(
      type: _RightsActionType.returnWindow,
      icon: Icons.assignment_return_outlined,
      status: product.returnText.contains('남음')
          ? RightsStatus.detected
          : RightsStatus.completed,
      title: '반품·교환 가능 기간',
      description: product.returnText.contains('남음')
          ? '기간이 남아 있을 때는 구매처 정책, 포장 상태, 사용 여부를 함께 확인해야 합니다.'
          : '등록된 구매 정보 기준으로 반품·교환 가능 기간은 종료됐습니다.',
      items: [
        _ActionInfoItem(label: '가능 기간', value: product.returnText),
        _ActionInfoItem(label: '구매처', value: product.purchaseStore),
        _ActionInfoItem(label: '구매일', value: product.purchasedAt),
      ],
      ctaLabel: '닫기',
      ctaIcon: Icons.close,
    );
  }

  factory _RightsActionDetail.forService(ProductSummary product) {
    return _RightsActionDetail(
      type: _RightsActionType.service,
      icon: Icons.build_circle_outlined,
      status: RightsStatus.processing,
      title: 'A/S 접수 준비',
      description: '문제가 생기면 모델번호, 구매일, 영수증 상태를 바탕으로 접수에 필요한 정보를 정리할 수 있어요.',
      items: [
        _ActionInfoItem(label: '모델번호', value: product.modelNumber),
        _ActionInfoItem(label: '구매처', value: product.purchaseStore),
        _ActionInfoItem(label: '영수증', value: product.receiptStatus),
      ],
      ctaLabel: '닫기',
      ctaIcon: Icons.close,
    );
  }

  factory _RightsActionDetail.forProductInfo(ProductSummary product) {
    return _RightsActionDetail(
      type: _RightsActionType.productInfo,
      icon: Icons.manage_search_outlined,
      status: RightsStatus.detected,
      title: '제품 정보를 확인하고 있어요',
      description: '등록 직후에는 테비오가 모델번호와 구매 정보를 기준으로 권리 상태를 계산합니다.',
      items: [
        _ActionInfoItem(label: '제품', value: '${product.brand} ${product.name}'),
        _ActionInfoItem(label: '모델번호', value: product.modelNumber),
        _ActionInfoItem(label: '구매일', value: product.purchasedAt),
      ],
      ctaLabel: '확인했어요',
      ctaIcon: Icons.check,
    );
  }

  factory _RightsActionDetail.forOverview(ProductSummary product) {
    return _RightsActionDetail(
      type: _RightsActionType.overview,
      icon: Icons.shield_outlined,
      status: RightsStatus.safe,
      title: '현재 필요한 조치는 없어요',
      description: '테비오가 등록된 제품의 리콜, 보증, 반품·교환 가능 기간을 계속 확인합니다.',
      items: [
        _ActionInfoItem(label: '리콜', value: '대상 없음'),
        _ActionInfoItem(label: '보증', value: product.warrantyText),
        _ActionInfoItem(label: '반품·교환', value: product.returnText),
      ],
      ctaLabel: '닫기',
      ctaIcon: Icons.close,
    );
  }
}

enum _RightsActionType {
  recall,
  warranty,
  returnWindow,
  service,
  productInfo,
  overview,
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  final ProductActivity event;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              if (!isFirst)
                const SizedBox(
                  height: TevioSpacing.sm,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: TevioColors.divider,
                  ),
                ),
              _TimelinePulseDot(
                status: event.status,
                isActive: event.status.isMotionImportant,
                isEmphasized: isFirst,
              ),
              if (!isLast)
                const SizedBox(
                  height: 58,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: TevioColors.divider,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: TevioSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(TevioSpacing.sm),
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : TevioSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(event.title, style: textTheme.titleSmall),
                      ),
                      const SizedBox(width: TevioSpacing.sm),
                      _TimelineTimePill(label: event.occurredAtLabel),
                    ],
                  ),
                  const SizedBox(height: TevioSpacing.xxs),
                  Text(event.description, style: textTheme.bodyMedium),
                  if (isFirst) ...[
                    const SizedBox(height: TevioSpacing.xs),
                    Text(
                      event.status.label,
                      style: textTheme.labelLarge?.copyWith(
                        color: event.status.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelinePulseDot extends StatefulWidget {
  const _TimelinePulseDot({
    required this.status,
    required this.isActive,
    required this.isEmphasized,
  });

  final RightsStatus status;
  final bool isActive;
  final bool isEmphasized;

  @override
  State<_TimelinePulseDot> createState() => _TimelinePulseDotState();
}

class _TimelinePulseDotState extends State<_TimelinePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: TevioMotion.pulse);
    _scale = Tween<double>(begin: 1, end: widget.status.pulseScale).animate(
      CurvedAnimation(parent: _controller, curve: TevioMotion.standardCurve),
    );
    _opacity = Tween<double>(begin: widget.status.pulseOpacity, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: TevioMotion.standardCurve),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _TimelinePulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive ||
        oldWidget.status != widget.status) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.isActive) {
      _controller.repeat();
      return;
    }

    _controller.stop();
    _controller.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.isEmphasized ? 14.0 : 8.0;
    final dotColor = widget.isEmphasized || widget.status.isMotionImportant
        ? widget.status.foreground
        : TevioColors.textTertiary;

    return SizedBox.square(
      dimension: 28,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isActive)
                  Transform.scale(
                    scale: _scale.value,
                    child: Opacity(
                      opacity: _opacity.value,
                      child: SizedBox.square(
                        dimension: dotSize,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: dotColor,
                            borderRadius: TevioRadius.fullBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                child!,
              ],
            );
          },
          child: SizedBox.square(
            dimension: dotSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: dotColor,
                borderRadius: TevioRadius.fullBorder,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineTimePill extends StatelessWidget {
  const _TimelineTimePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TevioColors.divider,
        borderRadius: TevioRadius.fullBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TevioSpacing.sm,
          vertical: TevioSpacing.xxs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: TevioColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

extension _ProductActivityStatus on ProductActivity {
  RightsStatus get status {
    if (title.contains('리콜')) {
      return RightsStatus.urgent;
    }

    if (title.contains('보증') || title.contains('수정') || title.contains('요청')) {
      return RightsStatus.processing;
    }

    if (title.contains('등록') || title.contains('구매')) {
      return RightsStatus.completed;
    }

    return RightsStatus.detected;
  }
}

extension _RightsStatusMotion on RightsStatus {
  bool get isMotionImportant {
    return switch (this) {
      RightsStatus.urgent || RightsStatus.processing => true,
      RightsStatus.safe ||
      RightsStatus.detected ||
      RightsStatus.actionRequired ||
      RightsStatus.completed ||
      RightsStatus.unknown => false,
    };
  }

  double get pulseScale {
    return switch (this) {
      RightsStatus.urgent => 2.4,
      RightsStatus.processing => 2.0,
      RightsStatus.safe ||
      RightsStatus.detected ||
      RightsStatus.actionRequired ||
      RightsStatus.completed ||
      RightsStatus.unknown => 1,
    };
  }

  double get pulseOpacity {
    return switch (this) {
      RightsStatus.urgent => 0.24,
      RightsStatus.processing => 0.18,
      RightsStatus.safe ||
      RightsStatus.detected ||
      RightsStatus.actionRequired ||
      RightsStatus.completed ||
      RightsStatus.unknown => 0,
    };
  }
}

class _ProductDetailViewData {
  const _ProductDetailViewData({
    required this.primaryTitle,
    required this.primaryDueText,
    required this.primaryAction,
    required this.rights,
    required this.events,
  });

  final String primaryTitle;
  final String primaryDueText;
  final _RightsActionDetail primaryAction;
  final List<_RightsDetailItem> rights;
  final List<ProductActivity> events;

  factory _ProductDetailViewData.from(
    ProductSummary product,
    List<ProductActivity> activities,
  ) {
    final recall = _recallItem(product);
    final warranty = _RightsDetailItem(
      icon: Icons.verified_user_outlined,
      status: product.status == RightsStatus.actionRequired
          ? RightsStatus.actionRequired
          : RightsStatus.safe,
      title: '보증',
      value: product.warrantyText,
      description: product.status == RightsStatus.actionRequired
          ? '종료 전에 영수증과 점검 가능 여부를 확인하세요.'
          : '무상보증 기간을 계속 추적하고 있어요.',
      action: _RightsActionDetail.forWarranty(product),
    );
    final returns = _RightsDetailItem(
      icon: Icons.assignment_return_outlined,
      status: product.returnText.contains('남음')
          ? RightsStatus.detected
          : RightsStatus.completed,
      title: '반품·교환',
      value: product.returnText,
      description: product.returnText.contains('남음')
          ? '가능 기간 안에 필요한 조건을 확인할 수 있어요.'
          : '현재 등록 정보 기준으로 가능 기간이 종료됐어요.',
      action: _RightsActionDetail.forReturn(product),
    );
    final service = _RightsDetailItem(
      icon: Icons.build_circle_outlined,
      status: RightsStatus.processing,
      title: 'A/S',
      value: '접수 가능',
      description: '문제가 생기면 제품 정보와 영수증을 바탕으로 접수를 도와드려요.',
      action: _RightsActionDetail.forService(product),
    );

    return _ProductDetailViewData(
      primaryTitle: _primaryTitleFor(product),
      primaryDueText: _primaryDueTextFor(product),
      primaryAction: _RightsActionDetail.forPrimary(product),
      rights: [recall, warranty, returns, service],
      events: _eventsFor(product, activities),
    );
  }

  static List<ProductActivity> _eventsFor(
    ProductSummary product,
    List<ProductActivity> activities,
  ) {
    return [
      ...activities,
      ProductActivity(
        id: '${product.id}-current-status',
        productId: product.id,
        occurredAtLabel: '오늘',
        title: product.statusSummary,
        description: '현재 등록 정보 기준으로 계산된 상태입니다.',
      ),
      ProductActivity(
        id: '${product.id}-purchase',
        productId: product.id,
        occurredAtLabel: product.purchasedAt,
        title: '${product.purchaseStore} 구매 정보가 등록됐어요.',
        description: '구매 이후 권리 확인에 사용하는 기본 정보입니다.',
      ),
    ];
  }

  static _RightsDetailItem _recallItem(ProductSummary product) {
    return _RightsDetailItem(
      icon: Icons.warning_amber_rounded,
      status: product.status == RightsStatus.urgent
          ? RightsStatus.urgent
          : RightsStatus.safe,
      title: '리콜',
      value: product.status == RightsStatus.urgent ? '확인 필요' : '대상 없음',
      description: product.status == RightsStatus.urgent
          ? '등록된 모델과 유사한 공식 리콜 정보가 있어요.'
          : '현재 확인된 리콜 대상은 없어요.',
      action: _RightsActionDetail.forRecall(product),
    );
  }

  static String _primaryTitleFor(ProductSummary product) {
    return switch (product.status) {
      RightsStatus.urgent => '리콜 대상인지 먼저 확인해 주세요',
      RightsStatus.actionRequired => '보증 만료 전에 확인해 주세요',
      RightsStatus.detected => '등록 정보를 확인하고 있어요',
      RightsStatus.processing => '처리 상태를 확인하고 있어요',
      RightsStatus.safe ||
      RightsStatus.completed ||
      RightsStatus.unknown => '현재 필요한 조치는 없어요',
    };
  }

  static String _primaryDueTextFor(ProductSummary product) {
    return switch (product.status) {
      RightsStatus.urgent => '즉시 확인 권장',
      RightsStatus.detected => '확인 중',
      RightsStatus.processing => '처리 중',
      RightsStatus.safe ||
      RightsStatus.completed ||
      RightsStatus.actionRequired ||
      RightsStatus.unknown => product.warrantyText,
    };
  }
}

class _RightsDetailItem {
  const _RightsDetailItem({
    required this.icon,
    required this.status,
    required this.title,
    required this.value,
    required this.description,
    required this.action,
  });

  final IconData icon;
  final RightsStatus status;
  final String title;
  final String value;
  final String description;
  final _RightsActionDetail action;
}
