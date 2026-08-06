import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../domain/models/product_summary.dart';
import '../state/product_queries.dart';

enum _ProductFilter { all, attention, urgent, safe }

enum _ProductSort { priority, recent, name }

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  _ProductFilter _filter = _ProductFilter.all;
  _ProductSort _sort = _ProductSort.priority;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productSummariesQueryProvider);
    final visibleProducts = _visibleProducts(products);

    return Scaffold(
      appBar: TevioAppBar(
        title: '제품',
        automaticallyImplyLeading: false,
        actions: [
          TevioIconButton(
            tooltip: '제품 보기 설정',
            icon: Icons.tune,
            onPressed: () => _showViewOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: visibleProducts.isEmpty
            ? TevioEmptyState(
                title: _filter == _ProductFilter.all
                    ? '등록된 제품이 없어요'
                    : '조건에 맞는 제품이 없어요',
                description: _filter == _ProductFilter.all
                    ? '제품을 등록하면 리콜, 보증, 반품·교환 정보를 한곳에서 관리할 수 있어요.'
                    : '보기 설정에서 다른 상태를 선택해 주세요.',
                actionLabel: _filter == _ProductFilter.all ? '제품 등록하기' : null,
                onActionPressed: _filter == _ProductFilter.all
                    ? () => context.go('/register')
                    : null,
              )
            : ListView(
                key: const PageStorageKey('products-scroll'),
                padding: const EdgeInsets.fromLTRB(
                  TevioSpacing.lg,
                  TevioSpacing.sm,
                  TevioSpacing.lg,
                  TevioSpacing.xl,
                ),
                children: [
                  if (_filter != _ProductFilter.all ||
                      _sort != _ProductSort.priority) ...[
                    _ActiveViewSummary(
                      label: '${_filter.label} · ${_sort.label}',
                      onReset: () {
                        setState(() {
                          _filter = _ProductFilter.all;
                          _sort = _ProductSort.priority;
                        });
                      },
                    ),
                    const SizedBox(height: TevioSpacing.md),
                  ],
                  for (final product in visibleProducts) ...[
                    TevioProductSummaryCard(
                      name: product.name,
                      identity: '${product.brand} · ${product.modelNumber}',
                      status: product.status,
                      summary: product.statusSummary,
                      primaryLabel: product.recommendedAction,
                      onPrimaryPressed: () =>
                          context.push('/products/${product.id}'),
                    ),
                    const SizedBox(height: TevioSpacing.md),
                  ],
                ],
              ),
      ),
    );
  }

  List<ProductSummary> _visibleProducts(List<ProductSummary> products) {
    final filtered = products.where((product) {
      return switch (_filter) {
        _ProductFilter.all => true,
        _ProductFilter.attention =>
          product.status == RightsStatus.actionRequired ||
              product.status == RightsStatus.detected ||
              product.status == RightsStatus.processing,
        _ProductFilter.urgent => product.status == RightsStatus.urgent,
        _ProductFilter.safe =>
          product.status == RightsStatus.safe ||
              product.status == RightsStatus.completed,
      };
    }).toList();

    filtered.sort((a, b) {
      return switch (_sort) {
        _ProductSort.priority => _priorityFor(
          a.status,
        ).compareTo(_priorityFor(b.status)),
        _ProductSort.recent => b.purchasedAt.compareTo(a.purchasedAt),
        _ProductSort.name => a.name.compareTo(b.name),
      };
    });

    return filtered;
  }

  int _priorityFor(RightsStatus status) {
    return switch (status) {
      RightsStatus.urgent => 0,
      RightsStatus.actionRequired => 1,
      RightsStatus.detected => 2,
      RightsStatus.processing => 3,
      RightsStatus.unknown => 4,
      RightsStatus.safe => 5,
      RightsStatus.completed => 6,
    };
  }

  Future<void> _showViewOptions(BuildContext context) async {
    var selectedFilter = _filter;
    var selectedSort = _sort;

    final result = await TevioSheet.show<(_ProductFilter, _ProductSort)>(
      context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return TevioSheet(
            title: '제품 보기',
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.66,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '필요한 제품을 빠르게 찾을 수 있도록 보기 방식을 정하세요.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: TevioSpacing.xl),
                    Text('상태', style: TevioTypography.titleMedium),
                    const SizedBox(height: TevioSpacing.sm),
                    Wrap(
                      spacing: TevioSpacing.xs,
                      runSpacing: TevioSpacing.xs,
                      children: [
                        for (final filter in _ProductFilter.values)
                          TevioChoiceChip(
                            label: filter.label,
                            selected: selectedFilter == filter,
                            onSelected: (_) {
                              setModalState(() => selectedFilter = filter);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: TevioSpacing.xl),
                    Text('정렬', style: TevioTypography.titleMedium),
                    const SizedBox(height: TevioSpacing.sm),
                    Column(
                      children: [
                        for (final sort in _ProductSort.values)
                          _SortOptionTile(
                            sort: sort,
                            groupValue: selectedSort,
                            onChanged: (value) {
                              setModalState(() => selectedSort = value);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: TevioSpacing.xl),
                    TevioButton(
                      label: '적용',
                      onPressed: () => Navigator.of(
                        context,
                      ).pop((selectedFilter, selectedSort)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _filter = result.$1;
      _sort = result.$2;
    });
  }
}

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
    required this.sort,
    required this.groupValue,
    required this.onChanged,
  });

  final _ProductSort sort;
  final _ProductSort groupValue;
  final ValueChanged<_ProductSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return TevioRadioControl<_ProductSort>(
      value: sort,
      groupValue: groupValue,
      label: sort.label,
      onChanged: onChanged,
    );
  }
}

class _ActiveViewSummary extends StatelessWidget {
  const _ActiveViewSummary({required this.label, required this.onReset});

  final String label;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: TevioColors.textSecondary),
          ),
        ),
        TevioTextAction(label: '초기화', onPressed: onReset),
      ],
    );
  }
}

extension on _ProductFilter {
  String get label {
    return switch (this) {
      _ProductFilter.all => '전체',
      _ProductFilter.attention => '확인 필요',
      _ProductFilter.urgent => '긴급',
      _ProductFilter.safe => '정상',
    };
  }
}

extension on _ProductSort {
  String get label {
    return switch (this) {
      _ProductSort.priority => '중요한 순',
      _ProductSort.recent => '최근 구매 순',
      _ProductSort.name => '제품명 순',
    };
  }
}
