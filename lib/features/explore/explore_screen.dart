import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/providers/branch_providers.dart';
import '../home/providers/favorite_branches_provider.dart';
import '../home/widgets/branch_card.dart';
import '../home/widgets/overall_occupancy_banner.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesProvider);
    final favorites = ref.watch(favoriteBranchesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        Text('Explorar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'El pulso de Capital Fitness en tiempo real',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        const OverallOccupancyBanner(),
        const SizedBox(height: 26),
        Text('Sedes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Toca el corazón para guardar tus sedes favoritas',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        branchesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No pudimos cargar las sedes: $error',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          data: (branches) => Column(
            children: [
              for (var i = 0; i < branches.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BranchCard(
                    branch: branches[i],
                    isFavorite: favorites.contains(branches[i].id),
                    onToggleFavorite: () => ref
                        .read(favoriteBranchesProvider.notifier)
                        .toggle(branches[i].id),
                    onTap: () => Navigator.of(context).pushNamed(
                      '/branch',
                      arguments: branches[i],
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 120 + i * 100))
                      .fadeIn(duration: const Duration(milliseconds: 420))
                      .slideY(
                        begin: 0.06,
                        end: 0,
                        duration: const Duration(milliseconds: 480),
                        curve: Curves.easeOutCubic,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
