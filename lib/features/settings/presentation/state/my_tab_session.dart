import 'package:flutter_riverpod/flutter_riverpod.dart';

final myTabSessionProvider = NotifierProvider<MyTabSession, int>(
  MyTabSession.new,
);

class MyTabSession extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void reset() {
    state++;
  }
}
