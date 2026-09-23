import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../data/models/branch.dart';
import '../home/providers/branch_providers.dart';
import '../home/providers/favorite_branches_provider.dart';
import '../home/widgets/branch_card.dart';

enum _ExploreFilter { all, open, leastBusy }

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  _ExploreFilter _filter = _ExploreFilter.all;

  List<Branch> _apply(List<Branch> branches) {
    return switch (_filter) {
      _ExploreFilter.all => branches,
      _ExploreFilter.open => branches.where((b) => b.isOpen).toList(),
      _ExploreFilter.leastBusy =>
        [...branches]..sort((a, b) {
          if (a.isOpen != b.isOpen) return a.isOpen ? -1 : 1;
          return a.occupancy.compareTo(b.occupancy);
        }),
    };
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(branchesProvider);
    final favorites = ref.watch(favoriteBranchesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        Text(
          'Explorar sedes',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Compara el aforo en vivo y elige a qué sede ir',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _FilterChip(
              label: 'TODAS',
              selected: _filter == _ExploreFilter.all,
              onTap: () => setState(() => _filter = _ExploreFilter.all),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'ABIERTAS',
              selected: _filter == _ExploreFilter.open,
              onTap: () => setState(() => _filter = _ExploreFilter.open),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'MENOR AFORO',
              selected: _filter == _ExploreFilter.leastBusy,
              onTap: () => setState(() => _filter = _ExploreFilter.leastBusy),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Toca el corazón para fijar tu favorita',
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
          data: (branches) {
            final visible = _apply(branches);
            if (visible.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No hay sedes abiertas en este momento',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < visible.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child:
                        BranchCard(
                              branch: visible[i],
                              isFavorite: favorites.contains(visible[i].id),
                              onToggleFavorite: () => ref
                                  .read(favoriteBranchesProvider.notifier)
                                  .toggle(visible[i].id),
                              onTap: () => Navigator.of(
                                context,
                              ).pushNamed('/branch', arguments: visible[i]),
                            )
                            .animate(
                              delay: Duration(milliseconds: 120 + i * 100),
                            )
                            .fadeIn(duration: const Duration(milliseconds: 420))
                            .slideY(
                              begin: 0.06,
                              end: 0,
                              duration: const Duration(milliseconds: 480),
                              curve: Curves.easeOutCubic,
                            ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? brand.accent.withValues(alpha: 0.15)
              : brand.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? brand.accent.withValues(alpha: 0.6)
                : brand.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
            color: selected ? brand.accent : brand.textSecondary,
          ),
        ),
      ),
    );
  }
}
