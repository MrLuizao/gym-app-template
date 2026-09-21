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
  testWidgets('el onboarding renderiza la primera slide', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ProviderScope(child: MembersApp()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('ENTRENA\nSIN LÍMITES'), findsOneWidget);
    expect(find.text('Saltar'), findsOneWidget);
    expect(find.text('CONTINUAR'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('el botón central de Check-in navega al Pase de Acceso',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_done': true,
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

    expect(find.text('Inicio'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.qr_code_2_rounded));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pase de Acceso'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('el tab Perfil muestra el perfil del socio', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_done': true,
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

    await tester.tap(find.text('Perfil'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mi membresía'), findsOneWidget);
    expect(find.text('SOCIO Nº CF-00421'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
