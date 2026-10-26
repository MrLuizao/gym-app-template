import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/branding/brand.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../data/models/coupon.dart';
import '../../data/models/sponsor_ad.dart';
import '../metrics/ad_metrics_provider.dart';
import '../promotions/providers/promotions_providers.dart';
import '../promotions/widgets/coupon_qr_sheet.dart';

class SponsorDetailScreen extends ConsumerStatefulWidget {
  const SponsorDetailScreen({super.key, required this.ad});

  static const routeName = '/sponsor';

  final SponsorAd ad;

  @override
  ConsumerState<SponsorDetailScreen> createState() =>
      _SponsorDetailScreenState();
}

class _SponsorDetailScreenState extends ConsumerState<SponsorDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  late final PageController _galleryController = PageController();
  int _photoIndex = 0;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted) return;
    final next = _scrollController.offset.clamp(0.0, 260.0);
    if ((next - _scrollOffset).abs() > 2) {
      setState(() => _scrollOffset = next);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  Future<void> _open(Uri uri) async {
    AppHaptics.light();
    ref.read(adMetricsProvider.notifier).track(widget.ad.id, 'tap');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openMap() {
    final ad = widget.ad;
    if (!ad.hasLocation) return;
    AppHaptics.medium();
    final brand = context.brand;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: brand.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cómo llegar a ${ad.advertiser}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (ad.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ad.address,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _MapAppOption(
                icon: Icons.navigation_rounded,
                label: 'Waze',
                detail: 'Navegación con tráfico en vivo',
                accent: context.brand.allyAccent(widget.ad.brandColor),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _open(
                    Uri.parse(
                      'https://waze.com/ul?ll=${ad.lat},${ad.lng}&navigate=yes',
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _MapAppOption(
                icon: Icons.map_rounded,
                label: 'Google Maps',
                detail: 'Abrir ruta en el mapa',
                accent: context.brand.allyAccent(widget.ad.brandColor),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _open(
                    Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${ad.lat},${ad.lng}',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _call() {
    final phone = widget.ad.phone.replaceAll(RegExp(r'[^+\d]'), '');
    if (phone.isEmpty) return;
    _open(Uri.parse('tel:$phone'));
  }

  void _openWhatsapp() {
    final phone = widget.ad.socials.whatsapp.replaceAll(RegExp(r'[^\d]'), '');
    if (phone.isEmpty) return;
    _open(Uri.parse('https://wa.me/$phone'));
  }

  void _openUrl(String url) {
    if (url.isEmpty) return;
    _open(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final ad = widget.ad;
    final ally = brand.allyAccent(ad.brandColor);
    final onAlly = brand.readableOn(ally);
    final gallery = ad.photos.isNotEmpty
        ? ad.photos
        : [if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty) ad.imageUrl!];

    // Progreso de colapso tipo Spotify (0.0 expandido -> 1.0 colapsado)
    final collapseT = ((_scrollOffset - 140) / 90).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: brand.background,
      body: Stack(
        children: [
          // Luz ambiental superior inmersiva con el color de marca del aliado
          Positioned(
            top: -80 - (_scrollOffset * 0.35),
            left: -60,
            right: -60,
            height: 460,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.4),
                    radius: 1.05,
                    colors: [
                      ally.withValues(alpha: 0.34),
                      ally.withValues(alpha: 0.12),
                      brand.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: Color.lerp(
                  Colors.transparent,
                  brand.surface.withValues(alpha: 0.94),
                  collapseT,
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: PressableScale(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.45),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                title: IgnorePointer(
                  ignoring: collapseT < 0.5,
                  child: Opacity(
                    opacity: collapseT,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ad.advertiser,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (ad.badge.trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ally,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              ad.badge.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: onAlly,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (gallery.isEmpty)
                        const CoverImage(icon: Icons.storefront_rounded)
                      else
                        PageView.builder(
                          controller: _galleryController,
                          itemCount: gallery.length,
                          onPageChanged: (index) {
                            AppHaptics.selection();
                            setState(() => _photoIndex = index);
                          },
                          itemBuilder: (_, index) => CoverImage(
                            url: gallery[index],
                            icon: Icons.storefront_rounded,
                          ),
                        ),
                      // Degradado tipo portada de playlist de Spotify que se funde con el fondo
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.35, 0.72, 1.0],
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                              brand.background.withValues(alpha: 0.72),
                              brand.background,
                            ],
                          ),
                        ),
                      ),
                      // Resplandor inferior del color del aliado
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 150,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  ally.withValues(alpha: 0.22),
                                  brand.background,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Contador de fotos interactivo en esquina superior derecha
                      if (gallery.length > 1)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 10,
                          right: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.photo_library_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${_photoIndex + 1}/${gallery.length}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Cabecera hero tipo artista/playlist de Spotify
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color.alphaBlend(
                                          ally.withValues(alpha: 0.55),
                                          Colors.black.withValues(alpha: 0.55),
                                        ),
                                        borderRadius: BorderRadius.circular(99),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.28,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'ALIADO OFICIAL',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.1,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (ad.badge.trim().isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ally,
                                      borderRadius: BorderRadius.circular(99),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ally.withValues(alpha: 0.45),
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
                                const Spacer(),
                                if (gallery.length > 1)
                                  Row(
                                    children: [
                                      for (var i = 0; i < gallery.length; i++)
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          width: i == _photoIndex ? 16 : 5,
                                          height: 5,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
                                            color: i == _photoIndex
                                                ? ally
                                                : Colors.white.withValues(
                                                    alpha: 0.35,
                                                  ),
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ad.advertiser,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                height: 1.04,
                                letterSpacing: -0.9,
                                color: Colors.white,
                              ),
                            ),
                            if (ad.address.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place_rounded,
                                    size: 13,
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      ad.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de acciones rápidas estilo Spotify (iconos a la izq + botón hero a la der)
                      _SpotifyActionDeck(
                            ad: ad,
                            allyColor: ally,
                            onCall: ad.phone.isNotEmpty ? _call : null,
                            onWhatsapp: ad.socials.whatsapp.isNotEmpty
                                ? _openWhatsapp
                                : null,
                            onDirections: ad.hasLocation ? _openMap : null,
                          )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 350))
                          .slideY(
                            begin: 0.05,
                            end: 0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 18),
                      // Tarjeta protagonista del beneficio (Ticket de beneficio)
                      _BenefitSpotlightCard(ad: ad, allyColor: ally)
                          .animate(delay: const Duration(milliseconds: 70))
                          .fadeIn(duration: const Duration(milliseconds: 380))
                          .slideY(
                            begin: 0.05,
                            end: 0,
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                          ),
                      // Miniaturas de galería cuando el aliado tiene varias fotos
                      if (gallery.length > 1) ...[
                        const SizedBox(height: 22),
                        const _SectionTitle('GALERÍA'),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 68,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: gallery.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final selected = index == _photoIndex;
                              return PressableScale(
                                onTap: () {
                                  AppHaptics.selection();
                                  _galleryController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOutCubic,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: 92,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected ? ally : brand.cardBorder,
                                      width: selected ? 2 : 1,
                                    ),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: ally.withValues(
                                                alpha: 0.35,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CoverImage(
                                      url: gallery[index],
                                      icon: Icons.photo_rounded,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (ad.description.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _SectionTitle('ACERCA DE ${ad.advertiser.toUpperCase()}'),
                        const SizedBox(height: 10),
                        Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: brand.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: brand.cardBorder),
                              ),
                              child: Text(
                                ad.description,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.55,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                              ),
                            )
                            .animate(delay: const Duration(milliseconds: 120))
                            .fadeIn(duration: const Duration(milliseconds: 380))
                            .slideY(
                              begin: 0.05,
                              end: 0,
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.easeOutCubic,
                            ),
                      ],
                      if (ad.phone.isNotEmpty ||
                          ad.socials.whatsapp.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle('CONTACTO DIRECTO'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (ad.phone.isNotEmpty)
                              Expanded(
                                child: _ContactButton(
                                  icon: Icons.call_rounded,
                                  label: 'Llamar',
                                  detail: ad.phone,
                                  onTap: _call,
                                  accent: ally,
                                ),
                              ),
                            if (ad.phone.isNotEmpty &&
                                ad.socials.whatsapp.isNotEmpty)
                              const SizedBox(width: 10),
                            if (ad.socials.whatsapp.isNotEmpty)
                              Expanded(
                                child: _ContactButton(
                                  icon: Icons.chat_rounded,
                                  label: 'WhatsApp',
                                  detail: ad.socials.whatsapp,
                                  onTap: _openWhatsapp,
                                  accent: ally,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (!ad.socials.isEmpty) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle('REDES Y SITIO WEB'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (ad.socials.instagram.isNotEmpty)
                              _SocialChip(
                                icon: Icons.camera_alt_rounded,
                                label: 'Instagram',
                                onTap: () => _openUrl(ad.socials.instagram),
                                accent: ally,
                              ),
                            if (ad.socials.facebook.isNotEmpty)
                              _SocialChip(
                                icon: Icons.facebook_rounded,
                                label: 'Facebook',
                                onTap: () => _openUrl(ad.socials.facebook),
                                accent: ally,
                              ),
                            if (ad.socials.tiktok.isNotEmpty)
                              _SocialChip(
                                icon: Icons.music_note_rounded,
                                label: 'TikTok',
                                onTap: () => _openUrl(ad.socials.tiktok),
                                accent: ally,
                              ),
                            if (ad.socials.website.isNotEmpty)
                              _SocialChip(
                                icon: Icons.language_rounded,
                                label: 'Sitio web',
                                onTap: () => _openUrl(ad.socials.website),
                                accent: ally,
                              ),
                            if (ad.socials.otherUrl.isNotEmpty)
                              _SocialChip(
                                icon: Icons.link_rounded,
                                label: ad.socials.otherLabel.isNotEmpty
                                    ? ad.socials.otherLabel
                                    : 'Enlace',
                                onTap: () => _openUrl(ad.socials.otherUrl),
                                accent: ally,
                              ),
                          ],
                        ),
                      ],
                      if (ad.address.isNotEmpty || ad.hasLocation) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle('UBICACIÓN'),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: brand.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: brand.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (ad.hasLocation) ...[
                                PressableScale(
                                  pressedScale: 0.985,
                                  onTap: _openMap,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: SizedBox(
                                      height: 165,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          FlutterMap(
                                            options: MapOptions(
                                              initialCenter: LatLng(
                                                ad.lat!,
                                                ad.lng!,
                                              ),
                                              initialZoom: 15.5,
                                              interactionOptions:
                                                  const InteractionOptions(
                                                    flags: InteractiveFlag.none,
                                                  ),
                                            ),
                                            children: [
                                              TileLayer(
                                                urlTemplate:
                                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                userAgentPackageName:
                                                    'com.rirhub.app',
                                              ),
                                              MarkerLayer(
                                                markers: [
                                                  Marker(
                                                    point: LatLng(
                                                      ad.lat!,
                                                      ad.lng!,
                                                    ),
                                                    width: 44,
                                                    height: 44,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: ally,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                  alpha: 0.35,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  3,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          size: 22,
                                                          color: onAlly,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.65,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(99),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.touch_app_rounded,
                                                    size: 11,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Toca para navegar',
                                                    style: TextStyle(
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (ad.address.isNotEmpty)
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: ally.withValues(alpha: 0.38),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: ally.withValues(alpha: 0.65),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.place_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        ad.address,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (ad.hasLocation) ...[
                                const SizedBox(height: 12),
                                PressableScale(
                                  onTap: _openMap,
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: ally,
                                      borderRadius: BorderRadius.circular(99),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ally.withValues(alpha: 0.35),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.directions_rounded,
                                            size: 17,
                                            color: onAlly,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'CÓMO LLEGAR',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                              color: onAlly,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barra de acciones inspirada en la cabecera de playlists de Spotify:
/// botones circulares de acción rápida a la izquierda y el CTA principal
/// de canje/generación de cupón brillante a la derecha.
class _SpotifyActionDeck extends ConsumerWidget {
  const _SpotifyActionDeck({
    required this.ad,
    required this.allyColor,
    this.onCall,
    this.onWhatsapp,
    this.onDirections,
  });

  final SponsorAd ad;
  final Color allyColor;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsapp;
  final VoidCallback? onDirections;

  static const _chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  Coupon _buildCoupon(BuildContext context) {
    final random = Random();
    final suffix = List.generate(
      4,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
    return Coupon(
      id: 'coupon-${ad.id}',
      brandId: context.brand.id,
      title: ad.title,
      description: ad.subtitle.isNotEmpty ? ad.subtitle : ad.description,
      badge: ad.badge,
      code: 'ALI-${ad.id.toUpperCase()}-$suffix',
      planIds: const ['ALL'],
      branchId: ad.branchId,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final onAlly = brand.readableOn(allyColor);
    final existing = ref.watch(
      generatedCouponsProvider.select((map) => map[ad.id]),
    );

    return Row(
      children: [
        if (onWhatsapp != null) ...[
          _QuickCircleAction(
            icon: Icons.chat_bubble_rounded,
            tooltip: 'WhatsApp',
            accent: allyColor,
            onTap: onWhatsapp!,
          ),
          const SizedBox(width: 10),
        ],
        if (onCall != null) ...[
          _QuickCircleAction(
            icon: Icons.call_rounded,
            tooltip: 'Llamar',
            accent: allyColor,
            onTap: onCall!,
          ),
          const SizedBox(width: 10),
        ],
        if (onDirections != null) ...[
          _QuickCircleAction(
            icon: Icons.near_me_rounded,
            tooltip: 'Cómo llegar',
            accent: allyColor,
            onTap: onDirections!,
          ),
          const SizedBox(width: 10),
        ],
        const Spacer(),
        PressableScale(
          pressedScale: 0.94,
          onTap: () {
            final coupon =
                existing ??
                ref
                    .read(generatedCouponsProvider.notifier)
                    .generate(ad.id, _buildCoupon(context));
            if (existing == null) {
              AppHaptics.heavy();
              ref.read(adMetricsProvider.notifier).track(ad.id, 'coupon');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  content: const Text(
                    'Cupón generado · encuéntralo en Promociones',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            } else {
              AppHaptics.medium();
            }
            CouponQrSheet.show(context, coupon);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: allyColor,
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                BoxShadow(
                  color: allyColor.withValues(alpha: 0.45),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  existing != null
                      ? Icons.qr_code_2_rounded
                      : Icons.confirmation_num_rounded,
                  size: 19,
                  color: onAlly,
                ),
                const SizedBox(width: 8),
                Text(
                  existing != null ? 'VER MI CUPÓN' : 'OBTENER CUPÓN',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    color: onAlly,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickCircleAction extends StatelessWidget {
  const _QuickCircleAction({
    required this.icon,
    required this.tooltip,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PressableScale(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.alphaBlend(
              accent.withValues(alpha: 0.32),
              brand.surface,
            ),
            border: Border.all(
              color: accent.withValues(alpha: 0.65),
              width: 1.2,
            ),
          ),
          child: Icon(icon, size: 19, color: Colors.white),
        ),
      ),
    );
  }
}

/// Tarjeta destacada del beneficio con estética de boleto VIP y vista
/// rápida del código si el socio ya generó su cupón.
class _BenefitSpotlightCard extends ConsumerWidget {
  const _BenefitSpotlightCard({required this.ad, required this.allyColor});

  final SponsorAd ad;
  final Color allyColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final existing = ref.watch(
      generatedCouponsProvider.select((map) => map[ad.id]),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            allyColor.withValues(alpha: 0.34),
            brand.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: allyColor.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: allyColor.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: allyColor.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'BENEFICIO EXCLUSIVO PARA SOCIOS',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ad.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          if (ad.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              ad.subtitle,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
          if (existing != null) ...[
            const SizedBox(height: 14),
            PressableScale(
              onTap: () {
                Clipboard.setData(ClipboardData(text: existing.code));
                AppHaptics.selection();
                CouponQrSheet.show(context, existing);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    allyColor.withValues(alpha: 0.35),
                    brand.background,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: allyColor.withValues(alpha: 0.7)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code_rounded,
                      size: 19,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TU CUPÓN ACTIVO',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            existing.code,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Mostrar QR ›',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
        color: Colors.white.withValues(alpha: 0.55),
      ),
    );
  }
}

class _MapAppOption extends StatelessWidget {
  const _MapAppOption({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: brand.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.7)),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            accent.withValues(alpha: 0.18),
            brand.surface,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.75)),
              ),
              child: Icon(icon, size: 17, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            accent.withValues(alpha: 0.24),
            brand.surface,
          ),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: accent.withValues(alpha: 0.58)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
