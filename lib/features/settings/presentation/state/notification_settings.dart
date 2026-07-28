import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsController, NotificationSettings>(
      NotificationSettingsController.new,
    );

class NotificationSettings {
  const NotificationSettings({
    this.recall = true,
    this.warranty = true,
    this.returnWindow = true,
    this.processing = true,
  });

  final bool recall;
  final bool warranty;
  final bool returnWindow;
  final bool processing;

  NotificationSettings copyWith({
    bool? recall,
    bool? warranty,
    bool? returnWindow,
    bool? processing,
  }) {
    return NotificationSettings(
      recall: recall ?? this.recall,
      warranty: warranty ?? this.warranty,
      returnWindow: returnWindow ?? this.returnWindow,
      processing: processing ?? this.processing,
    );
  }
}

class NotificationSettingsController extends Notifier<NotificationSettings> {
  static const _recallKey = 'notification_settings.recall';
  static const _warrantyKey = 'notification_settings.warranty';
  static const _returnWindowKey = 'notification_settings.return_window';
  static const _processingKey = 'notification_settings.processing';

  @override
  NotificationSettings build() {
    unawaited(_restore());
    return const NotificationSettings();
  }

  void setRecall(bool value) {
    state = state.copyWith(recall: value);
    unawaited(_save());
  }

  void setWarranty(bool value) {
    state = state.copyWith(warranty: value);
    unawaited(_save());
  }

  void setReturnWindow(bool value) {
    state = state.copyWith(returnWindow: value);
    unawaited(_save());
  }

  void setProcessing(bool value) {
    state = state.copyWith(processing: value);
    unawaited(_save());
  }

  Future<void> _restore() async {
    final preferences = await SharedPreferences.getInstance();
    if (!ref.mounted) {
      return;
    }

    state = state.copyWith(
      recall: preferences.getBool(_recallKey) ?? state.recall,
      warranty: preferences.getBool(_warrantyKey) ?? state.warranty,
      returnWindow: preferences.getBool(_returnWindowKey) ?? state.returnWindow,
      processing: preferences.getBool(_processingKey) ?? state.processing,
    );
  }

  Future<void> _save() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(_recallKey, state.recall),
      preferences.setBool(_warrantyKey, state.warranty),
      preferences.setBool(_returnWindowKey, state.returnWindow),
      preferences.setBool(_processingKey, state.processing),
    ]);
  }
}
