import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/firebase/app_bootstrap.dart';

Future<void> main() async {
  await AppBootstrap.initialize();
  runApp(const ProviderScope(child: MembersApp()));
}
