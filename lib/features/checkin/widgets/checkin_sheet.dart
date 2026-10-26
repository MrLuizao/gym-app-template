import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/branch.dart';
import '../../../data/repositories/gym_repositories.dart';
import '../../payments/checkout_screen.dart';
import '../../payments/providers/membership_provider.dart';
import 'vip_member_card.dart';

class CheckInSheet extends ConsumerWidget {
  const CheckInSheet({super.key, this.branch});

  final Branch? branch;

  static Future<void> show(BuildContext context, {Branch? branch}) {
    final brand = context.brand;
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: brand.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CheckInSheet(branch: branch),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final memberAsync = ref.watch(memberProvider);
    final member = memberAsync.value;
    final membership = ref.watch(membershipProvider);
    final memberBranch = member?.branchId;
    final isOutOfScope = branch != null &&
        !membership.allBranches &&
        memberBranch != null &&
        branch!.id != memberBranch;

    if (isOutOfScope) {
      return SafeArea(
        child: Padding(
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
              const SizedBox(height: 24),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BrandConfig.logoViolet.withValues(alpha: 0.16),
                  border: Border.all(
                    color: BrandConfig.logoViolet.withValues(alpha: 0.4),
                  ),
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: BrandConfig.logoGradientColors,
                    ).createShader(b),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Sede No Incluida',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu plan ${planNameFor(member?.planId ?? '')} solo permite check-in en tu sede de registro. Para ingresar a ${branch!.name}, actualiza a un plan multisede.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: brand.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'MEJORAR MI PLAN',
                  icon: Icons.stars_rounded,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(
                      MembershipCheckoutScreen.routeName,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: brand.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            if (!membership.allBranches && memberBranch != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: brand.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: brand.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: brand.accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Pase válido exclusivamente en tu sede de registro',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: brand.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
