import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/api_client.dart';
import '../../../core/firebase/auth_provider.dart';
import '../../../data/models/gym_class.dart';
import 'catalog_providers.dart';

class ReservedClassesNotifier extends Notifier<Set<String>> {
  /// El estado se clavea `'$classId|$branchId|$classDate'` — una reserva
  /// es por ocurrencia EN UNA SEDE: la misma clase multi-sede puede estar
  /// reservada en Select y libre en Carranza.
  static String keyOf(String classId, String branchId, String date) =>
      '$classId|$branchId|$date';

  @override
  Set<String> build() {
    if (!AppConfig.firebaseActive) return const {};
    final uid = ref.watch(authUidProvider);
    if (uid == null) return const {};

    /// Reservas reales del socio — las escribe POST /api/classes/:id/book
    /// (el cliente jamás toca la colección). El stream re-emite solo
    /// cuando el server confirma, así el estado sobrevive a reinicios.
    /// Reservas viejas sin class_date cuentan en su fecha de created_at.
    final sub = FirebaseFirestore.instance
        .collection('bookings')
        .where('auth_uid', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
          state = snap.docs
              .where((d) => d.data()['status'] == 'confirmed')
              .map((d) {
                final data = d.data();
                final created = data['created_at'];
                final date =
                    data['class_date'] as String? ??
                    (created is Timestamp
                        ? GymClass.dateKey(created.toDate())
                        : GymClass.dateKey(DateTime.now()));
                return keyOf(
                  data['class_id'] as String,
                  data['branch_id'] as String? ?? '',
                  date,
                );
              })
              .toSet();
        });
    ref.onDispose(sub.cancel);
    return const {};
  }

  /// Reserva o cancela la ocurrencia de [date] en [branchId] vía el
  /// backend; el stream de bookings refleja el resultado. En modo demo
  /// (sin Firebase) solo alterna en memoria.
  Future<void> toggle(
    String classId, {
    required String branchId,
    required String date,
  }) async {
    final key = keyOf(classId, branchId, date);
    if (!AppConfig.firebaseActive) {
      state = state.contains(key)
          ? (<String>{...state}..remove(key))
          : <String>{...state, key};
      return;
    }
    if (state.contains(key)) {
      await ApiClient.del(
        '/api/classes/$classId/book?date=$date&branchId=$branchId',
      );
    } else {
      await ApiClient.post('/api/classes/$classId/book', {
        'date': date,
        'branchId': branchId,
      });
    }
    ref.invalidate(branchClassesProvider);
  }
}

final reservedClassesProvider =
    NotifierProvider<ReservedClassesNotifier, Set<String>>(
      ReservedClassesNotifier.new,
    );
