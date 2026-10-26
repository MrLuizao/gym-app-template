import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/models/coupon.dart';
import '../../payments/providers/membership_provider.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    required this.coupon,
    this.locked = false,
    this.onTap,
  });

  final Coupon coupon;
  final bool locked;
  final VoidCallback? onTap;

  String get _plansLabel => coupon.planIds.contains('ALL')
      ? 'TODOS'
      : coupon.planIds.map(planNameFor).join(' · ');

  bool get _isActive =>
      coupon.expiresAt == null || coupon.expiresAt!.isAfter(DateTime.now());

  String _expiryLabel() {
    final expires = coupon.expiresAt;
    if (expires == null) return 'Vigente';
    final days = expires.difference(DateTime.now()).inDays;
    if (days <= 0) return 'Vence hoy';
    return 'Vence en ${days}d';
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final accent = locked ? brand.textSecondary : brand.accent;
    final card = Container(
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: !locked && _isActive
              ? brand.accent.withValues(alpha: 0.28)
              : brand.cardBorder,
        ),
        boxShadow: !locked && _isActive
            ? [
                BoxShadow(
                  color: brand.accent.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 92,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coupon.badge,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CUPÓN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: brand.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 14),
              color: brand.cardBorder,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: brand.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      coupon.description,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: brand.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: brand.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: brand.cardBorder),
                          ),
                          child: Text(
                            coupon.code,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 0.6,
                              color: accent,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _expiryLabel(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: brand.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: locked
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: brand.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 88),
                            child: Text(
                              _plansLabel,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: brand.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (_isActive
                                      ? brand.occupancyLow
                                      : brand.occupancyHigh)
                                  .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color:
                                (_isActive
                                        ? brand.occupancyLow
                                        : brand.occupancyHigh)
                                    .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          _isActive ? 'ACTIVO' : 'VENCIDO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: _isActive
                                ? brand.occupancyLow
                                : brand.occupancyHigh,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (locked || onTap == null) {
      return Opacity(opacity: locked ? 0.55 : 1, child: card);
    }

    return PressableScale(
      enableHaptic: true,
      onTap: onTap,
      pressedScale: 0.975,
      child: card,
    );
  }
}
