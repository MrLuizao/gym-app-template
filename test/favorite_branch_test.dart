import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prototipo_gym/features/home/providers/favorite_branches_provider.dart';

void main() {
  test('solo puede haber una sede favorita a la vez', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(favoriteBranchesProvider.notifier);

    notifier.toggle('select');
    expect(container.read(favoriteBranchesProvider), {'select'});

    notifier.toggle('xpress');
    expect(container.read(favoriteBranchesProvider), {'xpress'});

    notifier.toggle('xpress');
    expect(container.read(favoriteBranchesProvider), isEmpty);
  });
}
