import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/firebase/auth_provider.dart';
import '../mock/mock_data.dart';
import '../models/branch.dart';
import '../models/member.dart';

abstract class BranchRepository {
  Stream<List<Branch>> watchBranches(String brandId);
}

class FirestoreBranchRepository implements BranchRepository {
  FirestoreBranchRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<Branch>> watchBranches(String brandId) {
    /// Una marca por deployment — no hay filtro por brand_id.
    return _db
        .collection('branches')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Branch.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}

class MockBranchRepository implements BranchRepository {
  final _random = Random();

  @override
  Stream<List<Branch>> watchBranches(String brandId) async* {
    var branches = mockBranches
        .where((branch) => branch.brandId == brandId)
        .toList();
    yield List.of(branches);
    await for (final _ in Stream<void>.periodic(const Duration(seconds: 4))) {
      branches = branches.map(_simulateTraffic).toList();
      yield List.of(branches);
    }
  }

  Branch _simulateTraffic(Branch branch) {
    final delta = _random.nextInt(9) - 4;
    final next = (branch.currentCapacity + delta).clamp(0, branch.maxCapacity);
    return branch.copyWith(currentCapacity: next);
  }
}

abstract class MemberRepository {
  Stream<Member> watchMember(String userId);
}

class FirestoreMemberRepository implements MemberRepository {
  FirestoreMemberRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<Member> watchMember(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => Member.fromMap(doc.id, doc.data() ?? const {}));
  }
}

class MockMemberRepository implements MemberRepository {
  @override
  Stream<Member> watchMember(String userId) async* {
    yield mockMember;
  }
}

/// Pronóstico de aforo — /forecasts/{branchId} generado por close-day.
/// Devuelve el array de 24 horas del día de semana actual (lunes=1).
class ForecastRepository {
  ForecastRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<double>> watchTodayForecast(String branchId) {
    return _db.collection('forecasts').doc(branchId).snapshots().map((doc) {
      final byWeekday =
          doc.data()?['by_weekday'] as Map<String, dynamic>? ?? const {};
      final weekday = ((DateTime.now().weekday - 1) % 7 + 1).toString();
      final hours = byWeekday[weekday] as List<dynamic>? ?? const [];
      return List<double>.generate(
        24,
        (h) => (h < hours.length ? (hours[h] as num?)?.toDouble() : 0) ?? 0,
      );
    });
  }
}

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return AppConfig.firebaseActive
      ? FirestoreBranchRepository()
      : MockBranchRepository();
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return AppConfig.firebaseActive
      ? FirestoreMemberRepository()
      : MockMemberRepository();
});

final forecastRepositoryProvider = Provider<ForecastRepository>(
  (ref) => ForecastRepository(),
);

/// Pronóstico de hoy por sede — null si Firebase está apagado.
final todayForecastProvider = StreamProvider.family<List<double>?, String>((
  ref,
  branchId,
) {
  if (!AppConfig.firebaseActive) return Stream.value(null);
  return ref.watch(forecastRepositoryProvider).watchTodayForecast(branchId);
});

/// ¿Existe ya /users/{uid}? Con registro social el primer login llega
/// sin doc — el gate usa esto para mandar a completar perfil.
final memberDocExistsProvider = StreamProvider<bool>((ref) {
  if (!AppConfig.firebaseActive) return Stream.value(true);
  final uid = ref.watch(authUidProvider);
  if (uid == null) return Stream.value(false);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists);
});

/// El socio logueado — su uid de Firebase Auth es el doc /users/{uid}.
final memberProvider = StreamProvider<Member>((ref) {
  final uid = AppConfig.firebaseActive
      ? ref.watch(authUidProvider)
      : AppConfig.demoUserId;
  if (uid == null) return Stream.error(StateError('Sin sesión'));
  return ref.watch(memberRepositoryProvider).watchMember(uid);
});
