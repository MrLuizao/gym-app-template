import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
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
    return _db
        .collection('branches')
        .where('brand_id', isEqualTo: brandId)
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
    var branches =
        mockBranches.where((branch) => branch.brandId == brandId).toList();
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
    return _db.collection('users').doc(userId).snapshots().map(
          (doc) => Member.fromMap(doc.id, doc.data() ?? const {}),
        );
  }
}

class MockMemberRepository implements MemberRepository {
  @override
  Stream<Member> watchMember(String userId) async* {
    yield mockMember;
  }
}

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return AppConfig.useFirebase
      ? FirestoreBranchRepository()
      : MockBranchRepository();
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return AppConfig.useFirebase
      ? FirestoreMemberRepository()
      : MockMemberRepository();
});

final memberProvider = StreamProvider<Member>((ref) {
  return ref.watch(memberRepositoryProvider).watchMember(AppConfig.demoUserId);
});
