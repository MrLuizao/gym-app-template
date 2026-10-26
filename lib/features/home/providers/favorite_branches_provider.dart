import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/gym_repositories.dart';
import '../../payments/providers/membership_provider.dart';

class FavoriteBranchesNotifier extends Notifier<Set<String>> {
  static const _key = 'favorite_branches';

  @override
  Set<String> build() {
    final member = ref.watch(memberProvider).value;
    final membership = ref.watch(membershipProvider);
    Future.microtask(
      () => _loadAndSanitize(member?.branchId, membership.allBranches),
    );
    return const {};
  }

  Future<void> _loadAndSanitize(String? homeBranchId, bool allBranches) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getStringList(_key) ?? const <String>[]).toSet();

    // Si el plan es mono-sede con sede asignada:
    if (!allBranches && homeBranchId != null && homeBranchId.isNotEmpty) {
      if (saved.isEmpty || !saved.contains(homeBranchId) || saved.length > 1) {
        state = {homeBranchId};
        _persist();
        return;
      }
    }
    state = saved;
  }

  /// Verifica si el socio puede marcar esta sede según su plan.
  bool canSelectBranch(String branchId) {
    final member = ref.read(memberProvider).value;
    final membership = ref.read(membershipProvider);
    if (membership.allBranches) return true;
    if (member?.branchId == null || member!.branchId!.isEmpty) return true;
    return branchId == member.branchId;
  }

  /// Retorna `true` si el cambio fue exitoso, `false` si la sede está fuera de su plan.
  bool toggle(String branchId) {
    if (!canSelectBranch(branchId)) {
      return false;
    }
    state = state.contains(branchId) ? const {} : {branchId};
    _persist();
    return true;
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
