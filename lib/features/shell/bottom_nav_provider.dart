import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void go(int index) => state = index;
}

final bottomNavIndexProvider =
    NotifierProvider<BottomNavIndexNotifier, int>(BottomNavIndexNotifier.new);
