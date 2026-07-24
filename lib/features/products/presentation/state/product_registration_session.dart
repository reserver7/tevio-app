import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRegistrationSessionProvider =
    NotifierProvider<ProductRegistrationSession, int>(
      ProductRegistrationSession.new,
    );

class ProductRegistrationSession extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void reset() {
    state++;
  }
}
