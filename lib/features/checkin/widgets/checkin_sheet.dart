import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/repositories/gym_repositories.dart';
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
                'Dicta tu número de socio en recepción para registrar tu ingreso',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 18),
            VipMemberCard(member: memberAsync.value),
            const SizedBox(height: 18),
            _MemberNumberCard(number: memberAsync.value?.memberNumber),
          ],
        ),
      ),
    );
  }
}

/// Número de socio protagonista — recepción lo teclea en /checkin.
class _MemberNumberCard extends StatelessWidget {
  const _MemberNumberCard({this.number});

  final String? number;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final display = number ?? '—';
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NÚMERO DE SOCIO',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(letterSpacing: 1.6),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ingreso manual en recepción',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.badge_rounded, size: 22, color: brand.accent),
            ],
          ),
          const SizedBox(height: 18),

          /// QR del número de socio — recepción lo escanea o lo dicta.
          if (number != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: QrImageView(
                data: number!,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: number == null
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: number!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Número copiado'),
                      ),
                    );
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: brand.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: brand.cardBorder),
              ),
              child: Text(
                display,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  fontFamily: 'monospace',
                  color: brand.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Toca para copiar',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: brand.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
