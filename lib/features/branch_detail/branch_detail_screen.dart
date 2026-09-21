import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/hourly_forecast_chart.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../data/models/branch.dart';
import 'providers/catalog_providers.dart';
import 'providers/reservation_provider.dart';
import '../checkin/widgets/checkin_sheet.dart';
import '../home/providers/favorite_branches_provider.dart';
import 'widgets/class_detail_sheet.dart';
import 'widgets/class_tile.dart';
import 'widgets/trainer_card.dart';
import '../trainers/trainer_profile_screen.dart';

class BranchDetailScreen extends ConsumerStatefulWidget {
  const BranchDetailScreen({super.key, required this.branch});

  static const routeName = '/branch';

  final Branch branch;

  @override
  ConsumerState<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends ConsumerState<BranchDetailScreen> {
  int _selectedDay = 0;

  static const _dayLabels = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

  (String, int) _dayFor(int offset) {
    final date = DateTime.now().add(Duration(days: offset));
    return (_dayLabels[date.weekday - 1], date.day);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final branch = widget.branch;
    final classesAsync = ref.watch(branchClassesProvider(branch.id));
    final trainersAsync = ref.watch(branchTrainersProvider(branch.id));
    final reserved = ref.watch(reservedClassesProvider);
    final isFavorite = ref.watch(
      favoriteBranchesProvider.select((ids) => ids.contains(branch.id)),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 248,
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
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => ref
                      .read(favoriteBranchesProvider.notifier)
                      .toggle(branch.id),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.35),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 17,
                      color: isFavorite ? brand.accent : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CoverImage(url: branch.imageUrl),
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
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BadgeChip(
                          label: branch.isOpen ? 'ABIERTA AHORA' : 'CERRADA',
                          color: branch.isOpen
                              ? brand.occupancyLow
                              : brand.occupancyHigh,
                          icon: Icons.access_time_rounded,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          branch.name,
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _OccupancyCard(branch: branch),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 7,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final day = _dayFor(index);
                    final selected = index == _selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          color: selected ? brand.accent : brand.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: brand.cardBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.$1,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: selected
                                    ? Colors.white
                                    : brand.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${day.$2}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: selected
                                    ? Colors.white
                                    : brand.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Text('Clases grupales',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          classesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  children: [
                    _ClassSkeleton(),
                    SizedBox(height: 12),
                    _ClassSkeleton(),
                    SizedBox(height: 12),
                    _ClassSkeleton(),
                  ],
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No pudimos cargar las clases: $error',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            data: (classes) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: ClassTile(
                    gymClass: classes[index],
                    reserved: reserved.contains(classes[index].id),
                    onToggle: () => ref
                        .read(reservedClassesProvider.notifier)
                        .toggle(classes[index].id),
                    onTap: () =>
                        ClassDetailSheet.show(context, classes[index]),
                  ),
                ),
                childCount: classes.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Text('Entrenadores en turno',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          trainersAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  children: [
                    _TrainerSkeleton(),
                    SizedBox(width: 12),
                    _TrainerSkeleton(),
                    SizedBox(height: 12),
                    _TrainerSkeleton(),
                  ],
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No pudimos cargar los entrenadores: $error',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            data: (trainers) => SliverToBoxAdapter(
              child: SizedBox(
                height: 172,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: trainers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => TrainerCard(
                    trainer: trainers[index],
                    onTap: () => Navigator.of(context).pushNamed(
                      TrainerProfileScreen.routeName,
                      arguments: trainers[index],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
    );
  }
}

class _ClassSkeleton extends StatelessWidget {
  const _ClassSkeleton();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      height: 76,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brand.cardBorder),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 46, height: 34, radius: 10),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                SkeletonBox(width: 120, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerSkeleton extends StatelessWidget {
  const _TrainerSkeleton();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      width: 138,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brand.cardBorder),
      ),
      child: Column(
        children: [
          SkeletonBox(width: 56, height: 56, radius: 99),
          const SizedBox(height: 10),
          SkeletonBox(width: double.infinity, height: 11),
          const SizedBox(height: 6),
          SkeletonBox(width: double.infinity, height: 9),
        ],
      ),
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final ratio = branch.occupancy;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brand.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AFORO · PRONÓSTICO POR HORA',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(letterSpacing: 1.4),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Ahora ${branch.currentCapacity} de '
                      '${branch.maxCapacity} cupos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: brand.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BadgeChip(
                label: brand.occupancyLabelFor(ratio),
                color: brand.occupancyFor(ratio),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HourlyForecastChart(
            currentRatio: ratio,
            drift: (branch.id.hashCode % 9 - 4) / 100,
          ),
          const SizedBox(height: 12),
          const ForecastLegend(),
          const SizedBox(height: 14),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => CheckInSheet.show(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: brand.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: brand.accent.withValues(alpha: 0.35),
                ),
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
                  Text(
                    'CHECK-IN AQUÍ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: brand.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
