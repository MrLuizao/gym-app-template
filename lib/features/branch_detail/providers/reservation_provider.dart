import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/api_client.dart';
import '../../../core/firebase/auth_provider.dart';
import 'catalog_providers.dart';

class ReservedClassesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    if (!AppConfig.firebaseActive) return const {};
    final uid = ref.watch(authUidProvider);
    if (uid == null) return const {};

    /// Reservas reales del socio — las escribe POST /api/classes/:id/book
    /// (el cliente jamás toca la colección). El stream re-emite solo
    /// cuando el server confirma, así el estado sobrevive a reinicios.
    final sub = FirebaseFirestore.instance
        .collection('bookings')
        .where('auth_uid', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
          state = snap.docs
              .where((d) => d.data()['status'] == 'confirmed')
              .map((d) => d.data()['class_id'] as String)
              .toSet();
        });
    ref.onDispose(sub.cancel);
    return const {};
  }

  /// Reserva o cancela vía el backend; el stream de bookings refleja el
  /// resultado. En modo demo (sin Firebase) solo alterna en memoria.
  Future<void> toggle(String classId) async {
    if (!AppConfig.firebaseActive) {
      state = state.contains(classId)
          ? (<String>{...state}..remove(classId))
          : <String>{...state, classId};
      return;
    }
    if (state.contains(classId)) {
      await ApiClient.del('/api/classes/$classId/book');
    } else {
      await ApiClient.post('/api/classes/$classId/book', const {});
    }
    ref.invalidate(branchClassesProvider);
  }
}

final reservedClassesProvider =
    NotifierProvider<ReservedClassesNotifier, Set<String>>(
      ReservedClassesNotifier.new,
    );
