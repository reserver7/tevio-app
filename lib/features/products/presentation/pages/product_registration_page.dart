import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/product_registration_session.dart';
import '../../../../shared/design_system/tevio_design_system.dart';

enum _RegistrationStep {
  method,
  productInfo,
  candidate,
  notifications,
  complete,
}

enum _RegistrationMethod { camera, gallery, modelNumber, manual }

enum _RegistrationFailure {
  permissionDenied,
  imageCanceled,
  ocrFailed,
  modelNotFound,
  noCandidates,
  duplicatePossible,
  offline,
}

class ProductRegistrationPage extends ConsumerStatefulWidget {
  const ProductRegistrationPage({super.key});

  @override
  ConsumerState<ProductRegistrationPage> createState() =>
      _ProductRegistrationPageState();
}

class _ProductRegistrationPageState
    extends ConsumerState<ProductRegistrationPage> {
  _RegistrationStep _step = _RegistrationStep.method;
  _RegistrationMethod? _method;
  bool _recallAlert = true;
  bool _warrantyAlert = true;
  bool _returnAlert = true;
  _RegistrationFailure? _failure;
  bool _hasShownMockFailure = false;
  int? _activeSession;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(productRegistrationSessionProvider);
    if (_activeSession != session) {
      _activeSession = session;
      _resetLocalState();
    }

    final currentStep = _RegistrationStep.values.indexOf(_step);

    return Scaffold(
      key: ValueKey('product-registration-$session'),
      appBar: const TevioAppBar(title: '제품 등록'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            Text('테비오에 내 제품을 등록하세요', style: TevioTypography.titleLarge),
            const SizedBox(height: TevioSpacing.xs),
            Text(
              '영수증과 제품 정보를 모아두면 리콜, 보증, A/S 시점을 계속 확인할 수 있어요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TevioSpacing.lg),
            TevioStepIndicator(
              currentStep: currentStep,
              totalSteps: _RegistrationStep.values.length,
            ),
            const SizedBox(height: TevioSpacing.xl),
            _buildStepContent(),
          ],
        ),
      ),
      bottomNavigationBar: _failure == null
          ? SafeArea(
              minimum: const EdgeInsets.all(TevioSpacing.lg),
              child: Row(
                children: [
                  if (_step != _RegistrationStep.method &&
                      _step != _RegistrationStep.complete) ...[
                    Expanded(
                      child: TevioButton(
                        label: '이전',
                        icon: Icons.arrow_back_outlined,
                        variant: TevioButtonVariant.secondary,
                        onPressed: _goBack,
                      ),
                    ),
                    const SizedBox(width: TevioSpacing.sm),
                  ],
                  Expanded(
                    child: TevioButton(
                      label: _primaryActionLabel,
                      icon: _step == _RegistrationStep.complete
                          ? Icons.check
                          : Icons.arrow_forward_outlined,
                      onPressed: _canContinue ? _goNext : null,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildStepContent() {
    return switch (_step) {
      _RegistrationStep.method => _MethodStep(
        selectedMethod: _method,
        onSelected: (method) {
          setState(() {
            _method = method;
          });
        },
      ),
      _RegistrationStep.productInfo => _ProductInfoStep(
        failure: _failure,
        onRetryPressed: () {
          setState(() {
            _failure = null;
            _step = _RegistrationStep.candidate;
          });
        },
      ),
      _RegistrationStep.candidate => const _CandidateStep(),
      _RegistrationStep.notifications => _NotificationOptionsStep(
        recallAlert: _recallAlert,
        warrantyAlert: _warrantyAlert,
        returnAlert: _returnAlert,
        onRecallChanged: (value) => setState(() => _recallAlert = value),
        onWarrantyChanged: (value) => setState(() => _warrantyAlert = value),
        onReturnChanged: (value) => setState(() => _returnAlert = value),
      ),
      _RegistrationStep.complete => const TevioCompletionView(
        title: '제품 등록이 완료됐어요.',
        description: '이제 테비오가 이 제품의 권리를 계속 확인할게요.',
      ),
    };
  }

  bool get _canContinue {
    return switch (_step) {
      _RegistrationStep.method => _method != null,
      _RegistrationStep.productInfo => true,
      _RegistrationStep.candidate => true,
      _RegistrationStep.notifications => true,
      _RegistrationStep.complete => true,
    };
  }

  String get _primaryActionLabel {
    return switch (_step) {
      _RegistrationStep.method => '제품 정보 입력',
      _RegistrationStep.productInfo => '후보 확인',
      _RegistrationStep.candidate => '알림 선택',
      _RegistrationStep.notifications => '등록 완료',
      _RegistrationStep.complete => '확인',
    };
  }

  void _goBack() {
    setState(() {
      _failure = null;
      _step =
          _RegistrationStep.values[_RegistrationStep.values.indexOf(_step) - 1];
    });
  }

  void _goNext() {
    if (_step == _RegistrationStep.complete) {
      ref.read(productRegistrationSessionProvider.notifier).reset();
      return;
    }

    if (_step == _RegistrationStep.productInfo) {
      if (_hasShownMockFailure) {
        setState(() {
          _step = _RegistrationStep.candidate;
        });
        return;
      }

      setState(() {
        _failure = _RegistrationFailure.ocrFailed;
        _hasShownMockFailure = true;
      });
      return;
    }

    setState(() {
      _step =
          _RegistrationStep.values[_RegistrationStep.values.indexOf(_step) + 1];
    });
  }

  void _resetLocalState() {
    _step = _RegistrationStep.method;
    _method = null;
    _recallAlert = true;
    _warrantyAlert = true;
    _returnAlert = true;
    _failure = null;
    _hasShownMockFailure = false;
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({required this.selectedMethod, required this.onSelected});

  final _RegistrationMethod? selectedMethod;
  final ValueChanged<_RegistrationMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TevioSectionHeader(title: '등록 방식'),
        const SizedBox(height: TevioSpacing.sm),
        _MethodTile(
          method: _RegistrationMethod.camera,
          selectedMethod: selectedMethod,
          icon: Icons.camera_alt_outlined,
          title: '영수증 촬영',
          description: '구매 정보를 빠르게 읽어올 준비를 합니다.',
          onSelected: onSelected,
        ),
        const SizedBox(height: TevioSpacing.sm),
        _MethodTile(
          method: _RegistrationMethod.gallery,
          selectedMethod: selectedMethod,
          icon: Icons.image_outlined,
          title: '앨범에서 선택',
          description: '저장된 영수증 또는 주문 화면을 사용합니다.',
          onSelected: onSelected,
        ),
        const SizedBox(height: TevioSpacing.sm),
        _MethodTile(
          method: _RegistrationMethod.modelNumber,
          selectedMethod: selectedMethod,
          icon: Icons.keyboard_alt_outlined,
          title: '모델번호 직접 입력',
          description: '제품 라벨의 모델번호로 권리 정보를 확인합니다.',
          onSelected: onSelected,
        ),
        const SizedBox(height: TevioSpacing.sm),
        _MethodTile(
          method: _RegistrationMethod.manual,
          selectedMethod: selectedMethod,
          icon: Icons.edit_note_outlined,
          title: '제품 직접 등록',
          description: '제품명, 구매일, 구매처를 직접 입력합니다.',
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selectedMethod,
    required this.icon,
    required this.title,
    required this.description,
    required this.onSelected,
  });

  final _RegistrationMethod method;
  final _RegistrationMethod? selectedMethod;
  final IconData icon;
  final String title;
  final String description;
  final ValueChanged<_RegistrationMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return TevioSelectionTile(
      icon: icon,
      title: title,
      description: description,
      selected: selectedMethod == method,
      onTap: () => onSelected(method),
    );
  }
}

class _ProductInfoStep extends StatelessWidget {
  const _ProductInfoStep({required this.failure, required this.onRetryPressed});

  final _RegistrationFailure? failure;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    if (failure != null) {
      final copy = _RegistrationFailureCopy.from(failure!);

      return TevioErrorState(
        title: copy.title,
        description: copy.description,
        actionLabel: copy.action,
        onRetryPressed: onRetryPressed,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TevioSectionHeader(title: '제품 정보'),
        const SizedBox(height: TevioSpacing.sm),
        const _FieldLabel('제품명'),
        const TextField(decoration: InputDecoration(hintText: '예: 공기청정기')),
        const SizedBox(height: TevioSpacing.md),
        const _FieldLabel('제조사'),
        const TextField(decoration: InputDecoration(hintText: '예: ABC')),
        const SizedBox(height: TevioSpacing.md),
        const _FieldLabel('모델번호'),
        const TextField(decoration: InputDecoration(hintText: '예: ABC-123')),
        const SizedBox(height: TevioSpacing.md),
        const _FieldLabel('구매일'),
        const TextField(decoration: InputDecoration(hintText: '예: 2026.07.23')),
        const SizedBox(height: TevioSpacing.md),
        const _FieldLabel('구매처'),
        const TextField(decoration: InputDecoration(hintText: '예: 브랜드 공식몰')),
      ],
    );
  }
}

class _RegistrationFailureCopy {
  const _RegistrationFailureCopy({
    required this.title,
    required this.description,
    required this.action,
  });

  final String title;
  final String description;
  final String action;

  factory _RegistrationFailureCopy.from(_RegistrationFailure failure) {
    return switch (failure) {
      _RegistrationFailure.permissionDenied => const _RegistrationFailureCopy(
        title: '카메라 권한이 필요해요',
        description: '영수증을 촬영하려면 카메라 접근 권한을 허용해야 합니다.',
        action: '권한 설정 확인',
      ),
      _RegistrationFailure.imageCanceled => const _RegistrationFailureCopy(
        title: '이미지 선택이 취소됐어요',
        description: '앨범에서 영수증이나 주문 화면을 다시 선택할 수 있어요.',
        action: '이미지 다시 선택',
      ),
      _RegistrationFailure.ocrFailed => const _RegistrationFailureCopy(
        title: '영수증을 읽지 못했어요',
        description: '사진이 흐리거나 일부 정보가 가려져 있으면 직접 입력이 필요합니다.',
        action: '직접 입력으로 계속',
      ),
      _RegistrationFailure.modelNotFound => const _RegistrationFailureCopy(
        title: '모델번호를 확인하지 못했어요',
        description: '제품 라벨의 모델번호를 다시 확인하거나 제품명을 입력해 주세요.',
        action: '모델번호 다시 입력',
      ),
      _RegistrationFailure.noCandidates => const _RegistrationFailureCopy(
        title: '제품 후보가 없어요',
        description: '입력한 정보와 일치하는 제품 후보를 찾지 못했습니다.',
        action: '제품 직접 등록',
      ),
      _RegistrationFailure.duplicatePossible => const _RegistrationFailureCopy(
        title: '이미 등록한 제품일 수 있어요',
        description: '같은 모델번호와 구매일의 제품이 이미 등록되어 있습니다.',
        action: '기존 제품 확인',
      ),
      _RegistrationFailure.offline => const _RegistrationFailureCopy(
        title: '연결 상태를 확인해 주세요',
        description: '네트워크가 연결되면 리콜과 보증 정보를 다시 확인할 수 있어요.',
        action: '다시 시도',
      ),
    };
  }
}

class _CandidateStep extends StatelessWidget {
  const _CandidateStep();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TevioSectionHeader(title: '제품 후보 확인'),
        SizedBox(height: TevioSpacing.sm),
        TevioProductCard(
          name: '공기청정기',
          brand: 'ABC',
          modelNumber: 'ABC-123',
          purchasedAt: '2026.07.23',
          warrantyText: '365일 예상',
          status: RightsStatus.detected,
          summary: '입력한 모델번호와 가장 유사한 제품 후보예요.',
          actionLabel: '이 제품으로 등록',
        ),
        SizedBox(height: TevioSpacing.sm),
        TevioCard(
          child: Text(
            'OCR 결과가 확실하지 않으면 자동 확정하지 않고 후보를 확인합니다.',
            style: TevioTypography.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _NotificationOptionsStep extends StatelessWidget {
  const _NotificationOptionsStep({
    required this.recallAlert,
    required this.warrantyAlert,
    required this.returnAlert,
    required this.onRecallChanged,
    required this.onWarrantyChanged,
    required this.onReturnChanged,
  });

  final bool recallAlert;
  final bool warrantyAlert;
  final bool returnAlert;
  final ValueChanged<bool> onRecallChanged;
  final ValueChanged<bool> onWarrantyChanged;
  final ValueChanged<bool> onReturnChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TevioSectionHeader(title: '알림 항목'),
        const SizedBox(height: TevioSpacing.sm),
        TevioCard(
          child: Column(
            children: [
              SwitchListTile(
                value: recallAlert,
                onChanged: onRecallChanged,
                title: const Text('리콜과 무상수리'),
                subtitle: const Text('안전 문제와 공식 조치가 감지되면 알려드려요.'),
              ),
              const Divider(height: TevioSpacing.xl),
              SwitchListTile(
                value: warrantyAlert,
                onChanged: onWarrantyChanged,
                title: const Text('보증 만료'),
                subtitle: const Text('무상보증 종료 전 필요한 시점에 알려드려요.'),
              ),
              const Divider(height: TevioSpacing.xl),
              SwitchListTile(
                value: returnAlert,
                onChanged: onReturnChanged,
                title: const Text('반품과 교환 가능 기간'),
                subtitle: const Text('구매 이후 놓치기 쉬운 기한을 확인해요.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TevioSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
