import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/branding/brand.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/models/coupon.dart';

class CouponQrSheet extends StatelessWidget {
  const CouponQrSheet({super.key, required this.coupon});

  final Coupon coupon;

  static Future<void> show(BuildContext context, Coupon coupon) {
    AppHaptics.medium();
    final brand = context.brand;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: brand.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CouponQrSheet(coupon: coupon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
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
                coupon.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Presenta este código en el aliado para canjear tu beneficio',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: QrImageView(
                data: 'gym-coupon:${coupon.code}',
                version: QrVersions.auto,
                size: 214,
                backgroundColor: Colors.white,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: brand.background,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: brand.background,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PressableScale(
              onTap: () {
                Clipboard.setData(ClipboardData(text: coupon.code));
                AppHaptics.selection();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Código copiado al portapapeles'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: brand.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: brand.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      coupon.code,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        letterSpacing: 1.4,
                        color: brand.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.copy_rounded,
                      size: 15,
                      color: brand.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
