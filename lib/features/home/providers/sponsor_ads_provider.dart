import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/sponsor_ad.dart';
import '../../../data/repositories/catalog_repository.dart';

final sponsorAdsProvider = StreamProvider<List<SponsorAd>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchSponsorAds();
});
