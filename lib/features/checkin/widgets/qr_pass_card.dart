import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/app_card.dart';
import '../application/qr_token_provider.dart';

class QrPassCard extends StatelessWidget {
  const QrPassCard({super.key, required this.token});

  final QrToken token;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
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
                    'CÓDIGO DE INGRESO',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(letterSpacing: 1.6),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Válido por 45 s · un solo uso',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              _CountdownRing(token: token),
            ],
          ),
          const SizedBox(height: 18),
          Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: QrImageView(
                  data: token.payload,
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
              )
              .animate()
              .scale(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: const Duration(milliseconds: 260)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: brand.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 16,
                  color: brand.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ID ${token.memberId} · FIRMA ${token.signaturePreview}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: brand.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownRing extends StatefulWidget {
  const _CountdownRing({required this.token});

  final QrToken token;

  @override
  State<_CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<_CountdownRing> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final ratio = widget.token.remainingRatio(_now);
    final seconds = widget.token.remainingSeconds(_now);
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: ratio,
            strokeWidth: 5,
            strokeCap: StrokeCap.round,
            color: brand.accent,
            backgroundColor: brand.cardBorder,
          ),
          Text(
            '${seconds}s',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: brand.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
