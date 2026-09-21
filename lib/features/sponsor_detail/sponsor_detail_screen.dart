import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/models/sponsor_ad.dart';

class SponsorDetailScreen extends StatefulWidget {
  const SponsorDetailScreen({super.key, required this.ad});

  static const routeName = '/sponsor';

  final SponsorAd ad;

  @override
  State<SponsorDetailScreen> createState() => _SponsorDetailScreenState();
}

class _SponsorDetailScreenState extends State<SponsorDetailScreen> {
  int _photoIndex = 0;

  Future<void> _open(Uri uri) async {
    // TODO(Firebase): POST /ads/{id}/track {event: 'tap'} con el destino
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openMap() {
    final ad = widget.ad;
    if (!ad.hasLocation) return;
    final brand = context.brand;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: brand.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
              const SizedBox(height: 14),
              _MapAppOption(
                icon: Icons.navigation_rounded,
                label: 'Waze',
                detail: 'Navegación con tráfico en vivo',
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
                detail: 'Abrir en el mapa',
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
    final gallery = ad.photos.isNotEmpty
        ? ad.photos
        : [if (ad.imageUrl != null) ad.imageUrl!];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: brand.background,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.35),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (gallery.isEmpty)
                    const CoverImage(icon: Icons.campaign_rounded)
                  else
                    PageView.builder(
                      itemCount: gallery.length,
                      onPageChanged: (index) =>
                          setState(() => _photoIndex = index),
                      itemBuilder: (_, index) => CoverImage(
                        url: gallery[index],
                        icon: Icons.campaign_rounded,
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          brand.background.withValues(alpha: 0.96),
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                  if (gallery.length > 1)
                    Positioned(
                      right: 16,
                      bottom: 74,
                      child: Row(
                        children: [
                          for (var i = 0; i < gallery.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _photoIndex
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BadgeChip(
                          label: 'PUBLICIDAD · ${ad.badge}',
                          color: brand.accent,
                          icon: Icons.campaign_rounded,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ad.advertiser,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: -0.8,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: brand.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: brand.accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: brand.accent,
                          ),
                        ),
                        if (ad.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            ad.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (ad.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('SOBRE ${ad.advertiser.toUpperCase()}'),
                    const SizedBox(height: 8),
                    Text(
                      ad.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  if (ad.phone.isNotEmpty || ad.socials.whatsapp.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('CONTACTO'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (ad.phone.isNotEmpty)
                          Expanded(
                            child: _ContactButton(
                              icon: Icons.call_rounded,
                              label: 'Llamar',
                              detail: ad.phone,
                              onTap: _call,
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
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (!ad.socials.isEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionTitle('REDES SOCIALES'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (ad.socials.instagram.isNotEmpty)
                          _SocialChip(
                            icon: Icons.camera_alt_rounded,
                            label: 'Instagram',
                            onTap: () => _openUrl(ad.socials.instagram),
                          ),
                        if (ad.socials.facebook.isNotEmpty)
                          _SocialChip(
                            icon: Icons.facebook_rounded,
                            label: 'Facebook',
                            onTap: () => _openUrl(ad.socials.facebook),
                          ),
                        if (ad.socials.tiktok.isNotEmpty)
                          _SocialChip(
                            icon: Icons.music_note_rounded,
                            label: 'TikTok',
                            onTap: () => _openUrl(ad.socials.tiktok),
                          ),
                        if (ad.socials.website.isNotEmpty)
                          _SocialChip(
                            icon: Icons.language_rounded,
                            label: 'Sitio web',
                            onTap: () => _openUrl(ad.socials.website),
                          ),
                      ],
                    ),
                  ],
                                    if (ad.address.isNotEmpty || ad.hasLocation) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('UBICACIÓN'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: brand.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: brand.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ad.hasLocation) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                height: 150,
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter:
                                        LatLng(ad.lat!, ad.lng!),
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
                                          'com.prototipo.gym',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(ad.lat!, ad.lng!),
                                          width: 36,
                                          height: 36,
                                          child: Icon(
                                            Icons.location_on_rounded,
                                            size: 36,
                                            color: brand.accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (ad.address.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  size: 16,
                                  color: brand.accent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ad.address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (ad.hasLocation) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _openMap,
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: brand.accent,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.directions_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'CÓMO LLEGAR',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                          color: Colors.white,
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
        color: Colors.white.withValues(alpha: 0.5),
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
  });

  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: brand.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brand.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: brand.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: brand.accent),
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
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.4),
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
  });

  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: brand.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brand.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: brand.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.5),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: brand.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: brand.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: brand.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
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
