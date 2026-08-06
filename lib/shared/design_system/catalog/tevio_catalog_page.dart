import 'package:flutter/material.dart';

import '../components/tevio_app_bar.dart';
import '../components/tevio_button.dart';
import '../components/tevio_card.dart';
import '../components/tevio_controls.dart';
import '../components/tevio_feedback_banner.dart';
import '../components/tevio_integrations.dart';
import '../components/tevio_operational_patterns.dart';
import '../components/tevio_patterns.dart';
import '../components/tevio_product_patterns.dart';
import '../components/tevio_segmented_control.dart';
import '../components/tevio_selection_tile.dart';
import '../components/tevio_sheet.dart';
import '../components/tevio_status_badge.dart';
import '../components/tevio_switch.dart';
import '../components/tevio_tabs.dart';
import '../components/tevio_text_field.dart';
import '../models/rights_status.dart';
import '../tokens/tevio_spacing.dart';

class TevioCatalogPage extends StatelessWidget {
  const TevioCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TevioAppBar(title: 'Tevio UI Kit'),
      body: ListView(
        padding: const EdgeInsets.all(TevioSpacing.lg),
        children: [
          const TevioFormSection(
            title: 'Buttons',
            description: 'Primary, secondary, destructive and loading states',
            child: _ButtonPreview(),
          ),
          const SizedBox(height: TevioSpacing.xl),
          const TevioFormSection(
            title: 'Input and selection',
            description: '입력, 단일 선택, 토글은 상태와 다음 결과를 명확히 보여줍니다.',
            child: _InteractionPreview(),
          ),
          const SizedBox(height: TevioSpacing.xl),
          const TevioFormSection(
            title: 'Status',
            description: '상태는 텍스트·점·색상으로 함께 전달합니다.',
            child: Wrap(
              spacing: TevioSpacing.xs,
              runSpacing: TevioSpacing.xs,
              children: [
                TevioStatusBadge(status: RightsStatus.safe),
                TevioStatusBadge(status: RightsStatus.actionRequired),
                TevioStatusBadge(status: RightsStatus.urgent),
                TevioStatusBadge(status: RightsStatus.processing),
              ],
            ),
          ),
          const SizedBox(height: TevioSpacing.xl),
          TevioFeedbackBanner(
            status: RightsStatus.actionRequired,
            title: '확인이 필요해요',
            description: '제품 정보를 확인하면 다음 행동을 안내할 수 있어요.',
            actionLabel: '확인하기',
          ),
          const SizedBox(height: TevioSpacing.xl),
          const TevioProductSummaryCard(
            name: '무선청소기',
            identity: 'XYZ · VC-2401',
            status: RightsStatus.urgent,
            summary: '리콜 대상 여부를 먼저 확인해 주세요.',
            primaryLabel: '리콜 내용 확인',
          ),
          const SizedBox(height: TevioSpacing.xl),
          const TevioFormSection(
            title: 'Operational UX',
            description: '상태, 맥락, 다음 행동을 하나의 정보 단위로 다룹니다.',
            child: _OperationalPreview(),
          ),
          const SizedBox(height: TevioSpacing.xl),
          const TevioFormSection(
            title: 'Integrations',
            description: '외부 라이브러리는 테비오 UI 어댑터를 통해 사용합니다.',
            child: _IntegrationPreview(),
          ),
        ],
      ),
    );
  }
}

class _InteractionPreview extends StatefulWidget {
  const _InteractionPreview();

  @override
  State<_InteractionPreview> createState() => _InteractionPreviewState();
}

