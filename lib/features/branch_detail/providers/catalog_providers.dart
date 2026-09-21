import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/catalog_repository.dart';
import '../../../data/models/gym_class.dart';
import '../../../data/models/trainer.dart';

final branchClassesProvider = FutureProvider.family<List<GymClass>, String>(
  (ref, branchId) => ref.watch(catalogRepositoryProvider).fetchClasses(branchId),
);

final branchTrainersProvider = FutureProvider.family<List<Trainer>, String>(
  (ref, branchId) =>
      ref.watch(catalogRepositoryProvider).fetchTrainers(branchId),
);
