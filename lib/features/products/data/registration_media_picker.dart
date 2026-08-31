import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum RegistrationMediaSource { camera, gallery }

enum RegistrationPermissionAccess { granted, denied, permanentlyDenied }

sealed class RegistrationMediaResult {
  const RegistrationMediaResult();
}

class RegistrationMediaSelected extends RegistrationMediaResult {
  const RegistrationMediaSelected(this.path);

  final String path;
}

class RegistrationMediaCanceled extends RegistrationMediaResult {
  const RegistrationMediaCanceled();
}

enum RegistrationMediaFailureKind {
  cameraUnavailable,
  permissionDenied,
  pluginUnavailable,
  pickerFailure,
}

class RegistrationMediaFailure extends RegistrationMediaResult {
  const RegistrationMediaFailure(
    this.message, {
    this.kind = RegistrationMediaFailureKind.pickerFailure,
  });

  final String message;
  final RegistrationMediaFailureKind kind;
}

class RegistrationPermissionFailure implements Exception {
  const RegistrationPermissionFailure(this.message);

  final String message;
}

class RegistrationMediaPicker {
  RegistrationMediaPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  bool get isCameraUnavailableEnvironment =>
      Platform.isIOS &&
      (Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
          Platform.environment.containsKey('SIMULATOR_UDID') ||
          Platform.environment.containsKey('IPHONE_SIMULATOR_ROOT'));

  Future<RegistrationMediaResult> pickGranted(
    RegistrationMediaSource source,
  ) async {
    if (source == RegistrationMediaSource.camera &&
        isCameraUnavailableEnvironment) {
      return const RegistrationMediaFailure(
        'iOS 시뮬레이터에서는 카메라를 사용할 수 없어요. 실제 기기에서 촬영하거나 앨범에서 선택해 주세요.',
        kind: RegistrationMediaFailureKind.cameraUnavailable,
      );
    }
    try {
      final image = await _picker.pickImage(
        source: source == RegistrationMediaSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 92,
      );
      if (image == null) {
        return const RegistrationMediaCanceled();
      }
      return RegistrationMediaSelected(image.path);
    } on MissingPluginException {
      return const RegistrationMediaFailure(
        '카메라 기능을 준비하지 못했어요. 앱을 완전히 종료한 뒤 다시 실행해 주세요.',
        kind: RegistrationMediaFailureKind.pluginUnavailable,
      );
    } on PlatformException catch (error) {
      return RegistrationMediaFailure(
        _pickerFailureMessage(source, error.code),
        kind: _pickerFailureKind(source, error.code),
      );
    } on Exception {
      return RegistrationMediaFailure(_pickerFailureMessage(source, null));
    }
  }

  RegistrationMediaFailureKind _pickerFailureKind(
    RegistrationMediaSource source,
    String? errorCode,
  ) {
    if (source != RegistrationMediaSource.camera) {
      return RegistrationMediaFailureKind.pickerFailure;
    }
    if (errorCode == 'camera_access_denied') {
      return RegistrationMediaFailureKind.permissionDenied;
    }
    if (errorCode == 'no_available_camera' ||
        errorCode == 'camera_unavailable') {
      return RegistrationMediaFailureKind.cameraUnavailable;
    }
    return RegistrationMediaFailureKind.pickerFailure;
  }

  String _pickerFailureMessage(
    RegistrationMediaSource source,
    String? errorCode,
  ) {
    if (source == RegistrationMediaSource.camera) {
      return errorCode == 'camera_access_denied'
          ? '카메라 권한이 꺼져 있어요. 다시 눌러 기기 설정에서 권한을 확인해 주세요.'
          : '카메라를 열지 못했어요. 실제 기기에서 다시 시도하거나 앨범에서 선택해 주세요.';
    }
    return '앨범을 열지 못했어요. 잠시 후 다시 시도해 주세요.';
  }

  Future<RegistrationPermissionAccess> checkPermission(
    RegistrationMediaSource source,
  ) async {
    if (source == RegistrationMediaSource.gallery) {
      return RegistrationPermissionAccess.granted;
    }
    try {
      final permission = _permissionFor(source);
      if (permission == null) {
        return RegistrationPermissionAccess.granted;
      }
      return _mapPermissionStatus(await permission.status);
    } on Exception {
      throw const RegistrationPermissionFailure(
        '권한 상태를 확인하지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
    }
  }

  Future<RegistrationPermissionAccess> requestPermission(
    RegistrationMediaSource source,
  ) async {
    if (source == RegistrationMediaSource.gallery) {
      return RegistrationPermissionAccess.granted;
    }
    try {
      final permission = _permissionFor(source);
      if (permission == null) {
        return RegistrationPermissionAccess.granted;
      }
      return _mapPermissionStatus(await permission.request());
    } on Exception {
      throw const RegistrationPermissionFailure(
        '권한 요청을 시작하지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
    }
  }

  Future<bool> shouldShowRationale(RegistrationMediaSource source) async {
    if (source == RegistrationMediaSource.gallery) {
      return false;
    }
    try {
      final permission = _permissionFor(source);
      return permission == null ? false : permission.shouldShowRequestRationale;
    } on Exception {
      throw const RegistrationPermissionFailure(
        '권한 상태를 확인하지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
    }
  }

  Permission? _permissionFor(RegistrationMediaSource source) {
    return switch (source) {
      RegistrationMediaSource.camera => Permission.camera,
      RegistrationMediaSource.gallery => null,
    };
  }

  RegistrationPermissionAccess _mapPermissionStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return RegistrationPermissionAccess.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return RegistrationPermissionAccess.permanentlyDenied;
    }
    return RegistrationPermissionAccess.denied;
  }

  Future<bool> openSettings() => openAppSettings();

  Future<RegistrationMediaResult?> recoverLostImage() async {
    if (!Platform.isAndroid) {
      return null;
    }
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return null;
      }
      final file =
          response.file ??
          (response.files?.isNotEmpty == true ? response.files!.first : null);
      if (file != null) {
        return RegistrationMediaSelected(file.path);
      }
      return const RegistrationMediaFailure('선택한 이미지를 복구하지 못했어요. 다시 선택해 주세요.');
    } on Exception {
      return const RegistrationMediaFailure('선택한 이미지를 복구하지 못했어요. 다시 선택해 주세요.');
    }
  }
}
