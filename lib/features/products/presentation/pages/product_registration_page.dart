import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../data/product_registration_analysis_repository.dart';
import '../../data/registration_media_picker.dart';
import '../state/product_registration_dependencies.dart';
import '../state/product_registration_permission_flow.dart';
import '../state/product_registration_result.dart';
import '../state/product_registration_session.dart';

enum _RegistrationStep {
  method,
  analyzing,
  productInfo,
  candidate,
  notifications,
  registering,
  complete,
}

enum _RegistrationMethod { camera, gallery, modelNumber, manual }

enum _RegistrationFailure {
  mediaPickFailed,
  cameraUnavailable,
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
    extends ConsumerState<ProductRegistrationPage>
    with WidgetsBindingObserver {
  _RegistrationStep _step = _RegistrationStep.method;
  _RegistrationMethod? _method;
  bool _recallAlert = true;
  bool _warrantyAlert = true;
  bool _returnAlert = true;
  _RegistrationFailure? _failure;
  String? _registrationFailureMessage;
  bool _showDraftPrompt = false;
  bool _showFieldErrors = false;
  bool _isPrimaryActionBusy = false;
  RegistrationPermissionFlow _permissionFlow =
      const RegistrationPermissionFlow();
  String? _mediaPath;
  String? _registeredProductId;
  String? _registeredProductName;
  int? _activeSession;
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelNumberController;
  late final TextEditingController _purchasedAtController;
  late final TextEditingController _purchaseStoreController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _modelNumberFocusNode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeSession = ref.read(productRegistrationSessionProvider);
    final draft = ref.read(productRegistrationDraftProvider);
    _showDraftPrompt = draft != null;
    _step = draft == null
        ? _RegistrationStep.method
        : _RegistrationStep.values[draft.step];
    _method = draft?.method == null
        ? null
        : _RegistrationMethod.values[draft!.method!];
    _recallAlert = draft?.recallAlert ?? true;
    _warrantyAlert = draft?.warrantyAlert ?? true;
    _returnAlert = draft?.returnAlert ?? true;
    _mediaPath = draft?.mediaPath;
    _nameController = TextEditingController(text: draft?.name ?? '');
    _brandController = TextEditingController(text: draft?.brand ?? '');
    _modelNumberController = TextEditingController(
      text: draft?.modelNumber ?? '',
    );
    _purchasedAtController = TextEditingController(
      text: draft?.purchasedAt ?? '',
    );
    _purchaseStoreController = TextEditingController(
      text: draft?.purchaseStore ?? '',
    );
    _nameFocusNode = FocusNode();
    _modelNumberFocusNode = FocusNode();
    _recoverLostMedia();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_step != _RegistrationStep.complete &&
        _step != _RegistrationStep.registering) {
      ref
          .read(productRegistrationDraftProvider.notifier)
          .save(
            ProductRegistrationDraft(
              step: _step.index,
              method: _method?.index,
              name: _nameController.text,
              brand: _brandController.text,
              modelNumber: _modelNumberController.text,
              purchasedAt: _purchasedAtController.text,
              purchaseStore: _purchaseStoreController.text,
              mediaPath: _mediaPath,
              recallAlert: _recallAlert,
              warrantyAlert: _warrantyAlert,
              returnAlert: _returnAlert,
            ),
          );
    }
    _nameController.dispose();
    _brandController.dispose();
    _modelNumberController.dispose();
    _purchasedAtController.dispose();
    _purchaseStoreController.dispose();
    _nameFocusNode.dispose();
    _modelNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final source = _permissionFlow.source;
    if (source == null) return;
    if ((state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden) &&
        _permissionFlow.status ==
            RegistrationPermissionFlowStatus.openingSettings) {
      setState(() {
        _permissionFlow = _permissionFlow.transition(
          RegistrationPermissionFlowStatus.waitingForSettingsReturn,
        );
      });
      return;
    }
    if (state == AppLifecycleState.resumed &&
        _permissionFlow.isWaitingFor(source)) {
      _resumePendingPermissionAction(source);
    }
  }

  Future<void> _resumePendingPermissionAction(
    RegistrationMediaSource source,
  ) async {
    if (!_sourceMatchesMethod(source)) {
      setState(() => _permissionFlow = _permissionFlow.reset());
      return;
    }
    final access = await ref
        .read(registrationMediaPickerProvider)
        .checkPermission(source);
    if (!mounted || !_permissionFlow.isWaitingFor(source)) return;
    if (access == RegistrationPermissionAccess.granted) {
      setState(() => _permissionFlow = _permissionFlow.reset());
      await _openMediaPicker(source);
      return;
    }
    setState(() => _permissionFlow = _permissionFlow.reset());
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(productRegistrationSessionProvider);
    if (_activeSession != session) {
      _activeSession = session;
      _resetLocalState();
    }

    return Scaffold(
      key: ValueKey('product-registration-$session'),
      appBar: const TevioAppBar(title: '제품 등록'),
      body: TevioPageScrollView(
        padding: const EdgeInsets.fromLTRB(
          TevioSpacing.lg,
          TevioSpacing.sm,
          TevioSpacing.lg,
          TevioSpacing.xxl,
        ),
        children: [
          if (_progressStep != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(_stepTitle, style: TevioTypography.titleLarge),
                ),
                Text(
                  '${_progressStep! + 1}/4',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: TevioColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TevioSpacing.md),
            TevioStepIndicator(currentStep: _progressStep!, totalSteps: 4),
            const SizedBox(height: TevioSpacing.xl),
          ],
          if (_showDraftPrompt)
            _DraftResumeCard(
              onResume: () => setState(() => _showDraftPrompt = false),
              onStartOver: _startOver,
            )
          else
            _buildStepContent(),
        ],
      ),
      bottomNavigationBar:
          _failure == null &&
              _step != _RegistrationStep.registering &&
              !_showDraftPrompt
          ? TevioTaskActionBar(
              primaryLabel: _primaryActionLabel,
              primaryIcon: _primaryActionIcon,
              onPrimaryPressed: _canContinue && !_isActionBusy ? _goNext : null,
              secondaryLabel:
                  _step != _RegistrationStep.method &&
                      _step != _RegistrationStep.complete
                  ? '이전'
                  : null,
              onSecondaryPressed: _isActionBusy ? null : _goBack,
            )
          : null,
    );
  }

  int? get _progressStep {
    return switch (_step) {
      _RegistrationStep.method || _RegistrationStep.complete => null,
      _RegistrationStep.analyzing || _RegistrationStep.productInfo => 0,
      _RegistrationStep.candidate => 1,
      _RegistrationStep.notifications => 2,
      _RegistrationStep.registering => 3,
    };
  }

  String get _stepTitle {
    return switch (_step) {
      _RegistrationStep.method => '등록 방식',
      _RegistrationStep.analyzing => '구매 정보 가져오기',
      _RegistrationStep.productInfo => '제품 정보 확인',
      _RegistrationStep.candidate => '제품 후보 확인',
      _RegistrationStep.notifications => '알림 선택',
      _RegistrationStep.registering => '제품 등록',
      _RegistrationStep.complete => '등록 완료',
    };
  }

  Widget _buildStepContent() {
    return switch (_step) {
      _RegistrationStep.method => _MethodStep(
        selectedMethod: _method,
        failure: _failure,
        failureMessage: _registrationFailureMessage,
        onFailureAction: _handleMediaFailureAction,
        onSelected: (method) {
          if (_method == method) return;
          setState(() {
            _method = method;
            _mediaPath = null;
            _permissionFlow = _permissionFlow.reset();
            _failure = null;
            _registrationFailureMessage = null;
          });
        },
      ),
      _RegistrationStep.analyzing => _AnalysisStep(
        method: _method,
        mediaPath: _mediaPath,
        failure: _failure,
        onRetryPressed: _retryAnalysis,
        onReplaceMediaPressed: _pickSelectedMedia,
        onManualEntryPressed: _continueWithManualEntry,
      ),
      _RegistrationStep.productInfo => _ProductInfoStep(
        method: _method,
        failure: _failure,
        failureMessage: _registrationFailureMessage,
        onFailureAction: _handleProductInfoFailureAction,
        nameController: _nameController,
        brandController: _brandController,
        modelNumberController: _modelNumberController,
        purchasedAtController: _purchasedAtController,
        purchaseStoreController: _purchaseStoreController,
        nameFocusNode: _nameFocusNode,
        modelNumberFocusNode: _modelNumberFocusNode,
        showErrors: _showFieldErrors,
        onChanged: _handleProductInfoChanged,
        purchaseDate: _parseDate(_purchasedAtController.text),
        onPurchaseDateChanged: _setPurchaseDate,
      ),
      _RegistrationStep.candidate => _CandidateStep(input: _registrationInput),
      _RegistrationStep.notifications => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_failure != null) ...[
            TevioFeedbackBanner(
              status: RightsStatus.urgent,
              title: '제품을 등록하지 못했어요',
              description:
                  _registrationFailureMessage ??
                  _RegistrationFailureCopy.from(_failure!).description,
              actionLabel: '다시 등록하기',
              onActionPressed: () => setState(() => _failure = null),
            ),
            const SizedBox(height: TevioSpacing.lg),
          ],
          _NotificationOptionsStep(
            recallAlert: _recallAlert,
            warrantyAlert: _warrantyAlert,
            returnAlert: _returnAlert,
            onRecallChanged: (value) => setState(() => _recallAlert = value),
            onWarrantyChanged: (value) =>
                setState(() => _warrantyAlert = value),
            onReturnChanged: (value) => setState(() => _returnAlert = value),
          ),
        ],
      ),
      _RegistrationStep.registering => _RegisteringStep(
        input: _registrationInput.normalized(),
      ),
      _RegistrationStep.complete => TevioCompletionView(
        title: '${_registeredProductName ?? '제품'} 등록이 완료됐어요.',
        description: '테비오가 리콜, 보증, 반품·교환 정보를 확인하고 있어요.',
        status: RightsStatus.detected,
        statusLabel: '확인 중',
        statusDescription: '확인이 끝나면 필요한 내용만 알려드릴게요.',
      ),
    };
  }

  bool get _canContinue {
    return switch (_step) {
      _RegistrationStep.method => _method != null,
      _RegistrationStep.analyzing => _mediaPath != null,
      _RegistrationStep.productInfo => true,
      _RegistrationStep.candidate => true,
      _RegistrationStep.notifications => true,
      _RegistrationStep.registering => false,
      _RegistrationStep.complete => true,
    };
  }

  String get _primaryActionLabel {
    if (_isActionBusy) {
      if (_permissionFlow.status ==
          RegistrationPermissionFlowStatus.checkingPermission) {
        return '권한 확인 중';
      }
      if (_permissionFlow.status ==
          RegistrationPermissionFlowStatus.requestingPermission) {
        return '권한 확인 중';
      }
      if (_permissionFlow.status ==
          RegistrationPermissionFlowStatus.openingSettings) {
        return '설정 여는 중';
      }
      return switch (_step) {
        _RegistrationStep.method =>
          _method == _RegistrationMethod.camera ? '카메라 여는 중' : '앨범 여는 중',
        _RegistrationStep.analyzing => '정보 읽는 중',
        _RegistrationStep.productInfo => '제품 찾는 중',
        _ => '처리 중',
      };
    }
    return switch (_step) {
      _RegistrationStep.method => switch (_method) {
        _RegistrationMethod.camera => '영수증 촬영',
        _RegistrationMethod.gallery => '앨범에서 선택',
        _RegistrationMethod.modelNumber => '모델번호 입력',
        _RegistrationMethod.manual => '직접 입력',
        null => '등록 방식 선택',
      },
      _RegistrationStep.analyzing => '정보 읽어오기',
      _RegistrationStep.productInfo => '제품 후보 확인',
      _RegistrationStep.candidate => '이 제품으로 계속',
      _RegistrationStep.notifications => '제품 등록',
      _RegistrationStep.registering => '등록 중',
      _RegistrationStep.complete => '제품 상태 확인',
    };
  }

  IconData? get _primaryActionIcon {
    if (_isActionBusy) {
      if (_permissionFlow.status ==
          RegistrationPermissionFlowStatus.openingSettings) {
        return Icons.settings_outlined;
      }
      return Icons.hourglass_top_outlined;
    }
    return switch (_step) {
      _RegistrationStep.method => switch (_method) {
        _RegistrationMethod.camera => Icons.camera_alt_outlined,
        _RegistrationMethod.gallery => Icons.photo_library_outlined,
        _RegistrationMethod.modelNumber => Icons.keyboard_alt_outlined,
        _RegistrationMethod.manual => Icons.edit_note_outlined,
        null => null,
      },
      _RegistrationStep.analyzing => Icons.document_scanner_outlined,
      _RegistrationStep.productInfo => Icons.manage_search_outlined,
      _RegistrationStep.candidate => Icons.check_circle_outline,
      _RegistrationStep.notifications => Icons.inventory_2_outlined,
      _RegistrationStep.registering => Icons.sync_outlined,
      _RegistrationStep.complete => Icons.verified_outlined,
    };
  }

  bool get _isActionBusy => _isPrimaryActionBusy || _permissionFlow.isBusy;

  void _goBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _failure = null;
      _step =
          _RegistrationStep.values[_RegistrationStep.values.indexOf(_step) - 1];
    });
  }

  void _setPurchaseDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      return;
    }
    _purchasedAtController.text =
        '${selectedDate.year.toString().padLeft(4, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.day.toString().padLeft(2, '0')}';
    _handleProductInfoChanged();
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('.');
    if (parts.length != 3) {
      return null;
    }

    return DateTime.tryParse(
      '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}',
    );
  }

  void _startOver() {
    ref.read(productRegistrationDraftProvider.notifier).clear();
    setState(() {
      _showDraftPrompt = false;
      _resetLocalState();
    });
  }

  Future<void> _goNext() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_step == _RegistrationStep.complete) {
      ref.read(productRegistrationDraftProvider.notifier).clear();
      ref.read(productRegistrationSessionProvider.notifier).reset();
      if (_registeredProductId != null) {
        context.go('/products/$_registeredProductId');
      }
      return;
    }

    if (_step == _RegistrationStep.method) {
      switch (_method) {
        case _RegistrationMethod.camera:
        case _RegistrationMethod.gallery:
          await _pickSelectedMedia();
          return;
        case _RegistrationMethod.modelNumber:
          _moveToProductInfo(_modelNumberFocusNode);
          return;
        case _RegistrationMethod.manual:
          _moveToProductInfo(_nameFocusNode);
          return;
        case null:
          return;
      }
    }

    if (_step == _RegistrationStep.analyzing) {
      await _analyzeMedia();
      return;
    }

    if (_step == _RegistrationStep.productInfo) {
      if (_method == _RegistrationMethod.modelNumber) {
        await _findModelCandidate();
        return;
      }
      if (!_registrationInput.isValid) {
        setState(() {
          _showFieldErrors = true;
        });
        return;
      }
    }

    if (_step == _RegistrationStep.notifications) {
      await _submitRegistration();
      return;
    }

    setState(() {
      _showFieldErrors = false;
      _step =
          _RegistrationStep.values[_RegistrationStep.values.indexOf(_step) + 1];
    });
  }

  Future<void> _submitRegistration() async {
    if (!_registrationInput.isValid) {
      setState(() {
        _step = _RegistrationStep.productInfo;
        _showFieldErrors = true;
      });
      return;
    }

    setState(() {
      _step = _RegistrationStep.registering;
    });

    await Future<void>.delayed(TevioMotion.slow);
    if (!mounted) {
      return;
    }

    final result = ref
        .read(productRegistrationResultProvider)
        .registerProduct(_registrationInput);

    result.when(
      success: (product) {
        setState(() {
          _registeredProductId = product.id;
          _registeredProductName = product.name;
          _step = _RegistrationStep.complete;
        });
      },
      failure: (failure) {
        setState(() {
          _step = _RegistrationStep.notifications;
          _failure = _RegistrationFailure.offline;
          _registrationFailureMessage = failure.message;
        });
      },
    );
  }

  void _resetLocalState() {
    ref.read(productRegistrationDraftProvider.notifier).clear();
    _step = _RegistrationStep.method;
    _method = null;
    _recallAlert = true;
    _warrantyAlert = true;
    _returnAlert = true;
    _failure = null;
    _registrationFailureMessage = null;
    _showFieldErrors = false;
    _isPrimaryActionBusy = false;
    _permissionFlow = _permissionFlow.reset();
    _mediaPath = null;
    _registeredProductId = null;
    _registeredProductName = null;
    _nameController.clear();
    _brandController.clear();
    _modelNumberController.clear();
    _purchasedAtController.clear();
    _purchaseStoreController.clear();
  }

  ProductRegistrationInput get _registrationInput {
    return ProductRegistrationInput(
      name: _nameController.text,
      brand: _brandController.text,
      modelNumber: _modelNumberController.text,
      purchasedAt: _purchasedAtController.text,
      purchaseStore: _purchaseStoreController.text,
      recallAlert: _recallAlert,
      warrantyAlert: _warrantyAlert,
      returnAlert: _returnAlert,
    );
  }

  void _handleProductInfoChanged() {
    if (_failure == _RegistrationFailure.modelNotFound ||
        _failure == _RegistrationFailure.offline) {
      setState(() {
        _failure = null;
        _registrationFailureMessage = null;
      });
      return;
    }
    if (!_showFieldErrors) {
      return;
    }
    final shouldShowErrors = !_registrationInput.isValid;

    if (_showFieldErrors == shouldShowErrors) {
      return;
    }

    setState(() {
      _showFieldErrors = shouldShowErrors;
    });
  }

  void _moveToProductInfo(FocusNode focusNode) {
    setState(() {
      _failure = null;
      _registrationFailureMessage = null;
      _step = _RegistrationStep.productInfo;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        focusNode.requestFocus();
      }
    });
  }

  Future<void> _pickSelectedMedia() async {
    final source = switch (_method) {
      _RegistrationMethod.camera => RegistrationMediaSource.camera,
      _RegistrationMethod.gallery => RegistrationMediaSource.gallery,
      _RegistrationMethod.modelNumber ||
      _RegistrationMethod.manual ||
      null => null,
    };
    if (source == null || _isPrimaryActionBusy || _permissionFlow.isBusy) {
      return;
    }

    final picker = ref.read(registrationMediaPickerProvider);
    if (source == RegistrationMediaSource.gallery) {
      await _openMediaPicker(source);
      return;
    }

    if (picker.isCameraUnavailableEnvironment) {
      _showCameraUnavailable();
      return;
    }

    setState(() {
      _permissionFlow = RegistrationPermissionFlow(
        status: RegistrationPermissionFlowStatus.checkingPermission,
        source: source,
      );
      _failure = null;
      _registrationFailureMessage = null;
    });
    try {
      final access = await picker.checkPermission(source);
      if (!mounted) return;
      if (!_sourceMatchesMethod(source)) {
        _resetPermissionFlow();
        return;
      }
      _resetPermissionFlow();
      switch (access) {
        case RegistrationPermissionAccess.granted:
          await _openMediaPicker(source);
        case RegistrationPermissionAccess.denied:
          if (await picker.shouldShowRationale(source)) {
            if (!mounted) return;
            if (!_sourceMatchesMethod(source)) {
              _resetPermissionFlow();
              return;
            }
            final shouldContinue = await _showPermissionSheet(
              source,
              settingsRequired: false,
            );
            if (shouldContinue) await _requestPermission(source);
          } else {
            await _requestPermission(source);
          }
        case RegistrationPermissionAccess.permanentlyDenied:
          final shouldOpen = await _showPermissionSheet(
            source,
            settingsRequired: true,
          );
          if (shouldOpen) await _openPermissionSettings(source);
      }
    } on RegistrationPermissionFailure catch (error) {
      _showMediaActionFailure(error.message);
    } on Exception {
      _showMediaActionFailure('권한 확인을 시작하지 못했어요. 잠시 후 다시 시도해 주세요.');
    }
  }

  Future<void> _openMediaPicker(RegistrationMediaSource source) async {
    if (!_sourceMatchesMethod(source) || _permissionFlow.isBusy) return;
    setState(() {
      _permissionFlow = RegistrationPermissionFlow(
        status: RegistrationPermissionFlowStatus.openingPicker,
        source: source,
      );
      _failure = null;
      _registrationFailureMessage = null;
    });
    final RegistrationMediaResult result;
    try {
      result = await ref
          .read(registrationMediaPickerProvider)
          .pickGranted(source);
    } on Exception {
      _showMediaActionFailure('카메라나 앨범을 열지 못했어요. 잠시 후 다시 시도해 주세요.');
      return;
    }
    if (!mounted) return;
    if (!_sourceMatchesMethod(source)) {
      _resetPermissionFlow();
      return;
    }

    switch (result) {
      case RegistrationMediaSelected(:final path):
        setState(() {
          _permissionFlow = _permissionFlow.reset();
          _mediaPath = path;
          _step = _RegistrationStep.analyzing;
        });
      case RegistrationMediaCanceled():
        setState(() => _permissionFlow = _permissionFlow.reset());
      case RegistrationMediaFailure(:final message, :final kind):
        setState(() {
          _permissionFlow = _permissionFlow.reset();
          _failure = kind == RegistrationMediaFailureKind.cameraUnavailable
              ? _RegistrationFailure.cameraUnavailable
              : _RegistrationFailure.mediaPickFailed;
          _registrationFailureMessage = message;
        });
    }
  }

  Future<void> _requestPermission(RegistrationMediaSource source) async {
    if (!_sourceMatchesMethod(source) || _permissionFlow.isBusy) return;
    setState(() {
      _permissionFlow = RegistrationPermissionFlow(
        status: RegistrationPermissionFlowStatus.requestingPermission,
        source: source,
      );
    });
    try {
      final access = await ref
          .read(registrationMediaPickerProvider)
          .requestPermission(source);
      if (!mounted) return;
      if (!_sourceMatchesMethod(source)) {
        _resetPermissionFlow();
        return;
      }
      switch (access) {
        case RegistrationPermissionAccess.granted:
          _resetPermissionFlow();
          await _openMediaPicker(source);
        case RegistrationPermissionAccess.denied:
        case RegistrationPermissionAccess.permanentlyDenied:
          _resetPermissionFlow();
      }
    } on RegistrationPermissionFailure catch (error) {
      _showMediaActionFailure(error.message);
    } on Exception {
      _showMediaActionFailure('권한 요청을 시작하지 못했어요. 잠시 후 다시 시도해 주세요.');
    }
  }

  Future<bool> _showPermissionSheet(
    RegistrationMediaSource source, {
    required bool settingsRequired,
  }) async {
    final isCamera = source == RegistrationMediaSource.camera;
    final result = await TevioSheet.show<bool>(
      context,
      builder: (sheetContext) => TevioSheet(
        title: settingsRequired
            ? isCamera
                  ? '카메라 권한을 켜 주세요'
                  : '사진 접근을 허용해 주세요'
            : isCamera
            ? '카메라 권한이 필요해요'
            : '사진 접근 권한이 필요해요',
        child: Text(
          settingsRequired
              ? isCamera
                    ? '기기 설정에서 카메라를 허용하면 영수증 촬영을 바로 이어갈 수 있어요.'
                    : '기기 설정에서 사진 접근을 허용하면 영수증 선택을 바로 이어갈 수 있어요.'
              : isCamera
              ? '허용하면 영수증 촬영을 바로 시작해요.'
              : '허용하면 영수증 사진을 바로 선택해요.',
          style: Theme.of(sheetContext).textTheme.bodyLarge,
        ),
        footer: Row(
          children: [
            Expanded(
              child: TevioButton(
                label: '취소',
                variant: TevioButtonVariant.secondary,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ),
            const SizedBox(width: TevioSpacing.sm),
            Expanded(
              child: TevioButton(
                label: settingsRequired ? '설정 열기' : '계속',
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _openPermissionSettings(RegistrationMediaSource source) async {
    setState(() {
      _permissionFlow = RegistrationPermissionFlow(
        status: RegistrationPermissionFlowStatus.openingSettings,
        source: source,
      );
    });
    final bool opened;
    try {
      opened = await ref.read(registrationMediaPickerProvider).openSettings();
    } on Exception {
      _showMediaActionFailure('설정을 열지 못했어요. 기기 설정에서 테비오 권한을 확인해 주세요.');
      return;
    }
    if (!mounted) return;
    if (!_sourceMatchesMethod(source)) {
      _resetPermissionFlow();
      return;
    }
    if (!opened) {
      _resetPermissionFlow();
      TevioSnackbar.show(context, '설정을 열지 못했어요. 기기 설정에서 테비오 권한을 확인해 주세요.');
    }
  }

  void _resetPermissionFlow() {
    if (!mounted) return;
    setState(() => _permissionFlow = _permissionFlow.reset());
  }

  void _showMediaActionFailure(String message) {
    if (!mounted) return;
    setState(() {
      _permissionFlow = _permissionFlow.reset();
      _failure = _RegistrationFailure.mediaPickFailed;
      _registrationFailureMessage = message;
    });
    TevioSnackbar.show(context, message);
  }

  void _showCameraUnavailable() {
    if (!mounted) return;
    setState(() {
      _permissionFlow = _permissionFlow.reset();
      _failure = _RegistrationFailure.cameraUnavailable;
      _registrationFailureMessage =
          '시뮬레이터에서는 카메라를 사용할 수 없어요. 카메라 촬영은 실제 iPhone에서 확인할 수 있어요.';
    });
  }

  bool _sourceMatchesMethod(RegistrationMediaSource source) {
    return switch (source) {
      RegistrationMediaSource.camera => _method == _RegistrationMethod.camera,
      RegistrationMediaSource.gallery => _method == _RegistrationMethod.gallery,
    };
  }

  Future<void> _recoverLostMedia() async {
    final result = await ref
        .read(registrationMediaPickerProvider)
        .recoverLostImage();
    if (!mounted || result == null) return;
    switch (result) {
      case RegistrationMediaSelected(:final path):
        setState(() {
          _method ??= _RegistrationMethod.gallery;
          _mediaPath = path;
          _step = _RegistrationStep.analyzing;
        });
      case RegistrationMediaFailure(:final message, :final kind):
        setState(() {
          _failure = kind == RegistrationMediaFailureKind.cameraUnavailable
              ? _RegistrationFailure.cameraUnavailable
              : _RegistrationFailure.mediaPickFailed;
          _registrationFailureMessage = message;
        });
      case RegistrationMediaCanceled():
        return;
    }
  }

  Future<void> _analyzeMedia() async {
    final path = _mediaPath;
    if (path == null || _isPrimaryActionBusy) return;
    setState(() {
      _isPrimaryActionBusy = true;
      _failure = null;
    });
    final result = await ref
        .read(productRegistrationAnalysisRepositoryProvider)
        .analyzeReceipt(path);
    if (!mounted) return;
    switch (result) {
      case RegistrationAnalysisSuccess(:final candidate):
        _applyCandidate(candidate);
        setState(() {
          _isPrimaryActionBusy = false;
          _step = _RegistrationStep.productInfo;
        });
      case RegistrationAnalysisFailed(:final failure):
        setState(() {
          _isPrimaryActionBusy = false;
          _failure = switch (failure) {
            RegistrationAnalysisFailure.unreadableImage =>
              _RegistrationFailure.ocrFailed,
            RegistrationAnalysisFailure.network => _RegistrationFailure.offline,
          };
        });
    }
  }

  Future<void> _findModelCandidate() async {
    final modelNumber = _modelNumberController.text.trim();
    _modelNumberController.text = modelNumber;
    if (!RegExp(
      r'^[A-Za-z0-9가-힣][A-Za-z0-9가-힣._-]{2,}$',
    ).hasMatch(modelNumber)) {
      setState(() => _showFieldErrors = true);
      return;
    }
    if (_isPrimaryActionBusy) return;
    setState(() {
      _isPrimaryActionBusy = true;
      _failure = null;
    });
    final result = await ref
        .read(productRegistrationAnalysisRepositoryProvider)
        .findByModelNumber(modelNumber);
    if (!mounted) return;
    switch (result) {
      case ModelLookupSuccess(:final candidate):
        _applyCandidate(candidate);
        setState(() {
          _isPrimaryActionBusy = false;
          _showFieldErrors = false;
          _step = _RegistrationStep.candidate;
        });
      case ModelLookupFailed(:final failure):
        setState(() {
          _isPrimaryActionBusy = false;
          _failure = switch (failure) {
            ModelLookupFailure.notFound => _RegistrationFailure.modelNotFound,
            ModelLookupFailure.network => _RegistrationFailure.offline,
          };
        });
    }
  }

  void _applyCandidate(RegistrationProductCandidate candidate) {
    _nameController.text = candidate.name;
    _brandController.text = candidate.brand;
    _modelNumberController.text = candidate.modelNumber;
    _purchasedAtController.text = candidate.purchasedAt;
    _purchaseStoreController.text = candidate.purchaseStore;
  }

  Future<void> _handleMediaFailureAction() async {
    if (_failure == _RegistrationFailure.cameraUnavailable) {
      setState(() {
        _method = _RegistrationMethod.gallery;
        _permissionFlow = _permissionFlow.reset();
        _failure = null;
        _registrationFailureMessage = null;
      });
      await _pickSelectedMedia();
      return;
    }
    await _pickSelectedMedia();
  }

  Future<void> _retryAnalysis() async {
    setState(() => _failure = null);
    await _analyzeMedia();
  }

  void _continueWithManualEntry() {
    setState(() {
      _method = _RegistrationMethod.manual;
      _permissionFlow = _permissionFlow.reset();
      _failure = null;
      _mediaPath = null;
    });
    _moveToProductInfo(_nameFocusNode);
  }

  Future<void> _handleProductInfoFailureAction() async {
    if (_failure == _RegistrationFailure.offline) {
      setState(() => _failure = null);
      await _findModelCandidate();
      return;
    }
    setState(() {
      _method = _RegistrationMethod.manual;
      _failure = null;
      _showFieldErrors = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocusNode.requestFocus();
    });
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    required this.selectedMethod,
    required this.failure,
    required this.failureMessage,
    required this.onFailureAction,
    required this.onSelected,
  });

  final _RegistrationMethod? selectedMethod;
  final _RegistrationFailure? failure;
  final String? failureMessage;
  final VoidCallback onFailureAction;
  final ValueChanged<_RegistrationMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('어떤 방식으로 등록할까요?', style: TevioTypography.titleLarge),
        const SizedBox(height: TevioSpacing.xs),
        Text(
          '가장 편한 방법을 선택하면 필요한 정보만 차례로 확인할게요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (failure != null) ...[
          const SizedBox(height: TevioSpacing.lg),
          _RegistrationFailurePanel(
            failure: failure!,
            message: failureMessage,
            onActionPressed: onFailureAction,
          ),
        ],
        const SizedBox(height: TevioSpacing.xl),
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

class _DraftResumeCard extends StatelessWidget {
  const _DraftResumeCard({required this.onResume, required this.onStartOver});

  final VoidCallback onResume;
  final VoidCallback onStartOver;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('등록 중인 제품이 있어요', style: TevioTypography.titleLarge),
          const SizedBox(height: TevioSpacing.xs),
          Text(
            '입력한 정보와 진행 상황을 저장해 두었어요. 이어서 등록할까요?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: TevioSpacing.lg),
          TevioButton(label: '이어서 등록하기', onPressed: onResume),
          const SizedBox(height: TevioSpacing.sm),
          Align(
            alignment: Alignment.center,
            child: TevioTextAction(label: '새로 시작하기', onPressed: onStartOver),
          ),
        ],
      ),
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
      key: ValueKey(method),
      icon: icon,
      title: title,
      description: description,
      selected: selectedMethod == method,
      onTap: () => onSelected(method),
    );
  }
}

class _AnalysisStep extends StatelessWidget {
  const _AnalysisStep({
    required this.method,
    required this.mediaPath,
    required this.failure,
    required this.onRetryPressed,
    required this.onReplaceMediaPressed,
    required this.onManualEntryPressed,
  });

  final _RegistrationMethod? method;
  final String? mediaPath;
  final _RegistrationFailure? failure;
  final VoidCallback onRetryPressed;
  final VoidCallback onReplaceMediaPressed;
  final VoidCallback onManualEntryPressed;

  @override
  Widget build(BuildContext context) {
    if (failure != null) {
      return _AnalysisFailurePanel(
        failure: failure!,
        onRetryPressed: onRetryPressed,
        onReplaceMediaPressed: onReplaceMediaPressed,
        onManualEntryPressed: onManualEntryPressed,
      );
    }

    final title = method == _RegistrationMethod.camera
        ? '영수증을 촬영하면 정보를 읽어올게요'
        : '선택한 이미지에서 구매 정보를 읽어올게요';

    final description = method == _RegistrationMethod.camera
        ? '사진이 선명할수록 제품명, 구매일, 구매처를 더 정확히 확인할 수 있어요.'
        : '주문 내역 화면이나 영수증 이미지가 가장 정확합니다.';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TevioThemeColors.selectedSurface(context),
        borderRadius: TevioRadius.largeBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TevioSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.document_scanner_outlined,
                  color: TevioColors.primary,
                ),
                const SizedBox(width: TevioSpacing.sm),
                Expanded(
                  child: Text(
                    '구매 정보 스캔',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: TevioColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: TevioColors.mint,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TevioSpacing.md),
            _ReceiptPreview(
              path: mediaPath,
              replaceLabel: method == _RegistrationMethod.camera
                  ? '다시 촬영'
                  : '다른 사진 선택',
              onReplacePressed: onReplaceMediaPressed,
            ),
            const SizedBox(height: TevioSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TevioSpacing.xs),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: TevioSpacing.md),
            Text(
              '읽지 못한 정보는 다음 단계에서 직접 보완할 수 있어요.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: TevioColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductInfoStep extends StatelessWidget {
  const _ProductInfoStep({
    required this.method,
    required this.failure,
    required this.failureMessage,
    required this.onFailureAction,
    required this.nameController,
    required this.brandController,
    required this.modelNumberController,
    required this.purchasedAtController,
    required this.purchaseStoreController,
    required this.nameFocusNode,
    required this.modelNumberFocusNode,
    required this.showErrors,
    required this.onChanged,
    required this.purchaseDate,
    required this.onPurchaseDateChanged,
  });

  final _RegistrationMethod? method;
  final _RegistrationFailure? failure;
  final String? failureMessage;
  final VoidCallback onFailureAction;
  final TextEditingController nameController;
  final TextEditingController brandController;
  final TextEditingController modelNumberController;
  final TextEditingController purchasedAtController;
  final TextEditingController purchaseStoreController;
  final FocusNode nameFocusNode;
  final FocusNode modelNumberFocusNode;
  final bool showErrors;
  final VoidCallback onChanged;
  final DateTime? purchaseDate;
  final ValueChanged<DateTime?> onPurchaseDateChanged;

  @override
  Widget build(BuildContext context) {
    final modelNumberOnly = method == _RegistrationMethod.modelNumber;
    final helperText = switch (method) {
      _RegistrationMethod.camera ||
      _RegistrationMethod.gallery => '읽지 못한 정보만 직접 보완해 주세요.',
      _RegistrationMethod.modelNumber => '제품 라벨에 적힌 모델번호를 기준으로 확인합니다.',
      _RegistrationMethod.manual => '알 수 있는 정보만 먼저 입력해도 등록할 수 있어요.',
      null => '제품 정보를 입력해 주세요.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TevioSectionHeader(title: '제품 정보'),
        const SizedBox(height: TevioSpacing.sm),
        Text(helperText, style: Theme.of(context).textTheme.bodyMedium),
        if (failure != null) ...[
          const SizedBox(height: TevioSpacing.lg),
          _RegistrationFailurePanel(
            failure: failure!,
            message: failureMessage,
            onActionPressed: onFailureAction,
          ),
        ],
        const SizedBox(height: TevioSpacing.lg),
        if (!modelNumberOnly) ...[
          TevioTextField(
            label: '제품명',
            controller: nameController,
            focusNode: nameFocusNode,
            onChanged: (_) => onChanged(),
            hintText: '예: 공기청정기',
            errorText: _requiredErrorText(nameController, '제품명을 입력해 주세요.'),
          ),
          const SizedBox(height: TevioSpacing.md),
          TevioTextField(
            label: '제조사',
            controller: brandController,
            onChanged: (_) => onChanged(),
            hintText: '예: ABC',
            errorText: _requiredErrorText(brandController, '제조사를 입력해 주세요.'),
          ),
          const SizedBox(height: TevioSpacing.md),
        ],
        TevioTextField(
          label: '모델번호',
          controller: modelNumberController,
          focusNode: modelNumberFocusNode,
          onChanged: (_) => onChanged(),
          hintText: '예: ABC-123',
          helperText: modelNumberOnly
              ? '제품 뒷면이나 바닥의 라벨에서 MODEL, 모델명 항목을 확인해 주세요.'
              : method == _RegistrationMethod.manual
              ? '모델번호를 모르면 비워두고 등록할 수 있어요.'
              : null,
          errorText: _modelNumberError(),
        ),
        if (!modelNumberOnly) ...[
          const SizedBox(height: TevioSpacing.md),
          TevioDateField(
            label: '구매일',
            value: purchaseDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            onChanged: onPurchaseDateChanged,
            helpText: '구매일을 선택하세요',
            errorText: _purchaseDateError(),
          ),
          const SizedBox(height: TevioSpacing.md),
          TevioTextField(
            label: '구매처',
            controller: purchaseStoreController,
            onChanged: (_) => onChanged(),
            hintText: '예: 브랜드 공식몰',
          ),
        ],
      ],
    );
  }

  String? _requiredErrorText(TextEditingController controller, String message) {
    if (!showErrors || controller.text.trim().isNotEmpty) {
      return null;
    }

    return message;
  }

  String? _modelNumberError() {
    final value = modelNumberController.text.trim();
    if (method == _RegistrationMethod.modelNumber &&
        showErrors &&
        value.isEmpty) {
      return '모델번호를 입력해 주세요.';
    }
    if (method != _RegistrationMethod.modelNumber && value.isEmpty) {
      return null;
    }
    if (showErrors &&
        !RegExp(r'^[A-Za-z0-9가-힣][A-Za-z0-9가-힣._-]{2,}$').hasMatch(value)) {
      return '모델번호를 3자 이상 입력해 주세요.';
    }
    return null;
  }

  String? _purchaseDateError() {
    if (!showErrors || purchasedAtController.text.trim().isEmpty) {
      return null;
    }
    final parts = purchasedAtController.text.split('.');
    if (parts.length != 3) {
      return '구매일을 선택해 주세요.';
    }
    final date = DateTime.tryParse(
      '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}',
    );
    if (date == null || date.isAfter(DateTime.now())) {
      return '오늘 이전의 구매일을 선택해 주세요.';
    }
    return null;
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({
    required this.path,
    required this.replaceLabel,
    required this.onReplacePressed,
  });

  final String? path;
  final String replaceLabel;
  final VoidCallback onReplacePressed;

  @override
  Widget build(BuildContext context) {
    final imagePath = path;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: TevioRadius.mediumBorder,
            child: imagePath == null
                ? ColoredBox(
                    color: TevioThemeColors.surface(context),
                    child: const Center(
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: TevioColors.textTertiary,
                        size: 32,
                      ),
                    ),
                  )
                : Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: TevioThemeColors.surface(context),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: TevioColors.danger,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: TevioSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: TevioTextAction(
            label: replaceLabel,
            onPressed: onReplacePressed,
          ),
        ),
      ],
    );
  }
}

class _AnalysisFailurePanel extends StatelessWidget {
  const _AnalysisFailurePanel({
    required this.failure,
    required this.onRetryPressed,
    required this.onReplaceMediaPressed,
    required this.onManualEntryPressed,
  });

  final _RegistrationFailure failure;
  final VoidCallback onRetryPressed;
  final VoidCallback onReplaceMediaPressed;
  final VoidCallback onManualEntryPressed;

  @override
  Widget build(BuildContext context) {
    final copy = _RegistrationFailureCopy.from(failure);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TevioErrorState(
          title: copy.title,
          description: copy.description,
          actionLabel: failure == _RegistrationFailure.offline
              ? '다시 시도'
              : '이미지 다시 선택',
          onRetryPressed: failure == _RegistrationFailure.offline
              ? onRetryPressed
              : onReplaceMediaPressed,
        ),
        Align(
          alignment: Alignment.center,
          child: TevioTextAction(
            label: '직접 입력으로 계속',
            onPressed: onManualEntryPressed,
          ),
        ),
      ],
    );
  }
}

