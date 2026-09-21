import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prototipo_gym/app.dart';
import 'package:prototipo_gym/data/mock/mock_data.dart';
import 'package:prototipo_gym/data/models/branch.dart';
import 'package:prototipo_gym/data/repositories/gym_repositories.dart';

class _StaticBranchRepository implements BranchRepository {
  @override
  Stream<List<Branch>> watchBranches(String brandId) async* {
    yield mockBranches;
  }
}

void main() {
  testWidgets('la card de entrenador seguido no hace overflow', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_done': true,
      'following_trainers': <String>['t1'],
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          branchRepositoryProvider.overrideWithValue(_StaticBranchRepository()),
        ],
        child: const MembersApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.scrollUntilVisible(
      find.text('SIGUIENDO'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SIGUIENDO'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
