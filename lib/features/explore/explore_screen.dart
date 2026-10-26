import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/ambient_glow.dart';
import '../../core/widgets/branch_plan_restricted_sheet.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../data/models/branch.dart';
import '../../data/repositories/gym_repositories.dart';
import '../home/providers/branch_providers.dart';
import '../home/providers/favorite_branches_provider.dart';
import '../home/widgets/branch_card.dart';
import '../payments/providers/membership_provider.dart';

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

  void _selectFilter(_ExploreFilter filter) {
    if (_filter == filter) return;
    AppHaptics.selection();
    setState(() => _filter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(branchesProvider);
    final favorites = ref.watch(favoriteBranchesProvider);
    final member = ref.watch(memberProvider).value;
    final membership = ref.watch(membershipProvider);
    final memberBranch = member?.branchId;
    final planAllBranches = membership.allBranches;
    final branchesList = branchesAsync.value ?? const <Branch>[];
    final memberBranchName = memberBranch != null
        ? branchesList
            .where((b) => b.id == memberBranch)
            .firstOrNull
            ?.name
        : null;
    final currentPlanName = planNameFor(member?.planId ?? '');

    return Stack(
      children: [
        const AmbientTopGlow(),
        ListView(
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
                  onTap: () => _selectFilter(_ExploreFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'ABIERTAS',
                  selected: _filter == _ExploreFilter.open,
                  onTap: () => _selectFilter(_ExploreFilter.open),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'MENOR AFORO',
                  selected: _filter == _ExploreFilter.leastBusy,
                  onTap: () => _selectFilter(_ExploreFilter.leastBusy),
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
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
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
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  child: visible.isEmpty
                      ? Padding(
                          key: const ValueKey('empty'),
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No hay sedes abiertas en este momento',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : Column(
                          key: ValueKey(_filter),
                          children: [
                            for (var i = 0; i < visible.length; i++) ...[
                              Builder(
                                builder: (context) {
                                  final isOutOfScope = !planAllBranches &&
                                      memberBranch != null &&
                                      visible[i].id != memberBranch;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child:
                                        BranchCard(
                                              branch: visible[i],
                                              isFavorite: favorites.contains(
                                                visible[i].id,
                                              ),
                                              outOfScope: isOutOfScope,
                                              onToggleFavorite: () {
                                                if (isOutOfScope) {
                                                  BranchPlanRestrictedSheet.show(
                                                    context,
                                                    branch: visible[i],
                                                    memberBranchName:
                                                        memberBranchName,
                                                    currentPlanName:
                                                        currentPlanName,
                                                  );
                                                } else {
                                                  ref
                                                      .read(
                                                        favoriteBranchesProvider
                                                            .notifier,
                                                      )
                                                      .toggle(visible[i].id);
                                                }
                                              },
                                              onTap: () => Navigator.of(context)
                                                  .pushNamed(
                                                    '/branch',
                                                    arguments: visible[i],
                                                  ),
                                            )
                                            .animate(
                                              delay: Duration(
                                                milliseconds: 70 + i * 75,
                                              ),
                                            )
                                            .fadeIn(
                                              duration: const Duration(
                                                milliseconds: 360,
                                              ),
                                            )
                                            .slideY(
                                              begin: 0.05,
                                              curve: Curves.easeOutCubic,
                                            ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                );
              },
            ),
          ],
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
    final fg = selected
        ? brand.readableOn(brand.accent)
        : brand.textSecondary;
    return PressableScale(
      onTap: onTap,
      enableHaptic: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? brand.accent : brand.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? brand.accent : brand.cardBorder,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: brand.accent.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
            color: fg,
          ),
        ),
      ),
    );
  }
}