class _InteractionPreviewState extends State<_InteractionPreview> {
  final _controller = TextEditingController(text: 'VC-2401');
  final _searchController = TextEditingController(text: '무선청소기');
  var _selectedMethod = true;
  var _enabled = true;
  var _selectedSegment = '전체';
  var _selectedTab = '전체';
  var _selectedCategory = '생활가전';
  var _agreed = false;
  var _selectedSort = '중요한 순';

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TevioSearchField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TevioSpacing.md),
        TevioTextField(
          controller: _controller,
          label: '모델번호',
          hintText: '예: VC-2401',
          helperText: '제품 라벨에 적힌 번호를 입력하세요.',
        ),
        const SizedBox(height: TevioSpacing.md),
        TevioSelectField<String>(
          label: '제품 카테고리',
          value: _selectedCategory,
          items: const ['생활가전', '디지털', '주방'],
          labelBuilder: (item) => item,
          onChanged: (value) {
            if (value != null) setState(() => _selectedCategory = value);
          },
        ),
        const SizedBox(height: TevioSpacing.md),
        TevioSelectionTile(
          icon: Icons.document_scanner_outlined,
          title: '영수증으로 등록',
          description: '사진에서 구매 정보를 읽어옵니다.',
          selected: _selectedMethod,
          onTap: () => setState(() => _selectedMethod = !_selectedMethod),
        ),
        const SizedBox(height: TevioSpacing.md),
        TevioCheckControl(
          value: _agreed,
          label: '알림 수신에 동의해요',
          description: '서비스에 필요한 권리 상태 변경만 알려드려요.',
          onChanged: (value) => setState(() => _agreed = value),
        ),
        TevioRadioControl<String>(
          value: '중요한 순',
          groupValue: _selectedSort,
          label: '중요한 순',
          description: '안전과 기한이 임박한 항목을 먼저 봐요.',
          onChanged: (value) => setState(() => _selectedSort = value),
        ),
        TevioRadioControl<String>(
          value: '최근 구매 순',
          groupValue: _selectedSort,
          label: '최근 구매 순',
          onChanged: (value) => setState(() => _selectedSort = value),
        ),
        const SizedBox(height: TevioSpacing.md),
        TevioSwitch(
          value: _enabled,
          label: '리콜 알림',
          description: '안전 문제와 공식 조치가 감지되면 알려드려요.',
          onChanged: (value) => setState(() => _enabled = value),
        ),
        const SizedBox(height: TevioSpacing.md),
        TevioSegmentedControl<String>(
          items: const ['전체', '확인 필요'],
          selected: _selectedSegment,
          labelBuilder: (item) => item,
          onChanged: (value) => setState(() => _selectedSegment = value),
        ),
        const SizedBox(height: TevioSpacing.sm),
        TevioTabs<String>(
          items: const ['전체', '제품', '처리 기록'],
          selected: _selectedTab,
          labelBuilder: (item) => item,
          onChanged: (value) => setState(() => _selectedTab = value),
        ),
        const SizedBox(height: TevioSpacing.lg),
        const TevioProgress(value: .6, label: '영수증 정보 확인', showValue: true),
        const SizedBox(height: TevioSpacing.md),
        const TevioSkeleton(height: 44, animate: false),
        const SizedBox(height: TevioSpacing.md),
        TevioListItem(
          leading: const Icon(Icons.info_outline),
          title: '목록 항목',
          subtitle: '이동 가능한 행에는 화살표를 표시합니다.',
          onTap: () {},
        ),
      ],
    );
  }
}

class _OperationalPreview extends StatelessWidget {
  const _OperationalPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TevioActionCard(
          status: RightsStatus.actionRequired,
          eyebrow: 'XYZ 무선청소기',
          title: '모델번호를 확인해 주세요',
          description: '리콜 대상 여부를 정확하게 확인할 수 있어요.',
          supportingText: '확인 권장',
          actionLabel: '제품 정보 보기',
          onPressed: () {},
        ),
        const SizedBox(height: TevioSpacing.sm),
        TevioCard(
          child: Column(
            children: [
              TevioListRow(
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                description: '리콜과 보증 만료를 알려드려요.',
                onTap: () {},
              ),
              const Divider(height: TevioSpacing.xl),
              const TevioListRow(
                icon: Icons.info_outline,
                title: '앱 정보',
                value: '1.0.0',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntegrationPreview extends StatefulWidget {
  const _IntegrationPreview();

  @override
  State<_IntegrationPreview> createState() => _IntegrationPreviewState();
}

class _IntegrationPreviewState extends State<_IntegrationPreview> {
  DateTime? _selectedDate = DateTime(2026, 8, 6);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TevioDateField(
          label: '구매일',
          value: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onChanged: (value) => setState(() => _selectedDate = value),
        ),
        const SizedBox(height: TevioSpacing.sm),
        TevioDocumentPreview(
          title: '영수증',
          description: 'PDF · 1.2 MB',
          onOpen: () {},
        ),
        const SizedBox(height: TevioSpacing.sm),
        const TevioNetworkImage(
          imageUrl: null,
          semanticLabel: '제품 이미지 자리표시자',
          width: 72,
          height: 72,
        ),
        const SizedBox(height: TevioSpacing.sm),
        TevioPermissionRequest(
          icon: Icons.camera_alt_outlined,
          title: '카메라 접근',
          description: '영수증을 촬영할 때만 카메라를 사용합니다.',
          actionLabel: '권한 요청',
          onRequest: () {},
        ),
        const SizedBox(height: TevioSpacing.sm),
        TevioButton(
          label: '확인 시트 열기',
          variant: TevioButtonVariant.secondary,
          onPressed: () => TevioSheet.show<void>(
            context,
            builder: (context) => const TevioConfirmSheet(
              title: '변경 사항을 저장할까요?',
              description: '저장 후 제품의 권리 상태를 다시 확인합니다.',
              confirmLabel: '저장하기',
            ),
          ),
        ),
      ],
    );
  }
}

class _ButtonPreview extends StatelessWidget {
  const _ButtonPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        TevioButton(label: 'Primary', onPressed: _noop),
        SizedBox(height: TevioSpacing.sm),
        TevioButton(
          label: 'Secondary',
          onPressed: _noop,
          variant: TevioButtonVariant.secondary,
        ),
        SizedBox(height: TevioSpacing.sm),
        TevioLoadingButton(label: '저장하기', isLoading: true, onPressed: _noop),
      ],
    );
  }

  static void _noop() {}
}
