import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/glass_icon_button.dart';
import '../../data/models/trainer.dart';
import 'providers/following_trainers_provider.dart';

class TrainerProfileScreen extends ConsumerWidget {
  const TrainerProfileScreen({super.key, required this.trainer});

  static const routeName = '/trainer';

  final Trainer trainer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final following = ref.watch(followingTrainersProvider).contains(trainer.id);
    return Scaffold(
      backgroundColor: brand.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Row(
              children: [
                GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: brand.textPrimary,
                  ),
                ),
                const Spacer(),

                /// Mismo ancho que el GlassIconButton para centrar el título.
                const SizedBox(width: 42),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: CoverImage(
                      url:
                          'https://picsum.photos/seed/cf-trainer-${trainer.id}/800/500',
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: -26,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: CoverImage(
                        url: trainer.photoUrl,
                        icon: Icons.person_rounded,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: brand.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        trainer.specialty,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: brand.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => ref
                      .read(followingTrainersProvider.notifier)
                      .toggle(trainer.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: following ? Colors.transparent : brand.accent,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: following
                            ? brand.accent.withValues(alpha: 0.6)
                            : brand.accent,
                      ),
                    ),
                    child: Text(
                      following ? 'Siguiendo' : 'Seguir',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: following ? brand.accent : brand.background,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: brand.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: brand.cardBorder),
              ),
              child: Row(
                children: [
                  _Stat(label: 'Seguidores', value: '12.1', unit: 'k'),
                  const _VerticalDivider(),
                  _Stat(label: 'Clases', value: '18', unit: 'Set'),
                  _VerticalDivider(),
                  _Stat(label: 'Alumnos', value: '580', unit: ''),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _OfferCard(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Clases Populares',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Ver todas')),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _popularClasses.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _popularClasses[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 160,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://picsum.photos/seed/cf-class-${trainer.id}-$index/400/600',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [brand.surface, brand.background],
                                ),
                              ),
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Entrenamiento',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _popularClasses = <({String title, String tag})>[
  (title: 'Técnica de Pesas', tag: 'Fuerza'),
  (title: 'Piernas Masivas', tag: 'Fuerza'),
  (title: 'Movilidad Total', tag: 'Movilidad'),
];

class _OfferCard extends StatelessWidget {
  const _OfferCard();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: brand.accent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oferta Especial: 10% Off',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    color: brand.background,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Disponible exclusivamente para los primeros 100 socios en unirse.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: brand.background.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 92,
              height: 110,
              child: Image.network(
                'https://picsum.photos/seed/cf-offer/300/400',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(width: 1, height: 40, color: brand.cardBorder);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: brand.textPrimary,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: brand.textSecondary,
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
