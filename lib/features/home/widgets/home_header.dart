import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/member_avatar.dart';
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
            child: MemberAvatar(
              avatarId: member?.avatarId,
              initials: member?.initials ?? 'CF',
              size: 48,
            ),
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
