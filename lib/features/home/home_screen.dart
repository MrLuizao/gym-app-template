import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/skeleton_box.dart';
import '../checkin/widgets/checkin_sheet.dart';
import '../trainers/providers/following_trainers_provider.dart';
import '../trainers/trainer_profile_screen.dart';
import 'providers/branch_providers.dart';
import 'providers/favorite_branches_provider.dart';
import 'providers/sponsor_ads_provider.dart';
import 'widgets/branch_card.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/home_header.dart';
import 'widgets/sponsor_carousel.dart';
import 'widgets/weekly_summary_card.dart';
import '../shell/bottom_nav_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        const HomeHeader(),
        const SizedBox(height: 22),
        const WeeklySummarySection()
            .animate(delay: const Duration(milliseconds: 60))
            .fadeIn(duration: const Duration(milliseconds: 420))
            .slideY(
              begin: 0.06,
              end: 0,
              duration: const Duration(milliseconds: 480),
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 16),
        const _SponsorsSection()
            .animate(delay: const Duration(milliseconds: 100))
            .fadeIn(duration: const Duration(milliseconds: 420))
            .slideY(
              begin: 0.06,
              end: 0,
              duration: const Duration(milliseconds: 480),
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 24),
        // const GoalProgressSection()
        //     .animate(delay: const Duration(milliseconds: 140))
        //     .fadeIn(duration: const Duration(milliseconds: 420))
        //     .slideY(
        //       begin: 0.06,
        //       end: 0,
        //       duration: const Duration(milliseconds: 480),
        //       curve: Curves.easeOutCubic,
        //     ),
        // const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text('Mi sede favorita',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(bottomNavIndexProvider.notifier).go(1),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        branchesAsync.when(
          loading: () => const Column(
            children: [
              _SkeletonCard(),
              SizedBox(height: 16),
              _SkeletonCard(),
            ],
          ),
          error: (error, _) => _ErrorCard(
            message: '$error',
            onRetry: () => ref.invalidate(branchesProvider),
          ),
          data: (branches) {
            final favorites = ref.watch(favoriteBranchesProvider);
            final favoriteBranches = branches
                .where((branch) => favorites.contains(branch.id))
                .toList();
            if (favoriteBranches.isEmpty) {
              return _EmptyFavoritesCard(
                onTap: () =>
                    ref.read(bottomNavIndexProvider.notifier).go(1),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < favoriteBranches.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        BranchCard(
                          branch: favoriteBranches[i],
                          onTap: () => Navigator.of(context).pushNamed(
                            '/branch',
                            arguments: favoriteBranches[i],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _BranchCheckInButton(
                          branchName: favoriteBranches[i].name,
                          onTap: () => CheckInSheet.show(context),
                        ),
                      ],
                    )
                        .animate(delay: Duration(milliseconds: 140 + i * 100))
                        .fadeIn(duration: const Duration(milliseconds: 420))
                        .slideY(
                          begin: 0.07,
                          end: 0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                        ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 26),
        const _MyTrainersSection(),
      ],
    );
  }
}

class _SponsorsSection extends ConsumerWidget {
  const _SponsorsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(sponsorAdsProvider);
    return adsAsync.maybeWhen(
      data: (ads) {
        if (ads.isEmpty) return const SizedBox.shrink();
        // TODO(Firebase): registrar impresión por anuncio visible
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nuestros aliados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  'PUBLICIDAD',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        color: Theme.of(context).dividerColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SponsorCarousel(ads: ads),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _MyTrainersSection extends ConsumerWidget {
  const _MyTrainersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final followed = ref.watch(followedTrainersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mis entrenadores', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (followed.isEmpty)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                ref.read(bottomNavIndexProvider.notifier).go(1),
            child: AppCard(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          brand.accent.withValues(alpha: 0.22),
                          brand.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.sports_rounded,
                      size: 40,
                      color: brand.accent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Aún no sigues a ningún entrenador',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toca aquí para explorar tu sede, abrir el perfil de un '
                    'entrenador y tocar "Seguir" para verlo aquí.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EXPLORAR SEDES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: brand.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: brand.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: followed.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final trainer = followed[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    TrainerProfileScreen.routeName,
                    arguments: trainer,
                  ),
                  child: Container(
                    width: 152,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: brand.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: brand.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: brand.accent.withValues(alpha: 0.55),
                              width: 1.6,
                            ),
                          ),
                          child: ClipOval(
                            child: CoverImage(
                              url: trainer.photoUrl,
                              icon: Icons.person_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trainer.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: brand.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trainer.specialty,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: brand.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        BadgeChip(
                          label: 'SIGUIENDO',
                          color: brand.accent,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyFavoritesCard extends StatelessWidget {
  const _EmptyFavoritesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppCard(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    brand.accent.withValues(alpha: 0.22),
                    brand.accent.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 40,
                color: brand.accent,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Aún no tienes sedes favoritas',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Toca aquí para explorar las sedes y marca tu favorita '
              'con el corazón para tenerla siempre a mano.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EXPLORAR SEDES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: brand.accent,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: brand.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return AppCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 192,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SkeletonBox(
                width: 120,
                height: 14,
                radius: 99,
              ).animate(onPlay: (c) => c.repeat()).shimmer(
                    duration: const Duration(milliseconds: 1500),
                    colors: [brand.surface, brand.cardBorder, brand.surface],
                  ),
              const SizedBox(height: 10),
              SkeletonBox(
                height: 6,
                radius: 99,
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                    duration: const Duration(milliseconds: 1500),
                    colors: [brand.surface, brand.cardBorder, brand.surface],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return AppCard(
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: brand.textSecondary, size: 30),
          const SizedBox(height: 10),
          Text(
            'No se pudo cargar el aforo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _BranchCheckInButton extends StatelessWidget {
  const _BranchCheckInButton({required this.branchName, required this.onTap});

  final String branchName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: brand.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: brand.accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 16,
              color: brand.accent,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'CHECK-IN · ${branchName.toUpperCase()}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: brand.accent,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
