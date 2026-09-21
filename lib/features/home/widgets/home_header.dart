import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../data/repositories/gym_repositories.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final member = ref.watch(memberProvider).value;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipOval(
            child: member?.photoUrl != null
                ? Image.network(
                    member!.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _InitialsBox(
                      initials: member.initials,
                    ),
                  )
                : _InitialsBox(initials: member?.initials ?? 'CF'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: brand.accent,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                member?.name ?? 'Socio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: brand.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _BellButton(),
      ],
    );
  }
}

class _InitialsBox extends StatelessWidget {
  const _InitialsBox({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return ColoredBox(
      color: brand.surface,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: brand.accent,
          ),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: brand.surface,
          border: Border.all(color: brand.cardBorder),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_rounded,
                size: 20,
                color: brand.textPrimary,
              ),
            ),
            Positioned(
              right: 9,
              top: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brand.accent,
                  border: Border.all(color: brand.surface, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
