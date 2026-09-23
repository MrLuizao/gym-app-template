import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteBranchesNotifier extends Notifier<Set<String>> {
  static const _key = 'favorite_branches';

  @override
  Set<String> build() {
    Future.microtask(_load);
    return const {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  void toggle(String branchId) {
    state = state.contains(branchId) ? const {} : {branchId};
    _persist();
  }

  void _persist() {
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList(_key, state.toList()),
    );
  }
}

final favoriteBranchesProvider =
    NotifierProvider<FavoriteBranchesNotifier, Set<String>>(
      FavoriteBranchesNotifier.new,
    );
