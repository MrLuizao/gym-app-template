import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../data/repositories/gym_repositories.dart';
import '../application/qr_token_provider.dart';
import 'qr_pass_card.dart';
import 'vip_member_card.dart';

class CheckInSheet extends ConsumerWidget {
  const CheckInSheet({super.key});

  static Future<void> show(BuildContext context) {
    final brand = context.brand;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: brand.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const CheckInSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final memberAsync = ref.watch(memberProvider);
    final token = ref.watch(qrTokenProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: brand.cardBorder,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pase de Acceso',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Presenta este código en recepción para registrar tu ingreso',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 18),
            VipMemberCard(member: memberAsync.value),
            const SizedBox(height: 18),
            QrPassCard(token: token),
          ],
        ),
      ),
    );
  }
}
