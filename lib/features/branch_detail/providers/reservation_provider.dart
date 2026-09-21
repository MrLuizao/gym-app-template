import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReservedClassesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String classId) {
    state = state.contains(classId)
        ? (<String>{...state}..remove(classId))
        : <String>{...state, classId};
  }
}

final reservedClassesProvider =
    NotifierProvider<ReservedClassesNotifier, Set<String>>(
  ReservedClassesNotifier.new,
);
