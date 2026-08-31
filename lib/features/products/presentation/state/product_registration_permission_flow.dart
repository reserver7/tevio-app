import '../../data/registration_media_picker.dart';

enum RegistrationPermissionFlowStatus {
  idle,
  checkingPermission,
  requestingPermission,
  openingPicker,
  openingSettings,
  waitingForSettingsReturn,
}

class RegistrationPermissionFlow {
  const RegistrationPermissionFlow({
    this.status = RegistrationPermissionFlowStatus.idle,
    this.source,
  });

  final RegistrationPermissionFlowStatus status;
  final RegistrationMediaSource? source;

  bool get isBusy => switch (status) {
    RegistrationPermissionFlowStatus.checkingPermission ||
    RegistrationPermissionFlowStatus.requestingPermission ||
    RegistrationPermissionFlowStatus.openingPicker ||
    RegistrationPermissionFlowStatus.openingSettings => true,
    _ => false,
  };

  bool isWaitingFor(RegistrationMediaSource expectedSource) {
    return status ==
            RegistrationPermissionFlowStatus.waitingForSettingsReturn &&
        source == expectedSource;
  }

  RegistrationPermissionFlow transition(
    RegistrationPermissionFlowStatus next, {
    RegistrationMediaSource? source,
  }) {
    return RegistrationPermissionFlow(
      status: next,
      source: source ?? this.source,
    );
  }

  RegistrationPermissionFlow reset() => const RegistrationPermissionFlow();
}
