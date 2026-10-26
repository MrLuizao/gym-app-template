import 'package:flutter/material.dart';

import '../branding/brand.dart';
import '../utils/haptics.dart';
import '../widgets/primary_button.dart';
import '../../data/models/branch.dart';
import '../../features/payments/checkout_screen.dart';

class BranchPlanRestrictedSheet extends StatelessWidget {
  const BranchPlanRestrictedSheet({
    super.key,
    required this.branch,
    this.memberBranchName,
    this.currentPlanName,
  });

  final Branch branch;
  final String? memberBranchName;
  final String? currentPlanName;

  static Future<void> show(
    BuildContext context, {
    required Branch branch,
    String? memberBranchName,
    String? currentPlanName,
  }) {
    AppHaptics.medium();
    final brand = context.brand;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: brand.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BranchPlanRestrictedSheet(
        branch: branch,
        memberBranchName: memberBranchName,
        currentPlanName: currentPlanName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final plan = currentPlanName ?? 'actual';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: brand.cardBorder,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    BrandConfig.logoIndigo.withValues(alpha: 0.22),
                    BrandConfig.logoPink.withValues(alpha: 0.18),
                  ],
                ),
                border: Border.all(
                  color: BrandConfig.logoViolet.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: BrandConfig.logoViolet.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: BrandConfig.logoGradientColors,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Acceso Exclusivo Multisede',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: brand.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Tu plan '),
                  TextSpan(
                    text: plan,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: brand.textPrimary,
                    ),
                  ),
                  const TextSpan(
                    text: ' solo incluye acceso a tu sede de registro',
                  ),
                  if (memberBranchName != null && memberBranchName!.isNotEmpty) ...[
                    const TextSpan(text: ' ('),
                    TextSpan(
                      text: memberBranchName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: brand.accent,
                      ),
                    ),
                    const TextSpan(text: ')'),
                  ],
                  const TextSpan(
                    text:
                        '.\n\nPara entrenar, hacer check-in y marcar como favoritas todas las sedes de RIRHUB como ',
                  ),
                  TextSpan(
                    text: branch.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: brand.textPrimary,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ', actualiza a un plan multisede.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brand.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: brand.cardBorder),
              ),
              child: Column(
                children: [
                  _PerkRow(
                    icon: Icons.all_inclusive_rounded,
                    title: 'Acceso a todas las sedes',
                    subtitle: 'Entrena donde quieras sin restricciones',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _PerkRow(
                    icon: Icons.fitness_center_rounded,
                    title: 'Clases y cupos en cualquier sede',
                    subtitle: 'Reserva tus sesiones en cualquier ubicación',
                  ),
                ],
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
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Entendido',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: brand.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  const _PerkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: BrandConfig.logoViolet.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: BrandConfig.logoViolet),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: brand.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: brand.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
