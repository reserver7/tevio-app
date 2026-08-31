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
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            tooltip: '제품 등록',
            icon: Icons.add,
            onPressed: () => context.push('/register'),
          ),
        ],
      ),
      body: TevioPageScrollView(
        storageKey: 'products-scroll',
        children: [
          TevioPageIntro(
            eyebrow: '내 제품',
            title: '등록한 제품 ${products.length}개',
            description: '제품을 검색하거나 상태별로 모아볼 수 있어요.',
          ),
          const SizedBox(height: TevioSpacing.lg),
          TevioTextField(
            controller: _searchController,
            hintText: '제품명, 제조사, 모델번호 검색',
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value.trim()),
            onSubmitted: (value) => setState(() => _query = value.trim()),
            prefixIcon: const Icon(Icons.search_outlined),
            suffixIcon: _query.isEmpty
                ? null
                : TevioIconButton(
                    tooltip: '검색어 지우기',
                    icon: Icons.close,
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
          const SizedBox(height: TevioSpacing.md),
          Row(
            children: [
              Text(
                '${visibleProducts.length}개 제품',
                style: TevioTypography.titleMedium,
              ),
              const Spacer(),
              TevioTextAction(
                label:
                    _filter == _ProductFilter.all &&
                        _sort == _ProductSort.priority
                    ? '보기 설정'
                    : '설정됨',
                onPressed: () => _showViewOptions(context),
              ),
            ],
          ),
          const SizedBox(height: TevioSpacing.md),
          if (visibleProducts.isEmpty)
            TevioEmptyState(
              title: _query.isNotEmpty
                  ? '검색 결과가 없어요'
                  : _filter == _ProductFilter.all
                  ? '등록된 제품이 없어요'
                  : '조건에 맞는 제품이 없어요',
              description: _query.isNotEmpty
                  ? '제품명, 제조사 또는 모델번호를 확인해 다시 검색해 보세요.'
                  : _filter == _ProductFilter.all
                  ? '제품을 등록하면 리콜, 보증, 반품·교환 정보를 한곳에서 관리할 수 있어요.'
                  : '보기 설정에서 다른 상태를 선택해 주세요.',
              actionLabel: _query.isNotEmpty
                  ? '검색어 지우기'
                  : _filter == _ProductFilter.all
                  ? '제품 등록하기'
                  : null,
              onActionPressed: _query.isNotEmpty
                  ? () {
                      _searchController.clear();
                      setState(() => _query = '');
                    }
                  : _filter == _ProductFilter.all
                  ? () => context.go('/register')
                  : null,
            ),
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
            _ProductLibraryRow(
              product: product,
              onTap: () => context.push('/products/${product.id}'),
            ),
            if (product != visibleProducts.last) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  List<ProductSummary> _visibleProducts(List<ProductSummary> products) {
    final filtered = products.where((product) {
      final query = _query.toLowerCase();
      if (query.isNotEmpty &&
          !product.name.toLowerCase().contains(query) &&
          !product.brand.toLowerCase().contains(query) &&
          !product.modelNumber.toLowerCase().contains(query)) {
        return false;
      }
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
            footer: TevioButton(
              label: '적용',
              onPressed: () =>
                  Navigator.of(context).pop((selectedFilter, selectedSort)),
            ),
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
                const SizedBox(height: TevioSpacing.sm),
              ],
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

class _ProductLibraryRow extends StatelessWidget {
  const _ProductLibraryRow({required this.product, required this.onTap});

  final ProductSummary product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${product.name}, ${product.brand}, ${product.modelNumber}, ${product.status.label}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TevioSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProductMonogram(product: product),
              const SizedBox(width: TevioSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: TevioSpacing.xxs),
                    Text(
                      '${product.brand} · ${product.modelNumber}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: TevioSpacing.sm),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: product.status.foreground,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: TevioSpacing.xs),
                        Expanded(
                          child: Text(
                            product.statusSummary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TevioSpacing.sm),
              Text(
                product.status.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: product.status.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductMonogram extends StatelessWidget {
  const _ProductMonogram({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: product.status.background,
        borderRadius: TevioRadius.mediumBorder,
      ),
      child: Text(
        product.name.trim().isEmpty
            ? '?'
            : product.name.trim().characters.first,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: product.status.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
