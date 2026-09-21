import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/branch.dart';
import '../../../data/repositories/gym_repositories.dart';
import '../../../core/branding/brand_provider.dart';

class OverallOccupancy {
  const OverallOccupancy({required this.current, required this.max});

  final int current;
  final int max;

  double get ratio => max <= 0 ? 0 : current / max;
}

final branchesProvider = StreamProvider<List<Branch>>((ref) {
  final brand = ref.watch(activeBrandProvider);
  return ref.watch(branchRepositoryProvider).watchBranches(brand.id);
});

final overallOccupancyProvider = Provider<OverallOccupancy?>((ref) {
  final branches = ref.watch(branchesProvider).value;
  if (branches == null || branches.isEmpty) return null;
  var current = 0;
  var max = 0;
  for (final branch in branches) {
    current += branch.currentCapacity;
    max += branch.maxCapacity;
  }
  return OverallOccupancy(current: current, max: max);
});
