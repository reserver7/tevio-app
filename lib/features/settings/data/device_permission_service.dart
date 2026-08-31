import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum TevioDevicePermission { camera, photos, notifications }

enum TevioPermissionState { allowed, limited, denied }

enum TevioSettingsDestination { appDetails, notifications }

class DevicePermissionService {
  const DevicePermissionService();

  static const _settingsChannel = MethodChannel(
    'com.tevio.tevio_app/system_settings',
  );

  bool get supportsPhotosPermission => Platform.isIOS;

  Future<TevioPermissionState> status(TevioDevicePermission type) async {
    final status = await _permission(type).status;
    if (status.isLimited) return TevioPermissionState.limited;
    if (status.isGranted) return TevioPermissionState.allowed;
    return TevioPermissionState.denied;
  }

  Future<PermissionStatus> request(TevioDevicePermission type) {
    return _permission(type).request();
  }

  Future<bool> openSettings(TevioSettingsDestination destination) async {
    if (destination == TevioSettingsDestination.notifications &&
        Platform.isAndroid) {
      try {
        final opened = await _settingsChannel.invokeMethod<bool>(
          'openNotificationSettings',
        );
        if (opened == true) return true;
      } on PlatformException {
        // Fall through to the supported app-details settings destination.
      } on MissingPluginException {
        // Fall through when running against an older native build.
      }
    }
    return openAppSettings();
  }

  TevioSettingsDestination settingsDestinationFor(TevioDevicePermission type) =>
      switch (type) {
        TevioDevicePermission.notifications =>
          TevioSettingsDestination.notifications,
        TevioDevicePermission.camera ||
        TevioDevicePermission.photos => TevioSettingsDestination.appDetails,
      };

  Permission _permission(TevioDevicePermission type) => switch (type) {
    TevioDevicePermission.camera => Permission.camera,
    TevioDevicePermission.photos => Permission.photos,
    TevioDevicePermission.notifications => Permission.notification,
  };
}
