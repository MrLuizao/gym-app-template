import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/cover_image.dart';
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
    viewportFraction: 0.94,
  );
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients || widget.ads.length < 2) {
        return;
      }
      final next = (_controller.page!.round() + 1) % widget.ads.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
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
    ref.read(adMetricsProvider.notifier).track(ad.id, 'tap');
    Navigator.of(context).pushNamed('/sponsor', arguments: ad);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    if (widget.ads.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 172,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.ads.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final ad = widget.ads[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GestureDetector(
                  onTap: () => _openAd(ad),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CoverImage(
                          url: ad.imageUrl,
                          icon: Icons.campaign_rounded,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withValues(alpha: 0.18),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
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
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.ads.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page ? brand.accent : brand.cardBorder,
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          color: allyColor.withValues(alpha: 0.62),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ad.advertiser.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: onAlly.withValues(alpha: 0.75),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ad.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: onAlly,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ad.subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: onAlly.withValues(alpha: 0.75),
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
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: onAlly.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: onAlly.withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  'Ver oferta',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: onAlly,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
