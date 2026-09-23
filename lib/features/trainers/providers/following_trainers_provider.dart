import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/mock/mock_data.dart';
import '../../../data/models/trainer.dart';

class FollowingTrainersNotifier extends Notifier<Set<String>> {
  static const _key = 'following_trainers';

  @override
  Set<String> build() {
    Future.microtask(_load);
    return const {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  void toggle(String trainerId) {
    state = state.contains(trainerId)
        ? (<String>{...state}..remove(trainerId))
        : <String>{...state, trainerId};
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList(_key, state.toList()),
    );
  }
}

final followingTrainersProvider =
    NotifierProvider<FollowingTrainersNotifier, Set<String>>(
      FollowingTrainersNotifier.new,
    );

final followedTrainersProvider = Provider<List<Trainer>>((ref) {
  final ids = ref.watch(followingTrainersProvider);
  return mockTrainers.where((trainer) => ids.contains(trainer.id)).toList();
});
