import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/sponsor_ad.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/gym_repositories.dart';

/// Ads activos — globales (branch_id null) + los de la sede del socio.
final sponsorAdsProvider = StreamProvider<List<SponsorAd>>((ref) {
  final branchId = ref.watch(memberProvider).value?.branchId;
  return ref.watch(catalogRepositoryProvider).watchSponsorAds(branchId);
});
