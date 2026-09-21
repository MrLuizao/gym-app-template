import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brand.dart';
import 'brands.dart';

final activeBrandProvider = Provider<BrandConfig>((ref) => capitalFitness);
