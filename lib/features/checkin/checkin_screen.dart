import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/gym_repositories.dart';
import 'application/qr_token_provider.dart';
import 'widgets/qr_pass_card.dart';
import 'widgets/vip_member_card.dart';

class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberProvider);
    final token = ref.watch(qrTokenProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        Text('Pase de Acceso', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Presenta este código en recepción para registrar tu ingreso',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        VipMemberCard(member: memberAsync.value),
        const SizedBox(height: 20),
        QrPassCard(token: token),
      ],
    );
  }
}