class _RegistrationFailurePanel extends StatelessWidget {
  const _RegistrationFailurePanel({
    required this.failure,
    required this.message,
    required this.onActionPressed,
  });

  final _RegistrationFailure failure;
  final String? message;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final copy = _RegistrationFailureCopy.from(failure);
    return TevioFeedbackBanner(
      status: RightsStatus.urgent,
      title: copy.title,
      description: message ?? copy.description,
      actionLabel: copy.action,
      onActionPressed: onActionPressed,
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
      _RegistrationFailure.mediaPickFailed => const _RegistrationFailureCopy(
        title: '이미지를 불러오지 못했어요',
        description: '카메라나 앨범을 다시 열어 영수증 이미지를 선택해 주세요.',
        action: '다시 시도',
      ),
      _RegistrationFailure.cameraUnavailable => const _RegistrationFailureCopy(
        title: '시뮬레이터에서는 카메라를 사용할 수 없어요',
        description: '카메라 촬영은 실제 iPhone에서 확인하거나 앨범의 이미지를 사용할 수 있어요.',
        action: '앨범에서 선택',
      ),
      _RegistrationFailure.ocrFailed => const _RegistrationFailureCopy(
        title: '영수증을 읽지 못했어요',
        description: '사진이 흐리거나 일부 정보가 가려져 있으면 직접 입력이 필요합니다.',
        action: '직접 입력으로 계속',
      ),
      _RegistrationFailure.modelNotFound => const _RegistrationFailureCopy(
        title: '모델번호를 확인하지 못했어요',
        description: '제품 라벨의 모델번호를 다시 확인하거나 제품명을 입력해 주세요.',
        action: '직접 등록',
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
  const _CandidateStep({required this.input});

  final ProductRegistrationInput input;

  @override
  Widget build(BuildContext context) {
    final normalizedInput = input.normalized();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TevioSectionHeader(title: '제품 후보 확인'),
        const SizedBox(height: TevioSpacing.sm),
        TevioProductCard(
          name: normalizedInput.name,
          brand: normalizedInput.brand,
          modelNumber: normalizedInput.modelNumber,
          purchasedAt: normalizedInput.purchasedAt,
          warrantyText: '365일 예상',
          status: RightsStatus.detected,
          summary: '입력한 모델번호와 가장 유사한 제품 후보예요.',
        ),
        const SizedBox(height: TevioSpacing.sm),
        const TevioFeedbackBanner(
          status: RightsStatus.detected,
          title: '자동으로 확정하지 않았어요',
          description: '읽어온 정보의 신뢰도가 충분하지 않아 등록 전에 제품 후보를 직접 확인합니다.',
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
        TevioListSection(
          children: [
            TevioSwitch(
              value: recallAlert,
              onChanged: onRecallChanged,
              label: '리콜과 무상수리',
              description: '안전 문제와 공식 조치가 감지되면 알려드려요.',
            ),
            TevioSwitch(
              value: warrantyAlert,
              onChanged: onWarrantyChanged,
              label: '보증 만료',
              description: '무상보증 종료 전 필요한 시점에 알려드려요.',
            ),
            TevioSwitch(
              value: returnAlert,
              onChanged: onReturnChanged,
              label: '반품과 교환 가능 기간',
              description: '구매 이후 놓치기 쉬운 기한을 확인해요.',
            ),
          ],
        ),
      ],
    );
  }
}

class _RegisteringStep extends StatelessWidget {
  const _RegisteringStep({required this.input});

  final ProductRegistrationInput input;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('제품 정보를 등록하고 있어요', style: TevioTypography.titleLarge),
        const SizedBox(height: TevioSpacing.xs),
        Text(
          '모델번호와 구매 정보를 저장한 뒤 첫 권리 상태를 확인합니다.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TevioSpacing.xl),
        const TevioProcessTracker(
          steps: [
            TevioProcessStep(label: '제품 저장'),
            TevioProcessStep(
              label: '권리 확인',
              description: '공식 리콜 정보와 보증 기간을 확인하고 있어요.',
            ),
            TevioProcessStep(label: '알림 준비'),
            TevioProcessStep(label: '완료'),
          ],
          currentStep: 1,
          updatedAt: '진행 중',
        ),
        const SizedBox(height: TevioSpacing.xl),
        TevioEvidenceVault(
          items: [
            const TevioEvidenceItem(label: '모델번호', value: '확인됨'),
            const TevioEvidenceItem(label: '구매 정보', value: '저장됨'),
            TevioEvidenceItem(label: '알림', value: input.alertSummary),
          ],
        ),
      ],
    );
  }
}
