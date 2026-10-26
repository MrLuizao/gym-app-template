import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/cover_image.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/models/sponsor_ad.dart';
import '../../metrics/ad_metrics_provider.dart';

class SponsorCarousel extends ConsumerStatefulWidget {
  const SponsorCarousel({super.key, required this.ads});

  final List<SponsorAd> ads;

  @override
  ConsumerState<SponsorCarousel> createState() => _SponsorCarouselState();
}

class _SponsorCarouselState extends ConsumerState<SponsorCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: 0.92,
  );
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.ads.isNotEmpty) {
        ref
            .read(adMetricsProvider.notifier)
            .track(widget.ads.first.id, 'impression');
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients || widget.ads.length < 2) {
        return;
      }
      final next = (_controller.page!.round() + 1) % widget.ads.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _openAd(SponsorAd ad) {
    AppHaptics.medium();
    ref.read(adMetricsProvider.notifier).track(ad.id, 'tap');
    Navigator.of(context).pushNamed('/sponsor', arguments: ad);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    if (widget.ads.isEmpty) return const SizedBox.shrink();

    final safeIndex = _page.clamp(0, widget.ads.length - 1);
    final activeAd = widget.ads[safeIndex];
    final activeColor = brand.allyAccent(activeAd.brandColor);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Halo ambiental dinámico con el color de marca del aliado activo
            Positioned(
              top: -18,
              bottom: -18,
              left: 12,
              right: 12,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.95,
                      colors: [
                        activeColor.withValues(alpha: 0.26),
                        activeColor.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 216,
              child: PageView.builder(
                controller: _controller,
                clipBehavior: Clip.none,
                itemCount: widget.ads.length,
                onPageChanged: (page) {
                  setState(() => _page = page);
                  if (page >= 0 && page < widget.ads.length) {
                    ref
                        .read(adMetricsProvider.notifier)
                        .track(widget.ads[page].id, 'impression');
                  }
                },
                itemBuilder: (context, index) {
                  final ad = widget.ads[index];
                  final allyColor = brand.allyAccent(ad.brandColor);
                  final onAlly = brand.readableOn(allyColor);
                  final isCurrent = index == safeIndex;

                  return AnimatedScale(
                    scale: isCurrent ? 1.0 : 0.94,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: PressableScale(
                        pressedScale: 0.97,
                        onTap: () => _openAd(ad),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: isCurrent
                                  ? allyColor.withValues(alpha: 0.65)
                                  : brand.cardBorder,
                              width: isCurrent ? 1.6 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isCurrent
                                    ? allyColor.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.25),
                                blurRadius: isCurrent ? 24 : 12,
                                spreadRadius: isCurrent ? 1 : 0,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.5),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CoverImage(
                                  url: ad.imageUrl,
                                  icon: Icons.storefront_rounded,
                                ),
                                // Viñeta cinematográfica superior e inferior
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0.0, 0.35, 0.62, 1.0],
                                      colors: [
                                        Colors.black.withValues(alpha: 0.55),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.35),
                                        Colors.black.withValues(alpha: 0.88),
                                      ],
                                    ),
                                  ),
                                ),
                                // Tope: Sello del comercio + Badge de descuento/beneficio
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  right: 12,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 10,
                                              sigmaY: 10,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Color.alphaBlend(
                                                  allyColor.withValues(
                                                    alpha: 0.48,
                                                  ),
                                                  Colors.black.withValues(
                                                    alpha: 0.55,
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(99),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.24),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.verified_rounded,
                                                    size: 13,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Flexible(
                                                    child: Text(
                                                      ad.advertiser
                                                          .toUpperCase(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        letterSpacing: 1.1,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (ad.badge.trim().isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 11,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: allyColor,
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: allyColor.withValues(
                                                  alpha: 0.45,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.local_offer_rounded,
                                                size: 11,
                                                color: onAlly,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                ad.badge.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.8,
                                                  color: onAlly,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Franja inferior con cristal esmerilado y CTA vibrante
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: _AllyStrip(ad: ad),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Indicadores dinámicos con píldora expandible y contador
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.ads.length; i++)
              GestureDetector(
                onTap: () {
                  AppHaptics.selection();
                  _controller.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  width: i == safeIndex ? 24 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: i == safeIndex
                        ? activeColor
                        : brand.cardBorder.withValues(alpha: 0.7),
                    boxShadow: i == safeIndex
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AllyStrip extends StatelessWidget {
  const _AllyStrip({required this.ad});

  final SponsorAd ad;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final allyColor = brand.allyAccent(ad.brandColor);
    final onAlly = brand.readableOn(allyColor);
    final cta = ad.ctaLabel.trim().isNotEmpty
        ? ad.ctaLabel.trim()
        : 'Ver beneficio';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: 0.72),
                allyColor.withValues(alpha: 0.36),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: allyColor.withValues(alpha: 0.38),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ad.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.2,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ad.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: allyColor,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: allyColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cta,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: onAlly,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: onAlly,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
