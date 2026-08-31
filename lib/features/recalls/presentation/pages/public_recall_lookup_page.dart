import 'package:flutter/material.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class PublicRecallLookupPage extends StatefulWidget {
  const PublicRecallLookupPage({super.key});

  @override
  State<PublicRecallLookupPage> createState() => _PublicRecallLookupPageState();
}

class _PublicRecallLookupPageState extends State<PublicRecallLookupPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  _LookupState _state = _LookupState.idle;
  String _searchedTerm = '';

  bool get _canSearch => _controller.text.trim().length >= 2;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TevioAppBar(title: '공개 리콜 조회'),
      body: TevioPageScrollView(
        children: [
          const TevioPageIntro(
            eyebrow: 'PUBLIC LOOKUP',
            title: '공개 리콜 조회',
            description: '제품을 등록하지 않아도 제품명이나 모델번호로 공개 리콜 가능성을 검색할 수 있어요.',
          ),
          const SizedBox(height: TevioSpacing.xl),
          TevioTextField(
            controller: _controller,
            hintText: '제품명, 제조사, 모델번호 검색',
            textInputAction: TextInputAction.search,
            focusNode: _focusNode,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _lookup(),
            prefixIcon: const Icon(Icons.search_outlined),
            suffixIcon: _controller.text.isEmpty
                ? null
                : TevioIconButton(
                    tooltip: '검색어 지우기',
                    icon: Icons.close,
                    onPressed: () {
                      _controller.clear();
                      setState(() => _state = _LookupState.idle);
                    },
                  ),
          ),
          SizedBox(height: TevioSpacing.lg),
          TevioButton(
            label: '리콜 조회하기',
            icon: Icons.search,
            onPressed: _canSearch && _state != _LookupState.loading
                ? _lookup
                : null,
          ),
          const SizedBox(height: TevioSpacing.xl),
          _buildResult(),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return switch (_state) {
      _LookupState.idle => const TevioEmptyState(
        title: '제품 정보를 입력해 주세요',
        description: '제품명이나 모델번호를 입력하면 공개 리콜 정보를 확인할 수 있어요.',
      ),
      _LookupState.loading => const TevioLoadingState(
        label: '공식 리콜 정보를 확인하고 있어요',
      ),
      _LookupState.error => TevioErrorState(
        title: '조회하지 못했어요',
        description: '네트워크가 불안정해 공개 리콜 정보를 가져오지 못했습니다.',
        onRetryPressed: _lookup,
      ),
      _LookupState.empty => TevioEmptyState(
        title: '일치하는 공개 리콜 정보가 없어요',
        description: '검색어를 바꾸거나 제품 모델번호를 확인해 다시 조회해 보세요.',
        actionLabel: '다시 검색하기',
        onActionPressed: () => _focusNode.requestFocus(),
      ),
      _LookupState.result => TevioDecisionPanel(
        status: RightsStatus.urgent,
        contextLabel: '공개 리콜 검색 결과',
        title: '“$_searchedTerm”와 유사한 공지가 있어요',
        reason: '검색 결과는 참고용입니다. 사용 전에 제조사와 모델번호가 공식 공지와 일치하는지 확인해 주세요.',
        actionLabel: '모델번호 다시 확인',
        onPressed: () => _focusNode.requestFocus(),
      ),
    };
  }

  Future<void> _lookup() async {
    final term = _controller.text.trim();
    if (term.length < 2) return;
    setState(() {
      _searchedTerm = term;
      _state = _LookupState.loading;
    });
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final normalized = term.toLowerCase();
    setState(() {
      _state = term.contains('오류')
          ? _LookupState.error
          : (normalized.contains('xyz') ||
                normalized.contains('vc-2401') ||
                term.contains('무선청소기'))
          ? _LookupState.result
          : _LookupState.empty;
    });
  }
}

enum _LookupState { idle, loading, result, empty, error }
